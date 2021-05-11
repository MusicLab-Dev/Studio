/**
 * @ Author: Paul Creze
 * @ Description: Board manager
 */

#include <QDebug>

#include "NetworkLog.hpp"
#include "BoardManager.hpp"

#ifndef DISABLE_BOARD_NETWORKING
# define DISABLE_BOARD_NETWORKING true
#endif

BoardManager::BoardManager(void) : _networkBuffer(NetworkBufferSize)
{
#if DISABLE_BOARD_NETWORKING
    qDebug() << "BoardManager: Networking disabled";
    return;
#else
    qDebug() << "BoardManager: Networking enabled";

    onTickRateChanged();
    onDiscoverRateChanged();
    connect(this, &BoardManager::tickRateChanged, this, &BoardManager::onTickRateChanged);
    connect(this, &BoardManager::discoverRateChanged, this, &BoardManager::onDiscoverRateChanged);
    connect(&_tickTimer, &QTimer::timeout, this, &BoardManager::tick);
    connect(&_discoverTimer, &QTimer::timeout, this, &BoardManager::discover);

    resetNetworkBuffer();

    _identifierTable = new bool[256];
    std::memset(_identifierTable, 0, 256);

    #ifdef WIN32
        WSADATA WinsockData;
        if (WSAStartup(MAKEWORD(2, 2), &WinsockData) < 0)
            throw std::runtime_error(std::strerror(errno));
    #endif

    // Open the UDP broadcast socket
    _udpBroadcastSocket = ::socket(AF_INET, SOCK_DGRAM, 0);
    if (_udpBroadcastSocket < 0) {
        throw std::runtime_error(std::strerror(errno));
    }

    // Set socket option for UDP broadcast socket
    setSocketReusable(_udpBroadcastSocket);
    setSocketNonBlocking(_udpBroadcastSocket);
    enableSocketBroadcast(_udpBroadcastSocket);

    // Create the broadcast address
    NetworkAddress udpBroadcastAddress;
    udpBroadcastAddress.sin_family = AF_INET;
    udpBroadcastAddress.sin_port = ::htons(LexoPort);
    udpBroadcastAddress.sin_addr.s_addr = INADDR_ANY;

    // Bind the address to the socket
    try {
        bindSocket(_udpBroadcastSocket, udpBroadcastAddress);
        _tickTimer.start();
        _discoverTimer.start();
    } catch (const std::exception &e) {
        NETWORK_LOG("BoardManager::BoardManager: couldn't bind socket ", e.what());
    }
#endif
}

BoardManager::~BoardManager(void)
{
    NETWORK_LOG("BoardManager::~BoardManager");

    #ifdef WIN32
        WSACleanup();
    #endif
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
    NETWORK_LOG("Board size");
    return _boards.size();
}

QVariant BoardManager::data(const QModelIndex &index, int role) const
{
    const auto &elem = _boards[index.row()];

    switch (static_cast<Role>(role)) {
    case Role::Instance:
        return QVariant::fromValue(BoardWrapper { elem.get() });
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

void BoardManager::processBoardPacket(Protocol::ReadablePacket &packet)
{
    NETWORK_LOG("BoardManager::processBoardPacket");

    using namespace Protocol;

    BoardID packetBoardId = packet.extract<BoardID>();
    NETWORK_LOG("Packet board ID: ", static_cast<int>(packetBoardId));

    switch (packet.protocolType())
    {
    case ProtocolType::Connection:
        switch (packet.commandAs<ConnectionCommand>())
        {
        case ConnectionCommand::HardwareSpecs:
        {
            NETWORK_LOG("Received HardwareSpecs command");
            BoardSize boardSize = packet.extract<BoardSize>();

            int i = 0;
            for (const auto &board : _boards) {
                if (board->boardID() == static_cast<int>(packetBoardId)) {
                    board->setSize(QSize { static_cast<int>(boardSize.width), static_cast<int>(boardSize.heigth) });
                    emit dataChanged(index(i), index(i), { static_cast<int>(Role::Size) });
                    break;
                }
                ++i;
            }
            break;
        }
        default:
            break;
        }
        break;
    case ProtocolType::Event:
        switch (packet.commandAs<EventCommand>())
        {
        case EventCommand::ControlsChanged:
        {
            NETWORK_LOG("Received ControlsChanged command");
            Core::Vector<InputEvent> events;
            packet >> events;
            for (const auto &event : events) {
                NETWORK_LOG("Input index: ", static_cast<int>(event.inputIdx));
                NETWORK_LOG("Event value: ", static_cast<int>(event.value));
                emit boardEvent(static_cast<int>(packetBoardId), event.inputIdx, static_cast<float>(event.value));
            }
            break;
        }
        default:
            break;
        }
        break;
    default:
        break;
    }
}

void BoardManager::processNetworkBufferData(void)
{
    NETWORK_LOG("BoardManager::processNetworkBufferData");

    using namespace Protocol;

    std::uint8_t *networkBufferBegin = _networkBuffer.data();
    std::uint8_t *networkBufferEnd = _networkBuffer.data() + _writeIndex;
    std::size_t processIndex = 0;

    while (processIndex < _writeIndex) {

        ReadablePacket packet(networkBufferBegin + processIndex, networkBufferEnd);
        if (packet.magicKey() != SpecialLabMagicKey)
            break;
        processBoardPacket(packet);
        processIndex = processIndex + packet.totalSize();
    }
}

void BoardManager::tick(void)
{
    NETWORK_LOG("\nBoardManager::tick\n");

    // Prepare clients sockets for future operations using select()
    prepareSockets();
    // Process connected clients inputs using select()
    processDirectClients();
    // Process data stored in the network buffer for this tick
    if (_writeIndex == 0)
        return;
    processNetworkBufferData();
}

void BoardManager::discoveryScan(void)
{
    NETWORK_LOG("BoardManager::discoveryScan");

    // Sender address
    NetworkAddress udpSenderAddress;
    // DiscoveryPacket structure
    Protocol::DiscoveryPacket packet;
    // Receive disco packet one by one
    const auto readSize = recvFromSocket(
        _udpBroadcastSocket,
        reinterpret_cast<std::uint8_t *>(&packet),
        sizeof(packet),
        udpSenderAddress
    );
    if (readSize < 0) {
        if (operationWouldBlock() == true) {
            NETWORK_LOG("No UDP data on socket");
            return;
        }
        return;
    }
    // Check if the address is already discovered
    auto it = std::find_if(
        _discoveredAddress.begin(),
        _discoveredAddress.end(),
        [&](const auto &address) { return address.sin_addr.s_addr == udpSenderAddress.sin_addr.s_addr; }
    );
    if (it != _discoveredAddress.end())
        return;
    _discoveredAddress.push_back(udpSenderAddress);
}

void BoardManager::discover(void)
{
    NETWORK_LOG("BoardManager::discover");

    // This feature is only needed on windows
    #ifdef WIN32
        discoveryScan();
    #endif

    // vector<pair<interfaceName, ifaceAddress>>
    const auto usbInterfaces = getUsbNetworkInterfaces();

    // // Process USB network interfaces only
    processNewUsbInterfaces(usbInterfaces);

    // // Emit discovery packet on discovered network interfaces
    discoveryEmit();

    // // Scan for new incomming connection(s) from discovered network interfaces
    processNewConnections();
}

void BoardManager::discoveryEmit(void)
{
    NETWORK_LOG("BoardManager::discoveryEmit");

    // Create the studio discovery packet
    Protocol::DiscoveryPacket packet;
    std::memset(&packet, 0, sizeof(Protocol::DiscoveryPacket));
    packet.magicKey = Protocol::SpecialLabMagicKey;
    packet.boardID = static_cast<Protocol::BoardID>(420);
    packet.connectionType = Protocol::ConnectionType::USB;
    packet.distance = 0;

    #ifdef WIN32
        for (const NetworkAddress &address : _discoveredAddress) {
            NETWORK_LOG("Sending discovery packet to ", ::inet_ntoa(address.sin_addr));

            const DataSize ret = sendToSocket(
                _udpBroadcastSocket,
                address,
                reinterpret_cast<std::uint8_t *>(&packet),
                sizeof(packet)
            );
            if (ret < 0) {
                NETWORK_LOG("SENDTO ERROR");
            }
        }
    #else
        for (const auto &networkInterface : _interfaces) {

            Socket udpSocket { networkInterface.second.second };
            NetworkAddress broadcastAddress;
            broadcastAddress.sin_family = AF_INET;
            broadcastAddress.sin_port = ::htons(LexoPort);
            broadcastAddress.sin_addr.s_addr = ::inet_addr("169.254.255.255");

            NETWORK_LOG("Sending discovery packet to ", ::inet_ntoa(broadcastAddress.sin_addr));
            DataSize ret = sendToSocket(
                udpSocket,
                broadcastAddress,
                reinterpret_cast<std::uint8_t *>(&packet),
                sizeof(packet)
            );
            if (ret < 0) {
                if (errno == ENODEV) {
                    /*
                        sendto() has failed because the network interface is not valid anymore,
                        so checking to remove the associated network.
                    */
                    NETWORK_LOG("INTERFACE DISCONNECTED");
                    removeInterfaceNetwork(networkInterface.first);
                }
                else {
                    throw std::runtime_error(std::strerror(errno));
                }
            }
        }
    #endif
}

Socket BoardManager::createTcpMasterSocket(const InterfaceIndex interfaceIndex, const std::string &localAddress)
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
    setSocketDevice(tcpMasterSocket, interfaceIndex);

    // Create the interface address to bind the socket to
    NetworkAddress interfaceAddress = createNetworkAddress(LexoPort + 1, localAddress);

    // Bind the socket to the interface address
    bindSocket(tcpMasterSocket, interfaceAddress);

    // Listen for incomming connections on the master socket
    listenSocket(tcpMasterSocket, 1);

    return tcpMasterSocket;
}

Socket BoardManager::createUdpBroadcastSocket(const InterfaceIndex interfaceIndex, const std::string &broadcastAddress)
{
    Socket broadcastSocket { -1 };

    // Create a new UDP socket
    broadcastSocket = ::socket(AF_INET, SOCK_DGRAM, 0);
    if (broadcastSocket < 0)
        throw std::runtime_error(std::strerror(errno));

    setSocketReusable(broadcastSocket);

    // Set broadcast enabled on the socket
    enableSocketBroadcast(broadcastSocket);

    // Bind socket to the specific interface
    setSocketDevice(broadcastSocket, interfaceIndex);

    // Bind the UDP socket to the interface broadcast address
    NetworkAddress udpBroadcastAddress = createNetworkAddress(LexoPort, broadcastAddress);

    // Bind the socket to the interface broadcast address
    bindSocket(broadcastSocket, udpBroadcastAddress);

    return broadcastSocket;
}

void BoardManager::processNewUsbInterfaces(const std::vector<std::pair<InterfaceIndex, std::string>> &usbInterfaces)
{
    for (const auto &usbInterface : usbInterfaces) {

        const InterfaceIndex interfaceIndex = usbInterface.first;
        const std::string &ifaceAddress = usbInterface.second;

        if (ifaceAddress.substr(0, 7) != "169.254")
            continue;

        if (_interfaces.find(interfaceIndex) == _interfaces.end()) {

            NETWORK_LOG("New USB interface detected, index: ", interfaceIndex);

            Socket masterSocket = createTcpMasterSocket(interfaceIndex, ifaceAddress);
            Socket udpSocket = createUdpBroadcastSocket(interfaceIndex, ifaceAddress);
            _interfaces.insert( { interfaceIndex, { masterSocket, udpSocket } } );
        }
    }
}

std::vector<std::pair<InterfaceIndex, std::string>> getWindowsNetworkInterfaces(void)
{
    std::vector<std::pair<InterfaceIndex, std::string>> interfaces {};

    #ifdef WIN32
        #define MALLOC(x) HeapAlloc(GetProcessHeap(), 0, (x))
        #define FREE(x) HeapFree(GetProcessHeap(), 0, (x))

        PMIB_IPADDRTABLE pIPAddrTable;
        DWORD dwSize = 0;

        pIPAddrTable = (MIB_IPADDRTABLE *)MALLOC(sizeof (MIB_IPADDRTABLE));
        if (pIPAddrTable) {
            auto ret = GetIpAddrTable(pIPAddrTable, &dwSize, 0);
            if (ret == ERROR_INSUFFICIENT_BUFFER) {
                FREE(pIPAddrTable);
                pIPAddrTable = (MIB_IPADDRTABLE *)MALLOC(dwSize);
            }
            if (pIPAddrTable == nullptr)
                throw std::runtime_error("Memory allocation failed for GetIpAddrTable");
        }

        auto ret = GetIpAddrTable(pIPAddrTable, &dwSize, 0);
        if (ret != NO_ERROR)
            throw std::runtime_error(std::strerror(errno));

        for (auto i = 0; i < (int)pIPAddrTable->dwNumEntries; i++) {

            struct in_addr ifaceaddr;
            ifaceaddr.s_addr = (u_long) pIPAddrTable->table[i].dwAddr;

            InterfaceIndex interfaceIndex = pIPAddrTable->table[i].dwIndex;
            std::string ifaceAddress(::inet_ntoa(ifaceaddr));

            NETWORK_LOG("index:\t", interfaceIndex);
            NETWORK_LOG("interface address:\t", ifaceAddress);

            interfaces.push_back({ interfaceIndex, ifaceAddress });
        }
        if (pIPAddrTable) {
            FREE(pIPAddrTable);
            pIPAddrTable = nullptr;
        }
    #endif
    return interfaces;
}

std::vector<std::pair<InterfaceIndex, std::string>> getLinuxNetworkInterfaces(void)
{
    std::vector<std::pair<InterfaceIndex, std::string>> interfaces {};
    #ifdef WIN32
        return interfaces;
    #else
        struct ifaddrs *ifaddr;
        int family;
        int i = 0;

        auto ret = ::getifaddrs(&ifaddr);
        if (ret < 0)
            throw std::runtime_error(std::strerror(errno));
        for (struct ifaddrs *ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next) {
            if (ifa->ifa_addr == nullptr)
                continue;
            family = ifa->ifa_addr->sa_family;
            if (family == AF_INET && (ifa->ifa_flags & IFF_BROADCAST) && ifa->ifa_ifu.ifu_broadaddr != nullptr) {

                sockaddr_in *ifaceaddr = reinterpret_cast<sockaddr_in *>(ifa->ifa_addr);
                std::string interfaceName(ifa->ifa_name);
                InterfaceIndex interfaceIndex = if_nametoindex(ifa->ifa_name);
                std::string ifaceAddress(::inet_ntoa(ifaceaddr->sin_addr));

                NETWORK_LOG("index:\t", interfaceIndex);
                NETWORK_LOG("interface address:\t", ifaceAddress);

                // This code may be usefull later
                // sockaddr_in *broadaddr = reinterpret_cast<sockaddr_in *>(ifa->ifa_ifu.ifu_broadaddr);
                // std::string broadcastAddress(::inet_ntoa(broadaddr->sin_addr));
                // std::cout << "broadcast: " << broadcastAddress << '\n' << std::endl;

                interfaces.push_back({ interfaceIndex, ifaceAddress });
                i++;
            }
        }
        ::freeifaddrs(ifaddr);
    #endif
    return interfaces;
}

std::vector<std::pair<InterfaceIndex, std::string>> BoardManager::getUsbNetworkInterfaces(void)
{
    NETWORK_LOG("BoardManager::getUsbNetworkInterfaces");

    std::vector<std::pair<InterfaceIndex, std::string>> interfaces {};

    #ifdef WIN32
        interfaces = getWindowsNetworkInterfaces();
    #else
        interfaces = getLinuxNetworkInterfaces();
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
    NETWORK_LOG("BoardManager::processNewConnections");

    NetworkAddress clientAddress;

    for (const auto &networkInterface : _interfaces) {

        NETWORK_LOG("Start accept on interface: ", networkInterface.first);

        Socket interfaceMasterSocket = networkInterface.second.first;

        const Socket clientSocket = acceptSocket(interfaceMasterSocket, clientAddress);
        if (clientSocket < 0) {
            if (operationWouldBlock() == true) {
                NETWORK_LOG("BoardManager::processNewConnections: No pending connection on socket");
                continue;
            }
            throw std::runtime_error(std::strerror(errno));
        }

        setSocketNonBlocking(clientSocket);
        setSocketKeepAlive(clientSocket);

        NETWORK_LOG("New connection from [", ::inet_ntoa(clientAddress.sin_addr), ':', clientAddress.sin_port, ']');

        DirectClient directClient;
        directClient.socket = clientSocket;
        directClient.interfaceIndex = networkInterface.first;

        _clients.push(directClient);
    }
}

bool BoardManager::handleIdentifierRequest(const Protocol::ReadablePacket &packet, const Socket &clientSocket)
{
    using namespace Protocol;

    if (packet.protocolType() == ProtocolType::Connection &&
        packet.commandAs<ConnectionCommand>() == ConnectionCommand::IDAssignment &&
        packet.footprintStackSize() == 0) {

        NETWORK_LOG("Identifier request from a direct client received.");

        BoardID newID = aquireIdentifier();
        if (newID == 0) {
            NETWORK_LOG("BoardManager::aquireIdentifier: OUT OF IDENTIFIER");
            /* handle out of identifier error here */
            throw std::runtime_error("OUT OF IDENTIFIER");
        }
        // Return the identifier to the direct client
        char buffer[sizeof(WritablePacket::Header) + sizeof(BoardID)];
        WritablePacket response(std::begin(buffer), std::end(buffer));
        response.prepare(ProtocolType::Connection, ConnectionCommand::IDAssignment);
        response << newID;
        // Send the identifier response to the client
        DataSize ret = sendSocket(clientSocket, reinterpret_cast<std::uint8_t *>(&buffer), static_cast<int>(response.totalSize()));
        if (ret < 0)
            throw std::runtime_error(std::strerror(errno));
        // Add the new board the studio list
        beginInsertRows(QModelIndex(), rowCount(), rowCount());
        _boards.push(std::make_shared<Board>(newID, clientSocket));
        endInsertRows();
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
        NETWORK_LOG("BoardManager::processClientInput: Direct client disconnection detected");
        removeDirectClientNetwork(clientSocket);
        closeSocket(clientSocket);
        clientSocket = -1;
        return;
    }
    else if (inputSize < 0) {
        throw std::runtime_error(std::strerror(errno));
    }

    NETWORK_LOG(inputSize, " byte(s) received from client");

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
        NETWORK_LOG("BoardManager::processDirectClients: No client to process, return");
        return;
    }

    // Reset the network buffer before data from clients
    _writeIndex = 0;
    resetNetworkBuffer();

    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    auto activity = ::select(_maxFd + 1, &_readFds, NULL, NULL, &tv);
    if (activity < 0 && errno != EINTR) {
        NETWORK_LOG("BoardManager::processDirectClients::select: ", std::strerror(errno));
        return;
    }
    else if (activity == 0) {
        NETWORK_LOG("BoardManager::processDirectClients: No activity from any of the clients");
        return;
    }

    // Loop through direct clients and retrieve available data or remove them if disconnected
    NETWORK_LOG("BoardManager::processDirectClients: Client list size in: ", _clients.size());
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
    NETWORK_LOG("BoardManager::processDirectClients: Client list size out: ", _clients.size());
}

BoardID BoardManager::aquireIdentifier(void) noexcept
{
    std::uint16_t i = 1;

    while (i < 256) {
        if (_identifierTable[i] == false) {
            _identifierTable[i] = true;
            return static_cast<BoardID>(i);
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
    beginResetModel();
    for (auto &board : _boards) {
        if (board->getStatus() == false) {
            // board.unique();
            board.reset();
            _boards.erase(&board);
        }
    }
    endResetModel();
}

void BoardManager::removeDirectClientNetwork(const Socket directClientSocket)
{
    NETWORK_LOG("BoardManager::removeDirectClientNetwork");

    NETWORK_LOG("BoardManager::removeDirectClientNetwork: board list size in: ", _boards.size());
    beginResetModel();
    for (auto it = _boards.begin(); it != _boards.end();) {
        if (it->get()->getRootSocket() == directClientSocket) {
            _boards.erase(it);
        } else
            ++it;
    }
    endResetModel();
    NETWORK_LOG("BoardManager::removeDirectClientNetwork: Board list size out: ", _boards.size());
}

void BoardManager::removeInterfaceNetwork(const InterfaceIndex interfaceIndex)
{
    NETWORK_LOG("BoardManager::removeInterfaceNetwork");

    NETWORK_LOG("Removing interface network for index: ", interfaceIndex);

    for (auto &directClient : _clients) {
        if (directClient.interfaceIndex == interfaceIndex) {
            removeDirectClientNetwork(directClient.socket);
            closeSocket(directClient.socket);
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
