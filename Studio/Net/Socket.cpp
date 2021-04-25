/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Simple socket abstraction
 */

#include <stdexcept>

#include "Socket.hpp"

#ifdef _WIN32
    # include <WinSock2.h>
    # define SHUT_RD SD_RECEIVE
    # define SHUT_WR SD_SEND
    # define SHUT_RDWR SD_BOTH

#pragma comment(lib, "Ws2_32.lib")

    using Socklen = int;
    using SockAddrIn = SOCKADDR_IN;
    using SockAddr = SOCKADDR;
    using InAddr = IN_ADDR;
#else
    extern "C" {
    # include <sys/types.h>
    # include <sys/socket.h>
    # include <netinet/in.h>
    # include <arpa/inet.h>
    # include <unistd.h>
    }
    # include <string.h>
    using Socklen = socklen_t;
    using SockAddrIn = struct sockaddr_in;
    using SockAddr = struct sockaddr;
    using InAddr = struct in_addr;
    typedef struct sockaddr_in SOCKADDR_IN;
#endif

using namespace Net;

static SockAddrIn GetAddrIn(const Address address, const std::uint16_t port) noexcept
{
    SockAddrIn sin;

    sin.sin_addr.s_addr = address;
    sin.sin_family = AF_INET;
    sin.sin_port = htons(port);
    return sin;
}

Address Net::ToAddress(const char *addr) noexcept
{
    return ::inet_addr(addr);
}

void SocketBase::Initialize(void)
{
#ifdef _WIN32
    WSADATA wsa;
    if (auto res = WSAStartup(MAKEWORD(2, 2), &wsa); res < 0)
        throw std::runtime_error(Socket().getSocketError("Initialize", "WSAStartup failed with error " + std::to_string(res)));
#endif
}

void SocketBase::Release(void)
{
#ifdef _WIN32
    WSACleanup();
#endif
}

std::int32_t SocketBase::send(const void *buffer, const std::int32_t size, const bool sendAll) noexcept
{
    std::int32_t written = 0, sent = 0;

    written = ::send(_sock, reinterpret_cast<const char *>(buffer), size, 0);
    if (!sendAll || size == written)
        return written;
    while (written < size) {
        if (sent = ::send(_sock, reinterpret_cast<const char *>(buffer) + written, size - written, 0); !sent)
            break;
        else
            written += sent;
    }
    return written;
}

std::int32_t SocketBase::sendTo(const void *buffer, const std::int32_t size, const Address address, const Port port, const bool sendAll) noexcept
{
    auto sin = GetAddrIn(address, port);
    std::int32_t written = 0, sent = 0;

    written = ::sendto(_sock, reinterpret_cast<const char *>(buffer), size, 0, reinterpret_cast<SockAddr *>(&sin), sizeof(sin));
    if (!sendAll || size == written)
        return written;
    while (written < size) {
        if (sent = ::sendto(_sock, reinterpret_cast<const char *>(buffer) + written, size - written, 0, reinterpret_cast<SockAddr *>(&sin), sizeof(sin)); !sent)
           break;
        else
           written += sent;
    }
    return written;
}

std::int32_t SocketBase::receive(void *buffer, const std::int32_t maxSize, const bool receiveAll) noexcept
{
    return ::recv(_sock, reinterpret_cast<char *>(buffer), maxSize, receiveAll ? MSG_WAITALL : 0);
}

std::int32_t SocketBase::receiveFrom(void *buffer, const std::int32_t maxSize, Address &address, Port &port, const bool receiveAll) noexcept
{
    SockAddrIn sin;
    Socklen len = sizeof(&sin);
    auto size = ::recvfrom(_sock, reinterpret_cast<char *>(buffer), maxSize, receiveAll ? MSG_WAITALL : 0, reinterpret_cast<SockAddr *>(&sin), &len);

    address = htonl(sin.sin_addr.s_addr);
    port = htons(sin.sin_port);
    return size;
}

std::string SocketBase::getSocketError(const char *context, const std::string &msg, const bool useErrno) const noexcept
{
    auto str = std::string("Socket::") + context + ": " + msg;

    if (!useErrno)
        return str;
#ifdef _WIN32
    char err[96] { 0 };
    FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                   nullptr, static_cast<DWORD>(WSAGetLastError()),
                   MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                   err, sizeof(err), nullptr);
    str += std::string("\n\t") + err;
#else
    str += "\n\t'";
    str += ::strerror(errno);
    str += '\'';
#endif
    return str;
}


bool Socket::connectTo(const Address address, const Port port, const Protocol protocol)
{
    auto sin = GetAddrIn(address, port);

    open(protocol);
    if (connect(_sock, reinterpret_cast<SockAddr *>(&sin), sizeof(sin)) != SocketError)
        return true;
    close();
    return false;
}

void Socket::listenAt(const Address address, const Port port, const std::int32_t backlog)
{
    if (!isOpened())
        open(Protocol::TCP);
    bind(address, port);
    if (::listen(_sock, backlog) == SocketError)
        throw std::runtime_error(getSocketError("listenAt", "Couldn't start listening", true));
}

Socket Socket::acceptFrom(Address &address, Port &port) noexcept
{
    SockAddrIn sin;
    Socklen len = sizeof(sin);
    auto sock = Socket { ::accept(_sock, reinterpret_cast<SockAddr *>(&sin), &len) };

    if (!sock)
        return sock;
    address = ::ntohl(sin.sin_addr.s_addr);
    port = ::ntohs(sin.sin_port);
    return sock;
}

void Socket::open(const Protocol protocol)
{
    if (isOpened())
        close();
    _sock = socket(
        AF_INET,
        protocol == Protocol::TCP ? SOCK_STREAM : SOCK_DGRAM,
        0
    );
    if (!isOpened())
        throw std::runtime_error(getSocketError("open", "Couldn't open socket", true));
    if (char flags = 1; ::setsockopt(_sock, SOL_SOCKET, SO_REUSEADDR, &flags, sizeof(flags)) == SocketError)
        throw std::runtime_error(getSocketError("open", "Couldn't set socket flags", true));
}

void Socket::close(void) noexcept
{
    if (!isOpened())
        return;
#ifdef _WIN32
    ::closesocket(_sock);
#else
    ::close(_sock);
#endif
}

bool Socket::shutdown(void) noexcept
{
    if (!isOpened())
        return false;
    return !::shutdown(_sock, SHUT_RDWR);
}

void Socket::bind(const Address address, const Port port)
{
    auto sin = GetAddrIn(address, port);

    if (::bind(_sock, reinterpret_cast<SockAddr *>(&sin), sizeof(sin)) == SocketError)
        throw std::runtime_error(getSocketError("listenAt", "Couldn't bind socket", true));
}
