/**
 * @ Author: Paul Creze
 * @ Description: Board
 */

#pragma once

#include <QObject>
#include <QTimer>

#include <iostream>
#include <cstring>

#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>

#include <Core/Vector.hpp>
#include <Protocol/Packet.hpp>
#include <Protocol/Protocol.hpp>

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
    Core::Vector<std::unique_ptr<Board>, int> _boards {}; // TODO: Add allocator to _boards
    Core::TinyVector<Net::Socket> _clients {};
    Net::Socket _listenSocket {};
    int _tickRate { 1000 };
    int _discoverRate { 1000 };
    QTimer _tickTimer {};
    QTimer _discoverTimer {};

    int _udpBroadcastSocket { -1 };
    int _tcpMasterSocket { -1 };

    fd_set _readFds;
    int _maxFd { 0 };

    NetworkBuffer _networkBuffer;
    std::size_t _writeIndex { 0 };

    /** @brief Callback when the tick rate changed */
    void onTickRateChanged(void);

    /** @brief Callback when the discover rate changed */
    void onDiscoverRateChanged(void);


    /** @brief Perform the tick process */
    void tick(void);

    /** @brief Perform the discover process */
    void discover(void);

    /** @brief Init the UDP broadcast socket */
    void initUdpBroadcastSocket(void);

    /** @brief Init the TCP master socket */
    void initTcpMasterSocket(void);

    /** @brief Emit a DiscoveryPacket packet on the UDP broadcast address */
    void discoveryEmit(void);

    /** @brief Accept new incomming board connections & add them to the client list */
    void processNewConnections(void);

    /** @brief Prepare direct clients socket for the select() call */
    void prepareSockets(void);

    /** @brief Scan for a read operation available on every direct clients */
    void processDirectClients(void);

    /** @brief Read client's pending data and place it into the network buffer (& handle disconnection) */
    void processClientInput(Net::Socket *clientSocket);

    /** @brief Remove a board network branch starting from his rooter board */
    void removeDirectClientNetwork(const Net::Socket &clientSocket);

    // std::unique_ptr<Board> *getBoardFromSocket(const Net::Socket &clientSocket);
};
