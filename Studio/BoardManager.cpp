/**
 * @ Author: Paul Creze
 * @ Description: Board manager
 */

#include <QDebug>

#include "BoardManager.hpp"

BoardManager::BoardManager(void) : _networkBuffer(NetworkBufferSize)
{
    std::cout << "BoardManager::BoardManager" << std::endl;

    onTickRateChanged();
    onDiscoverRateChanged();
    _tickTimer.start();
    _discoverTimer.start();
    connect(this, &BoardManager::tickRateChanged, this, &BoardManager::onTickRateChanged);
    connect(this, &BoardManager::discoverRateChanged, this, &BoardManager::onDiscoverRateChanged);
    connect(&_tickTimer, &QTimer::timeout, this, &BoardManager::tick);
    connect(&_discoverTimer, &QTimer::timeout, this, &BoardManager::discover);

    _boards.push(std::make_unique<Board>())->setSize(QSize(10, 10));
    _boards.push(std::make_unique<Board>())->setSize(QSize(12, 8));
    _boards.push(std::make_unique<Board>())->setSize(QSize(8, 8));

    _networkBuffer.reset();

    initUdpBroadcastSocket();
    initTcpMasterSocket();
}

BoardManager::~BoardManager(void)
{
    std::cout << "BoardManager::~BoardManager" << std::endl;

    close(_udpBroadcastSocket);
    close(_tcpMasterSocket);
}

QHash<int, QByteArray> BoardManager::roleNames(void) const
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Role::Instance), "boardInstance" },
        { static_cast<int>(Role::Size),     "boardSize" }
    };
}

int BoardManager::rowCount(const QModelIndex &) const
{
    qDebug() << "Board size" << _boards.size();
    return _boards.size();
}

QVariant BoardManager::data(const QModelIndex &index, int role) const
{
    const auto &elem = _boards[index.row()];

    switch (static_cast<Role>(role)) {
    case Role::Instance:
        return QVariant::fromValue(elem.get());
    case Role::Size:
        return elem->size();
    default:
        throw std::logic_error("BoardManager::data: Invalid role");
    }
}

void BoardManager::setTickRate(const int value)
{
    if (_tickRate == value)
        return;
    _tickRate = value;
    emit tickRateChanged();
}

void BoardManager::setDiscoverRate(const int value)
{
    if (_discoverRate == value)
        return;
    _discoverRate = value;
    emit discoverRateChanged();
}

void BoardManager::onTickRateChanged(void)
{
    _tickTimer.setInterval(tickRate());
    _tickTimer.setTimerType(Qt::PreciseTimer); // Max precision
}

void BoardManager::onDiscoverRateChanged(void)
{
    _discoverTimer.setInterval(discoverRate());
    _tickTimer.setTimerType(Qt::CoarseTimer); // 5% margin
}

void BoardManager::tick(void)
{
    qDebug() << "Tick";
    // Prepare clients sockets for future operations
    prepareSockets();
    // Process connected clients inputs using select()
    processDirectClients();
}

void BoardManager::discover(void)
{
    qDebug() << "Discover";

    // Emit a discovery packet
    discoveryEmit();
    // Scan for new incomming connection(s)
    processNewConnections();
}

void BoardManager::prepareSockets(void)
{
    std::cout << "BoardManager::prepareSockets" << std::endl;

    FD_ZERO(&_readFds);
    FD_SET(_tcpMasterSocket, &_readFds);
    _maxFd = _tcpMasterSocket;

    if (_clients.empty())
        return;
    for (const auto &clientSocket : _clients) {
        const auto fd = clientSocket.get();
        if (fd > 0) {
            FD_SET(fd, &_readFds);
            if(fd > _maxFd)
                _maxFd = fd;
        }
    }
}

void BoardManager::processNewConnections(void)
{
    std::cout << "BoardManager::processNewConnections" << std::endl;

    sockaddr_in clientAddress { 0 };
    socklen_t clientAddressLen = sizeof(clientAddress);

    while (1) {
        const auto clientSocket = ::accept(
            _tcpMasterSocket,
            reinterpret_cast<sockaddr *>(&clientAddress),
            &clientAddressLen
        );
        // Loop end condition, until all pending connection(s) are proccessed
        if (clientSocket < 0 && (errno == EAGAIN || errno == EWOULDBLOCK)) {
            std::cout << "BoardManager::processNewConnections: No new client connection to proccess" << std::endl;
            return;
        } else if (clientSocket < 0)
            throw std::runtime_error(std::strerror(errno));
        // Push the newly connected client to the client list
        std::cout << "New connection from [" << inet_ntoa(clientAddress.sin_addr) << ':' << clientAddress.sin_port << ']' << std::endl;
        _clients.push(clientSocket);
    }
}

// std::unique_ptr<Board> *BoardManager::getBoardFromSocket(const Net::Socket &clientSocket)
// {
//     const auto clientFd = clientSocket.get();
//     for (auto &boardUniquePtr: _boards) {
//         const auto socketView = boardUniquePtr.get()->getRooter();
//         if (socketView.get() == clientFd) {
//             return &boardUniquePtr;
//         }
//     }
//     return nullptr;
// }

void BoardManager::removeDirectClientNetwork(const Net::Socket &rootClientSocket)
{
    const auto rootClientFd = rootClientSocket.get();
    for (auto &boardUniquePtr: _boards) {
        const auto socketView = boardUniquePtr.get()->getRooter();
        if (socketView.get() == rootClientFd) {
            _boards.erase(&boardUniquePtr);
        }
    }
}

void BoardManager::processClientInput(Net::Socket *clientSocket)
{
    std::cout << "BoardManager::processClientInput" << std::endl;

    std::uint8_t *bufferPtr = _networkBuffer.data() + _writeIndex;

    const auto inputSize = ::recv(clientSocket->get(), bufferPtr, NetworkBufferSize, 0);
    if (inputSize == 0) {
        std::cout << "BoardManager::processClientInput: Disconnection detected" << std::endl;
        removeDirectClientNetwork(*clientSocket);
        _clients.erase(clientSocket);
        return;
    }
    std::cout << inputSize << " received from client" << std::endl;
    _writeIndex += inputSize;
}

void BoardManager::processDirectClients(void)
{
    std::cout << "BoardManager::processDirectInputs" << std::endl;

    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 0;

    _writeIndex = 0;
    _networkBuffer.reset();

    auto activity = ::select(_maxFd + 1, &_readFds, NULL, NULL, &tv);

    if ((activity < 0) && (errno != EINTR)) {
        std::cout << "BoardManager::processDirectInputs::select: " << std::strerror(errno) << std::endl;
        return;
    } else if (activity == 0) {
        std::cout << "BoardManager::processDirectInputs: No activity from any of the clients" << std::endl;
        return;
    }

    for (auto client = _clients.begin(); client != _clients.end(); ) {

        if (FD_ISSET(client->get(), &_readFds)) {
            processClientInput(client);
        }
        if (client != _clients.end())
            client++;
    }
}

void BoardManager::discoveryEmit(void)
{
    std::cout << "BoardManager::discoveryEmit" << std::endl;

    Protocol::DiscoveryPacket packet;
    std::memset(&packet, 0, sizeof(Protocol::DiscoveryPacket));
    packet.magicKey = Protocol::SpecialLabMagicKey;
    packet.boardID = static_cast<Protocol::BoardID>(420);
    packet.connectionType = Protocol::ConnectionType::USB;
    packet.distance = 0;

    sockaddr_in udpBroadcastAddress {
        .sin_family = AF_INET,
        .sin_port = ::htons(420),
        .sin_addr = {
            .s_addr = ::inet_addr("169.254.255.255")
        },
        .sin_zero = { 0 }
    };

    const auto ret = ::sendto(
        _udpBroadcastSocket,
        &packet,
        sizeof(Protocol::DiscoveryPacket),
        0,
        reinterpret_cast<const sockaddr *>(&udpBroadcastAddress),
        sizeof(udpBroadcastAddress)
    );
    if (ret < 0) {
        std::cout << "BoardManager::discoveryEmit::sendto failed: " << std::strerror(errno) << std::endl;
        std::cout << "ERRNO code: " << errno << std::endl;
    }
}

void BoardManager::initUdpBroadcastSocket(void)
{
    std::cout << "BoardManager::initUdpBroadcastSocket" << std::endl;

    // Open UDP broadcast socket
    int broadcast = 1;
    _udpBroadcastSocket = ::socket(AF_INET, SOCK_DGRAM, 0);
    if (_udpBroadcastSocket < 0)
        throw std::runtime_error(std::strerror(errno));
    auto ret = ::setsockopt(
        _udpBroadcastSocket,
        SOL_SOCKET,
        SO_BROADCAST,
        &broadcast,
        sizeof(broadcast)
    );
    if (ret < 0)
        throw std::runtime_error(std::strerror(errno));
}

void BoardManager::initTcpMasterSocket(void)
{
    // Open TCP master socket
    _tcpMasterSocket = ::socket(AF_INET, SOCK_STREAM, 0);
    if (_tcpMasterSocket < 0)
        throw std::runtime_error(std::strerror(errno));

    // Set the socket options
    int enable = 1;
    if (::setsockopt(_tcpMasterSocket, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int)) < 0) {
        close(_tcpMasterSocket);
        throw std::runtime_error(std::strerror(errno));
    }

    fcntl(_tcpMasterSocket, F_SETFL, O_NONBLOCK);

    sockaddr_in localMasterAddress = {
        .sin_family = AF_INET,
        .sin_port = ::htons(421),
        .sin_addr = {
            .s_addr = ::htonl(INADDR_ANY)
        }
    };

    // Bind the TCP master socket to the local address
    auto ret = ::bind(
        _tcpMasterSocket,
        reinterpret_cast<const sockaddr *>(&localMasterAddress),
        sizeof(localMasterAddress)
    );
    if (ret < 0) {
        close(_tcpMasterSocket);
        throw std::runtime_error(std::strerror(errno));
    }

    // Listen for incomming connections on master socket
    ret = ::listen(_tcpMasterSocket, 5);
    if (ret < 0) {
        close(_tcpMasterSocket);
        throw std::runtime_error(std::strerror(errno));
    }
}
