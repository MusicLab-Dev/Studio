/**
 * @ Author: Paul Creze
 * @ Description: Board
 */

#pragma once

// Qt headers
#include <QObject>
#include <QTimer>

// C++ standard library
#include <iostream>
#include <string>
#include <unordered_map>

// network headers
#include <unistd.h>
#include <fcntl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <netinet/tcp.h>
#include <net/if.h>

// Lexo headers
#include <Core/Vector.hpp>
#include <Protocol/Packet.hpp>
#include <Protocol/Protocol.hpp>
#include <Protocol/ConnectionProtocol.hpp>

#include "Board.hpp"

class BoardManager : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int tickRate READ tickRate WRITE setTickRate NOTIFY tickRateChanged)
    Q_PROPERTY(int discoverRate READ discoverRate WRITE setDiscoverRate NOTIFY discoverRateChanged)

public:
    /** @brief Enumeration of 'Board' roles */
    enum class Role {
        Instance = Qt::UserRole + 1,
        Size
    };

    static constexpr std::size_t NetworkBufferSize = 4096;

    using Vector = Core::Vector<std::uint8_t, std::uint16_t>;

    /** @brief Network buffer used to store direct client(s) inputs */
    class NetworkBuffer : public Vector
    {

        public:

            NetworkBuffer(std::size_t networkBufferSize) : Vector(networkBufferSize) {  }

            void setTransferSize(std::size_t size) noexcept { this->setSize(size); }

            void reset(void) noexcept
            {
                std::memset(data(), 0, capacity());
                setSize(0);
            }

        private:

    };

    using Interface = std::pair<int, int>;

    struct DirectClient
    {
        Socket socket { -1 };
        Interface *iface { nullptr };
    };

    BoardManager(void);
    ~BoardManager(void);

    /** @brief Names of 'Board' roles */
    [[nodiscard]] virtual QHash<int, QByteArray> roleNames(void) const override;

    /** @brief Get the number of connected boards */
    [[nodiscard]] virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /** @brief Query data from the board list */
    [[nodiscard]] virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;


    /** @brief Get / Set the tick rate property */
    [[nodiscard]] int tickRate(void) const noexcept { return _tickRate; }
    void setTickRate(const int value);

    /** @brief Get / Set the discover rate property */
    [[nodiscard]] int discoverRate(void) const noexcept { return _discoverRate; }
    void setDiscoverRate(const int value);

public slots:

signals:
    /** @brief Notify that the tick rate has changed */
    void tickRateChanged(void);

    /** @brief Notify that the discover rate has changed */
    void discoverRateChanged(void);

private:
    int _tickRate { 1000 };
    int _discoverRate { 1000 };
    QTimer _tickTimer {};
    QTimer _discoverTimer {};

    fd_set _readFds;
    int _maxFd { 0 };

    std::unordered_map<std::string, std::pair<int, int>> _interfaces {}; // [ interfaceName ] = { masterSocket, broadcastSocket }
    Core::TinyVector<DirectClient> _clients {};
    Core::Vector<std::shared_ptr<Board>, int> _boards {}; // TODO: Add allocator to _boards

    NetworkBuffer _networkBuffer;
    std::size_t _writeIndex { 0 };

    bool *_identifierTable { nullptr };

    /** @brief Remove the board network starting from the specified board ID */
    void removeNetworkFrom(const BoardID senderId, const BoardID targetId)
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
                board.reset();
                _boards.erase(&board);
            }
        }
    }

    /** @brief Remove a board network branch starting from his rooter board */
    void removeDirectClientNetwork(const Socket clientSocket)
    {
        // TO DO
    }

    /** @brief Callback when the tick rate changed */
    void onTickRateChanged(void);

    /** @brief Callback when the discover rate changed */
    void onDiscoverRateChanged(void);

    /** @brief Perform the tick process */
    void tick(void);

    /** @brief Perform the discover process */
    void discover(void);

    /** @brief Emit a DiscoveryPacket packet on every interface broadcast address */
    void discoveryEmit(void);

    // Interfaces utils

    /** @brief Create a TCP master socket for a specific interface */
    [[nodiscard]] Socket createTcpMasterSocket(const std::string &interfaceName, const std::string &localAddress);

    /** @brief Create an UDP broadcast socket for a specific interface */
    [[nodiscard]] Socket createUdpBroadcastSocket(const std::string &interfaceName, const std::string &broadcastAddress);

    /** @brief Scan and register new USB network interfaces */
    void processNewUsbInterfaces(const std::vector<std::tuple<std::string, std::string, std::string>> &usbInterfaces);

    /** @brief List available network interfaces with their broadcast address */
    [[nodiscard]] std::vector<std::tuple<std::string, std::string, std::string>> getUsbNetworkInterfaces(void);

    // Connections utils

    /** @brief Prepare direct clients socket for the select() call */
    void prepareSockets(void);

    /** @brief Accept new incomming board connections & add them to the client list */
    void processNewConnections(void);

    /** @brief Read client's pending data and place it into the network buffer (& handle disconnection) */
    void processClientInput(const Socket clientSocket);

    /** @brief Scan for a read operation available on every direct clients */
    void processDirectClients(void);

    // Identifiers utils

    /** @brief Acquire a free identifier for a newly connected board */
    [[nodiscard]] BoardID aquireIdentifier(void) noexcept;

    /** @brief Release an acquired identifier, it will be assignable again */
    void releaseIdentifier(const BoardID identifier) noexcept { _identifierTable[identifier] = false; };

    // Sockets utils

    /** @brief Set socket to be in non-blocking mode */
    void setSocketNonBlocking(const Socket socket) { ::fcntl(socket, F_SETFL, O_NONBLOCK); };

    /** @brief Set keepalive option on socket */
    void setSocketKeepAlive(const Socket socket);
};
