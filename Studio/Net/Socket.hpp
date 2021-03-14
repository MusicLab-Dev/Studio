/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Simple socket abstraction
 */

#pragma once

#include <string>

namespace Net
{
    enum class Protocol {
        TCP = 0,
        UDP
    };

    class Socket;

    /** @brief Guard initializer */
    struct Initializer;

    using Address = std::uint32_t;
    using Port = std::uint16_t;

    /** @brief Gets an address out of string */
    [[nodiscard]] Address ToAddress(const char *addr) noexcept;
}

class Net::Socket
{
public:
#ifdef WIN32
    using Internal = std::uint64_t;
    static constexpr Internal NullSock = ~0u;
    static constexpr std::int32_t SocketError = -1;
#else
    using Internal = int;
    static constexpr Internal NullSock = -1;
    static constexpr std::int32_t SocketError = -1;
#endif
    static constexpr std::int32_t DefaultBacklog = 3;

    /** @brief Initialize backend library */
    static void Initialize(void);

    /** @brief Release backend library */
    static void Release(void);

    /** @brief Construct a new null socket */
    Socket(void) noexcept = default;

    /** @brief Copy construct is disabled */
    Socket(const Socket &other) = delete;

    /** @brief Move construct a socket */
    Socket(Socket &&other) noexcept { std::swap(_sock, other._sock); }

    /** @brief Take ownership of given socket */
    Socket(Internal sock) noexcept : _sock(sock) {}

    /** @brief Destroys the socket */
    ~Socket(void) noexcept { close(); }

    /** @brief Tries to connect socket to given endpoint */
    [[nodiscard]] bool connectTo(const Address address, const Port port, const Protocol protocol = Protocol::TCP);

    /** @brief Listen on given endpoint */
    void listenAt(const Address address, const Port port, const std::int32_t backlog = DefaultBacklog);

    /** @brief Accept a connection */
    [[nodiscard]] Socket accept(void) noexcept;

    /** @brief Accept a connection and get its endpoint */
    [[nodiscard]] Socket acceptFrom(Address &address, Port &port) noexcept;

    /** @brief Disconnect and closes the socket from host */
    void disconnectFromHost(void) noexcept;

    /** @brief Open a socket with a given protocol */
    void open(const Protocol protocol);

    /** @brief Close socket if opened */
    void close(void) noexcept;

    /** @brief Shutdown a socket */
    bool shutdown(void) noexcept;

    /** @brief Bind an opened socket to a specific address */
    void bind(const Address address, const Port port);

    /** @brief Send a packet to connected endpoint */
    [[nodiscard]] std::int32_t send(const void *buffer, const std::int32_t size, const bool sendAll = false) noexcept;

    /** Send a packet to given endpoint */
    [[nodiscard]] std::int32_t sendTo(const void *buffer, const std::int32_t size, const Address address, const Port port, const bool sendAll = false) noexcept;

    /** Received data from connected enpoint */
    [[nodiscard]] std::int32_t receive(void *buffer, const std::int32_t maxSize, const bool receiveAll = false) noexcept;

    /** Received data and get its enpoint */
    [[nodiscard]] std::int32_t receiveFrom(void *buffer, const std::int32_t maxSize, Address &address, Port &port, const bool receiveAll = false) noexcept;

    /** @brief Check if socket is opened */
    operator bool(void) const noexcept { return isOpened(); }

    /** @brief Check if socket is opened */
    [[nodiscard]] bool isOpened(void) const noexcept { return _sock != NullSock; }

private:
    Internal _sock { NullSock };

    /** @brief Gets an internal well formated error message */
    [[nodiscard]] std::string getSocketError(const char *context, const std::string &msg, const bool useErrno = false) const noexcept;
};

struct Net::Initializer
{
    Initializer(void) { Socket::Initialize(); }
    ~Initializer(void) { Socket::Release(); }
};

/* Socket must be cheap and small ! */
static_assert(sizeof(Net::Socket) == sizeof(Net::Socket::Internal));

#include "Socket.ipp"