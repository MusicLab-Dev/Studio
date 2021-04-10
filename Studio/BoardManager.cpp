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

    // _boards.push(std::make_unique<Board>())->setSize(QSize(10, 10));
    // _boards.push(std::make_unique<Board>())->setSize(QSize(12, 8));
    // _boards.push(std::make_unique<Board>())->setSize(QSize(8, 8));

    _networkBuffer.reset();

    initTcpMasterSocket();

    _identifierTable = new bool[256];
    std::memset(_identifierTable, 0, 256);
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
    // qDebug() << "Tick";

    // Prepare clients sockets for future operations
    prepareSockets();
    // Process connected clients inputs using select()
    processDirectClients();
}

void BoardManager::discover(void)
{
    // qDebug() << "Discover";

    const auto interfaces = listNetworkInterfaces();

    discoveryEmit(interfaces);

    // Scan for new incomming connection(s)
    processNewConnections();
}

std::unordered_map<int, std::string> BoardManager::getRoutingTables(void)
{
    std::ifstream rt_tables;
    std::unordered_map<int, std::string> tables {};

    rt_tables.open("/etc/iproute2/rt_tables", std::istream::in);
    if (rt_tables.is_open() == false)
        throw std::runtime_error("Cannot open routing table configuration file");
    std::string line;
    while (std::getline(rt_tables, line)) {
        std::istringstream iss(line);
        int tableIndex;
        std::string tableName;
        if (line[0] == '#') {
            std::cout << "Commented line..." << std::endl;
            continue;
        }
        if (!(iss >> tableIndex >> tableName)) { // ERROR
            std::cout << "PARSING ERROR" << std::endl;
            continue;
        }
        tables.insert({tableIndex, tableName});
    }
    rt_tables.close();
    return tables;
}

void BoardManager::writeRoutingTables(const std::unordered_map<int, std::string> &tables)
{
    std::ofstream rt_tables;

    rt_tables.open("/etc/iproute2/rt_tables", std::ofstream::out | std::ofstream::trunc);
    if (rt_tables.is_open() == false)
        throw std::runtime_error("Cannot open routing table configuration file");
    for (const auto &table: tables) {
        rt_tables << table.first << '\t' << table.second << '\n';
    }
    rt_tables.close();
}

void BoardManager::addEthernetRoute(struct ifaddrs *ifa)
{
    std::string interface_name(ifa->ifa_name);
    sockaddr_in *ifaceaddr = reinterpret_cast<sockaddr_in *>(ifa->ifa_addr);
    std::string iface_address(::inet_ntoa(ifaceaddr->sin_addr));
    int netmask = reinterpret_cast<sockaddr_in *>(ifa->ifa_netmask)->sin_addr.s_addr;
    int length = 0;
    in_addr networkId;

    while (netmask > 0) {
        netmask = netmask >> 1;
        length++;
    }
    auto tables = getRoutingTables();
    int tableIndex = -1;
    for (const auto &table: tables) {
        if (table.second == interface_name) {
            tableIndex = table.first;
            break;
        }
    }
    if (tableIndex < 0) {
        tableIndex = 1;
        while (tableIndex < 255) {
            if (tables.find(tableIndex) == tables.end())
                break;
            tableIndex++;
        }
        tables.insert({tableIndex, interface_name});
    }
    writeRoutingTables(tables);
    networkId.s_addr = ifaceaddr->sin_addr.s_addr & ((struct sockaddr_in *)(ifa->ifa_netmask))->sin_addr.s_addr;
    const std::string command1("ip route add " + std::string(::inet_ntoa(networkId)) + '/' + std::to_string(length) + " dev " + interface_name + " table " + interface_name);
    const std::string command2("ip rule add from " + iface_address + " lookup " + interface_name);
    system(command1.c_str());
    system(command2.c_str());
}

std::vector<std::pair<std::string, std::string>> BoardManager::listNetworkInterfaces(void)
{
    struct ifaddrs *ifaddr;
    int family;
    int i = 0;
    std::vector<std::pair<std::string, std::string>> interfaces {};

    std::cout << '\n';

    auto ret = ::getifaddrs(&ifaddr);
    if (ret < 0)
        throw std::runtime_error(std::strerror(errno));
    for (struct ifaddrs *ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next) {
        if (ifa->ifa_addr == nullptr)
            continue;
        family = ifa->ifa_addr->sa_family;

        if (family == AF_INET && (ifa->ifa_flags & IFF_BROADCAST) && ifa->ifa_ifu.ifu_broadaddr != nullptr) {

            sockaddr_in *broadaddr = reinterpret_cast<sockaddr_in *>(ifa->ifa_ifu.ifu_broadaddr);

            std::string interface_name(ifa->ifa_name);
            std::string broad_address(::inet_ntoa(broadaddr->sin_addr));

            std::cout << "interface: " << interface_name << std::endl;
            std::cout << "broadcast: " << broad_address << '\n' << std::endl;

            addEthernetRoute(ifa);

            interfaces.push_back({interface_name, broad_address});
            i++;
        }
    }

    ::freeifaddrs(ifaddr);
    return interfaces;
}

int BoardManager::createBroadcastSocket(const std::string &interfaceName)
{
    int socket { -1 };
    int broadcast { 1 };
    const char *iface = interfaceName.c_str();
    struct ifreq ifr;

    socket = ::socket(AF_INET, SOCK_DGRAM, 0);
    if (socket < 0)
        throw std::runtime_error(std::strerror(errno));
    auto ret = ::setsockopt(socket, SOL_SOCKET, SO_BROADCAST, &broadcast, sizeof(broadcast));
    if (ret < 0)
        throw std::runtime_error(std::strerror(errno));
    ::memset(&ifr, 0, sizeof(struct ifreq));
    ::snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), iface);
    ::ioctl(socket, SIOCGIFINDEX, &ifr);
    ret = ::setsockopt(socket, SOL_SOCKET, SO_BINDTODEVICE, (void*)&ifr, sizeof(struct ifreq));
    if (ret < 0)
        throw std::runtime_error(std::strerror(errno));
    return socket;
}

void BoardManager::discoveryEmit(const std::vector<std::pair<std::string, std::string>> &interfaces)
{
    Protocol::DiscoveryPacket packet;
    std::memset(&packet, 0, sizeof(Protocol::DiscoveryPacket));
    packet.magicKey = Protocol::SpecialLabMagicKey;
    packet.boardID = static_cast<Protocol::BoardID>(420);
    packet.connectionType = Protocol::ConnectionType::USB;
    packet.distance = 0;

    for (const auto &interfaceDetails : interfaces) {

        sockaddr_in udpBroadcastAddress {
            .sin_family = AF_INET,
            .sin_port = ::htons(420),
            .sin_addr = {
                .s_addr = ::inet_addr(interfaceDetails.second.c_str())
            },
            .sin_zero = { 0 }
        };
        int socket = createBroadcastSocket(interfaceDetails.first);
        const auto ret = ::sendto(
            socket,
            &packet,
            sizeof(Protocol::DiscoveryPacket),
            0,
            reinterpret_cast<const sockaddr *>(&udpBroadcastAddress),
            sizeof(udpBroadcastAddress)
        );
        if (ret < 0) {
            std::cout << "BoardManager::discoveryEmit::sendto failed: " << std::strerror(errno) << std::endl;
        }
        close(socket);
    }
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

void BoardManager::prepareSockets(void)
{
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

void BoardManager::setSocketKeepAlive(const int socket)
{
    int enable = 1;
    int idle = 3;
    int interval = 3;
    int maxpkt = 1;

    setsockopt(socket, SOL_SOCKET, SO_KEEPALIVE, &enable, sizeof(int));
    setsockopt(socket, IPPROTO_TCP, TCP_KEEPIDLE, &idle, sizeof(int));
    setsockopt(socket, IPPROTO_TCP, TCP_KEEPINTVL, &interval, sizeof(int));
    setsockopt(socket, IPPROTO_TCP, TCP_KEEPCNT, &maxpkt, sizeof(int));
}

void BoardManager::processNewConnections(void)
{
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
        // Set keepalive on socket
        setSocketKeepAlive(clientSocket);
        // Push the newly connected client to the client list
        std::cout << "New connection from [" << inet_ntoa(clientAddress.sin_addr) << ':' << clientAddress.sin_port << ']' << std::endl;
        _clients.push(clientSocket);
    }
}

void BoardManager::removeDirectClientNetwork(const Net::Socket &rootClientSocket)
{
    const auto rootClientFd = rootClientSocket.get();
    std::cout << "Board list size in: " << _boards.size() << std::endl;
    for (auto &boardUniquePtr: _boards) {
        const auto socketView = boardUniquePtr.get()->getRooter();
        if (socketView.get() == rootClientFd) {
            _boards.erase(&boardUniquePtr);
        }
    }
    std::cout << "Board list size out: " << _boards.size() << std::endl;
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

void BoardManager::processClientInput(Net::Socket *clientSocket)
{
    std::uint8_t *bufferPtr = _networkBuffer.data() + _writeIndex;

    const auto inputSize = ::recv(clientSocket->get(), bufferPtr, NetworkBufferSize, 0);
    if (inputSize == 0 || (inputSize < 0 && errno == ETIMEDOUT)) { // Disconnection || Connection timed out, broken...
        std::cout << "BoardManager::processClientInput: Disconnection detected" << std::endl;
        removeDirectClientNetwork(*clientSocket);
        _clients.erase(clientSocket);
        return;
    }
    std::cout << inputSize << " byte(s) received from client" << std::endl;
    Protocol::ReadablePacket packet(bufferPtr, bufferPtr + inputSize);
    if (packet.protocolType() == Protocol::ProtocolType::Connection &&
            packet.commandAs<Protocol::ConnectionCommand>() == Protocol::ConnectionCommand::IDAssignment &&
            packet.footprintStackSize() == 0) {

        std::cout << "Direct client ID request !" << std::endl;
        BoardID newID = aquireIdentifier();
        if (newID == 0) {
            std::cout << "aquireIdentifier ERROR" << std::endl;
            /* handle out of identifier error here */
            return;
        }
        char buffer[sizeof(WritablePacket::Header) + sizeof(BoardID)];
        WritablePacket response(std::begin(buffer), std::end(buffer));
        response.prepare(ProtocolType::Connection, ConnectionCommand::IDAssignment);
        response << newID;
        const auto ret = ::send(clientSocket->get(), &buffer, response.totalSize(), 0);
        if (ret < 0) {
            std::cout << "BoardManager::processClientInput::send failed: " << std::strerror(errno) << std::endl;
            return;
        }
        Net::Socket::Internal clientFD = clientSocket->get();
        _boards.push(std::make_unique<Board>(newID, clientFD));
    }

    _writeIndex += inputSize;
}

void BoardManager::processDirectClients(void)
{
    if (_clients.empty()) {
        std::cout << "BoardManager::processDirectInputs: No client connected, return" << std::endl;
        return;
    }

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
