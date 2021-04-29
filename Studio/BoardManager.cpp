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

    _networkBuffer.reset();

    _identifierTable = new bool[256];
    std::memset(_identifierTable, 0, 256);
}

BoardManager::~BoardManager(void)
{
    std::cout << "BoardManager::~BoardManager" << std::endl;
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
    std::cout << "\nBoardManager::tick\n" << std::endl;

    // Prepare clients sockets for future operations using select()
    prepareSockets();
    // Process connected clients inputs using select()
    processDirectClients();
}

void BoardManager::discover(void)
{
    std::cout << "BoardManager::discover" << std::endl;

    // vector<tuple<interfaceName, localAddress, broadcastAddress>>
    const auto usbInterfaces = getUsbNetworkInterfaces();

    // Process USB network interfaces only
    processNewUsbInterfaces(usbInterfaces);

    // Emit discovery packet on discovered network interfaces
    discoveryEmit();

    // Scan for new incomming connection(s) from discovered network interfaces
    processNewConnections();
}

void BoardManager::discoveryEmit(void)
{
    std::cout << "BoardManager::discoveryEmit" << std::endl;

    // Create the studio discovery packet
    Protocol::DiscoveryPacket packet;
    std::memset(&packet, 0, sizeof(Protocol::DiscoveryPacket));
    packet.magicKey = Protocol::SpecialLabMagicKey;
    packet.boardID = static_cast<Protocol::BoardID>(420);
    packet.connectionType = Protocol::ConnectionType::USB;
    packet.distance = 0;

    for (const auto &networkInterface : _interfaces) {

        Socket broadcastSocket { networkInterface.second.second };
        sockaddr_in broadcastAddress { 0 };
        Socklen len = sizeof(broadcastAddress);

        auto ret = ::getsockname(
            broadcastSocket,
            reinterpret_cast<sockaddr *>(&broadcastAddress),
            &len
        );
        if (ret < 0) {
            throw std::runtime_error(std::strerror(errno));
        }

        ret = sendToSocket(broadcastSocket, broadcastAddress, reinterpret_cast<std::uint8_t *>(&packet), sizeof(packet));
        if (ret < 0) {
            if (errno == ENODEV) {
                /*
                    sendto() has failed because the network interface is not valid anymore,
                    so checking to remove the associated network.
                */
                std::cout << "INTERFACE DISCONNECTED" << std::endl;
                removeInterfaceNetwork(networkInterface.first);
            }
            else {
                throw std::runtime_error(std::strerror(errno));
            }
        }
    }
}

Socket BoardManager::createTcpMasterSocket(const std::string &interfaceName, const std::string &localAddress)
{
    Socket tcpMasterSocket { -1 };

    // Open TCP master socket
    tcpMasterSocket = ::socket(AF_INET, SOCK_STREAM, 0);
    if (tcpMasterSocket < 0)
        throw std::runtime_error(std::strerror(errno));

    // Set address to be reusable
    setSocketReusable(tcpMasterSocket);

    // Set socket in non-blocking mode
    setSocketNonBlocking(tcpMasterSocket);

    // Bind TCP socket to the device specified by interfaceName
    setSocketDevice(tcpMasterSocket,interfaceName);

    // Create the interface address to bind the socket to
    NetworkAddress interfaceAddress = createNetworkAddress(421, localAddress);

    // Bind the socket to the interface address
    bindSocket(tcpMasterSocket, interfaceAddress);

    // Listen for incomming connections on the master socket
    listenSocket(tcpMasterSocket);

    return tcpMasterSocket;
}

Socket BoardManager::createUdpBroadcastSocket(const std::string &interfaceName, const std::string &broadcastAddress)
{
    Socket broadcastSocket { -1 };

    // Create a new UDP socket
    broadcastSocket = ::socket(AF_INET, SOCK_DGRAM, 0);
    if (broadcastSocket < 0)
        throw std::runtime_error(std::strerror(errno));

    // Set broadcast enabled on the socket
    enableSocketBroadcast(broadcastSocket);

    // Bind socket to the specific interface
    setSocketDevice(broadcastSocket, interfaceName);

    // Bind the UDP socket to the interface broadcast address
    NetworkAddress udpBroadcastAddress = createNetworkAddress(420, broadcastAddress);

    // Bind the socket to the interface broadcast address
    bindSocket(broadcastSocket, udpBroadcastAddress);

    return broadcastSocket;
}

void BoardManager::processNewUsbInterfaces(const std::vector<std::tuple<std::string, std::string, std::string>> &usbInterfaces)
{
    for (const auto &usbInterface : usbInterfaces) {

        const std::string &interfaceName = std::get<0>(usbInterface);
        const std::string &localAddress = std::get<1>(usbInterface);
        const std::string &broadcastAddress = std::get<2>(usbInterface);

        if (interfaceName[0] != 'e')
            continue;

        if (_interfaces.find(interfaceName) == _interfaces.end()) {

            std::cout << "New USB interface \"" << interfaceName << "\" detected" << std::endl;

            Socket masterSocket = createTcpMasterSocket(interfaceName, localAddress);
            Socket broadcastSocket = createUdpBroadcastSocket(interfaceName, broadcastAddress);
            _interfaces.insert( { interfaceName, { masterSocket, broadcastSocket } } );
        }
    }
}

std::vector<std::tuple<std::string, std::string, std::string>> BoardManager::getUsbNetworkInterfaces(void)
{
    std::vector<std::tuple<std::string, std::string, std::string>> interfaces {};

    #ifdef WIN32

    #else
        struct ifaddrs *ifaddr;
        int family;
        int i = 0;


        std::cout << '\n';

        auto ret = ::getifaddrs(&ifaddr);
        if (ret < 0)
            throw std::runtime_error(std::strerror(errno));
        for (struct ifaddrs *ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next) {
            if (ifa->ifa_addr == nullptr)
                continue;
            family = ifa->ifa_addr->sa_family;
            if (family == AF_INET && (ifa->ifa_flags & IFF_BROADCAST) && ifa->ifa_ifu.ifu_broadaddr != nullptr) {

                sockaddr_in *ifaceaddr = reinterpret_cast<sockaddr_in *>(ifa->ifa_addr);
                sockaddr_in *broadaddr = reinterpret_cast<sockaddr_in *>(ifa->ifa_ifu.ifu_broadaddr);

                std::string interfaceName(ifa->ifa_name);
                std::string localAddress(::inet_ntoa(ifaceaddr->sin_addr));
                std::string broadcastAddress(::inet_ntoa(broadaddr->sin_addr));

                std::cout << "interface: " << interfaceName << '\n';
                std::cout << "address  : " << localAddress << '\n';
                std::cout << "broadcast: " << broadcastAddress << '\n' << std::endl;

                interfaces.push_back({ interfaceName, localAddress, broadcastAddress });
                i++;
            }
        }
        ::freeifaddrs(ifaddr);
    #endif

    return interfaces;
}

void BoardManager::prepareSockets(void)
{
    if (_clients.empty())
        return;

    FD_ZERO(&_readFds);
    _maxFd = -1;

    for (const auto &directClient : _clients) {
        const auto fd = directClient.socket;
        if (fd > 0) {
            FD_SET(fd, &_readFds);
            if(fd > _maxFd)
                _maxFd = fd;
        }
    }
}

void BoardManager::processNewConnections(void)
{
    std::cout << "BoardManager::processNewConnections" << '\n';

    sockaddr_in clientAddress { 0 };
    Socklen clientAddressLen = sizeof(clientAddress);

    for (const auto &networkInterface : _interfaces) {

        std::cout << "Start accept on: " << networkInterface.first << std::endl;

        Socket interfaceMasterSocket = networkInterface.second.first;

        const Socket clientSocket = ::accept(
            interfaceMasterSocket,
            reinterpret_cast<sockaddr *>(&clientAddress),
            &clientAddressLen
        );

        if (clientSocket < 0 && (errno == EAGAIN || errno == EWOULDBLOCK)) {
            std::cout << "BoardManager::processNewConnections: No pending connection on socket" << std::endl;
            continue;
        }
        else if (clientSocket < 0) {
            throw std::runtime_error(std::strerror(errno));
        }

        setSocketNonBlocking(clientSocket);
        setSocketKeepAlive(clientSocket);

        std::cout << "New connection from [" << inet_ntoa(clientAddress.sin_addr) << ':' << clientAddress.sin_port << ']' << std::endl;

        DirectClient directClient = {
            .socket = clientSocket,
            .interfaceName = networkInterface.first
        };

        _clients.push(directClient);
    }
}

bool BoardManager::handleIdentifierRequest(const Protocol::ReadablePacket &packet, const Socket &clientSocket)
{
    using namespace Protocol;

    if (packet.protocolType() == ProtocolType::Connection &&
        packet.commandAs<ConnectionCommand>() == ConnectionCommand::IDAssignment &&
        packet.footprintStackSize() == 0) {

        std::cout << "Identifier request from a direct client received." << std::endl;

        BoardID newID = aquireIdentifier();
        if (newID == 0) {
            std::cout << "BoardManager::aquireIdentifier: OUT OF IDENTIFIER" << std::endl;
            /* handle out of identifier error here */
            throw std::runtime_error("OUT OF IDENTIFIER");
        }
        // Return the identifier to the direct client
        char buffer[sizeof(WritablePacket::Header) + sizeof(BoardID)];
        WritablePacket response(std::begin(buffer), std::end(buffer));
        response.prepare(ProtocolType::Connection, ConnectionCommand::IDAssignment);
        response << newID;
        // Send the identifier response to the client
        int ret = sendSocket(clientSocket, reinterpret_cast<std::uint8_t *>(&buffer), static_cast<int>(response.totalSize()));
        if (ret < 0)
            throw std::runtime_error(std::strerror(errno));
        // Add the new board the studio list
        _boards.push(std::make_shared<Board>(newID, clientSocket));
        return true;
    }
    return false;
}

void BoardManager::processClientInput(Socket &clientSocket)
{
    std::uint8_t *bufferPtr = _networkBuffer.data() + _writeIndex;

    const auto inputSize = recvSocket(clientSocket, bufferPtr, NetworkBufferSize);

    if (inputSize == 0 || (inputSize < 0 && errno == ETIMEDOUT)) {
        /*
            recv() detected that the connection has been closed by the peer or
            the keepalive option detected that the peer has timed out.
        */
        std::cout << "BoardManager::processClientInput: Direct client disconnection detected" << std::endl;
        removeDirectClientNetwork(clientSocket);
        closeSocket(clientSocket);
        clientSocket = -1;
        return;
    }
    else if (inputSize < 0) {
        throw std::runtime_error(std::strerror(errno));
    }

    std::cout << inputSize << " byte(s) received from client" << std::endl;

    Protocol::ReadablePacket packet(bufferPtr, bufferPtr + inputSize);

    // Check if the received packet is a identifier request, must be processed now
    if (handleIdentifierRequest(packet, clientSocket) == true) {
        std::memset(bufferPtr, 0, inputSize);
        return;
    }

    // Increment network buffer by the size of the received data
    _writeIndex += inputSize;
}

void BoardManager::processDirectClients(void)
{
    if (_clients.empty()) {
        std::cout << "BoardManager::processDirectClients: No client to process, return" << std::endl;
        return;
    }

    _writeIndex = 0;
    _networkBuffer.reset();

    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    auto activity = ::select(_maxFd + 1, &_readFds, NULL, NULL, &tv);
    if (activity < 0 && errno != EINTR) {
        std::cout << "BoardManager::processDirectClients::select: " << std::strerror(errno) << std::endl;
        return;
    }
    else if (activity == 0) {
        std::cout << "BoardManager::processDirectClients: No activity from any of the clients" << std::endl;
        return;
    }

    // Loop through direct clients and retrieve available data or remove them if disconnected
    std::cout << "client list size IN: " << _clients.size() << std::endl;
    for(auto it = _clients.begin(); it != _clients.end();) {
        if (FD_ISSET(it->socket, &_readFds)) {
            processClientInput(it->socket);
            if (it->socket == -1) {
                _clients.erase(it);
            } else
                ++it;
        } else
            ++it;
    }
    std::cout << "client list size OUT: " << _clients.size() << std::endl;
}

BoardID BoardManager::aquireIdentifier(void) noexcept
{
    int i = 1;

    while (i < 256) {
        if (_identifierTable[i] == false) {
            _identifierTable[i] = true;
            return i;
        }
        i++;
    }
    return 0;
}

void BoardManager::removeNetworkFrom(const BoardID senderId, const BoardID targetId)
{
    if (_boards.empty())
        return;
    // Find and mark all disconnected board
    for (auto &board : _boards) {
        if (board.get()->getIdentifier() == senderId) {

            // Get the sender pointer
            Board *sender = board.get();
            // Get the target pointer
            Board *target = sender->getSlave(targetId);

            if (target == nullptr) {
                throw std::runtime_error("Cannot find disconnected board !");
            }
            // Mark all the network behind target as disconnected
            target->markSlavesOff();
            // Mark target as disconnected
            target->setStatus(false);
            // Detach target from sender
            sender->detachSlave(targetId);
            break;
        }
    }
    // Remove all disconnected board from main board vector
    for (auto &board : _boards) {
        if (board->getStatus() == false) {
            // board.unique();
            board.reset();
            _boards.erase(&board);
        }
    }
}

void BoardManager::removeDirectClientNetwork(const Socket directClientSocket)
{
    std::cout << "BoardManager::removeDirectClientNetwork" << std::endl;

    std::cout << "board list size IN: " << _boards.size() << std::endl;
    for (auto it = _boards.begin(); it != _boards.end();) {
        if (it->get()->getRootSocket() == directClientSocket)
            _boards.erase(it);
        else
            ++it;
    }
    std::cout << "board list size OUT: " << _boards.size() << std::endl;
}

void BoardManager::removeInterfaceNetwork(const std::string &interfaceName)
{
    std::cout << "BoardManager::removeInterfaceNetwork" << std::endl;

    std::cout << "Removing interface network for: " << interfaceName << std::endl;

    for (auto &directClient : _clients) {
        if (directClient.interfaceName == interfaceName) {
            removeDirectClientNetwork(directClient.socket);
            close(directClient.socket);
            directClient.socket = -1;
        }
    }
    for (auto it = _clients.begin(); it != _clients.end();) {
        if (it->socket == -1)
            _clients.erase(it);
        else
            ++it;
    }
}
