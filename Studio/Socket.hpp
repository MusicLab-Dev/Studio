/**
 * @ Author: Paul Creze
 * @ Description: Board
 */

#pragma once

#include <cstdint>
#include <string>
#include <cstring>

#ifdef WIN32

#pragma comment(lib, "Ws2_32.lib")

// Windows network headers
#include <winsock2.h>
#include <WS2tcpip.h>

#else

// Linux network headers
#include <unistd.h>
#include <fcntl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <netinet/tcp.h>
#include <net/if.h>

#endif

#ifdef WIN32
    using Socket = std::int64_t;
    static constexpr std::int64_t NullSock = ~0u;
    static constexpr std::int32_t SocketError = -1;

    using Socklen = int;
    using NetworkAddress = sockaddr_in;
#else
    using Socket = int;
    static constexpr Socket NullSock = -1;
    static constexpr std::int32_t SocketError = -1;

    using Socklen = socklen_t;
    using NetworkAddress = sockaddr_in;
    using Port = std::uint16_t;
    using DataSize = std::int64_t;
#endif
    static constexpr std::int32_t DefaultBacklog = 3;

inline void closeSocket(const Socket socket)
{
    #ifdef WIN32
        ::closesocket(socket);
    #else
        ::close(socket);
    #endif
}

inline void setSocketReusable(const Socket socket)
{
    const char enable = 1;
    const int ret = ::setsockopt(
        socket,
        SOL_SOCKET,
        SO_REUSEADDR,
        &enable,
        sizeof(int)
    );
    if (ret < 0) {
        closeSocket(socket);
        throw std::runtime_error(std::strerror(errno));
    }
}

inline void setSocketDevice(const Socket socket, const std::string &interfaceName)
{
    int ret = 0;

    #ifdef WIN32
//        ret = ::setsockopt(
//            socket,
//            SOL_SOCKET,
//            SO_BINDTODEVICE,
//            interfaceName.c_str(),
//            interfaceName.length()
//        );
    #else
        ret = ::setsockopt(
            socket,
            SOL_SOCKET,
            SO_BINDTODEVICE,
            interfaceName.c_str(),
            static_cast<Socklen>(interfaceName.length())
        );
    #endif
    if (ret < 0) {
        closeSocket(socket);
        throw std::runtime_error(std::strerror(errno));
    }
}

inline void bindSocket(const Socket socket, const NetworkAddress &address)
{
    int ret = 0;

    #ifdef WIN32

    #else
        ret = ::bind(
            socket,
            reinterpret_cast<const sockaddr *>(&address),
            sizeof(address)
        );
    #endif
    if (ret < 0) {
        closeSocket(socket);
        throw std::runtime_error(std::strerror(errno));
    }
}

inline void listenSocket(const Socket socket)
{
    int ret = 0;

    #ifdef WIN32
        ret = ::listen(socket, 1);
    #else
        ret = ::listen(socket, 1);
    #endif
    if (ret < 0) {
        closeSocket(socket);
        throw std::runtime_error(std::strerror(errno));
    }
}

inline NetworkAddress createNetworkAddress(const Port port, const std::string &address)
{
    NetworkAddress tcpAddress;

    #ifdef WIN32
        tcpAddress.sin_family = AF_INET;
        tcpAddress.sin_port = ::htons(port);
        tcpAddress.sin_addr.s_addr = ::inet_addr(address.c_str());
    #else
        tcpAddress.sin_family = AF_INET;
        tcpAddress.sin_port = ::htons(port);
        tcpAddress.sin_addr.s_addr = ::inet_addr(address.c_str());
    #endif

    return tcpAddress;
}

inline void enableSocketBroadcast(const Socket socket)
{
    int ret = 0;

    #ifdef WIN32
        const char broadcast = 1;
        ret = ::setsockopt(
            socket,
            SOL_SOCKET,
            SO_BROADCAST,
            &broadcast,
            sizeof(broadcast)
        );
    #else
        int broadcast = 1;
        ret = ::setsockopt(
            socket,
            SOL_SOCKET,
            SO_BROADCAST,
            &broadcast,
            sizeof(broadcast)
        );
    #endif
    if (ret < 0) {
        closeSocket(socket);
        throw std::runtime_error(std::strerror(errno));
    }
}

inline void setSocketNonBlocking(const Socket socket)
{
    #ifdef WIN32
        u_long iMode = 1;
        ::ioctlsocket(socket, FIONBIO, &iMode);
    #else
        ::fcntl(socket, F_SETFL, O_NONBLOCK);
    #endif
}

inline void setSocketKeepAlive(const Socket socket)
{
    #ifdef WIN32
        const char enable = 1;
        const char idle = 3;
        const char interval = 3;
        const char maxpkt = 1;
    #else
        int enable = 1;
        int idle = 3;
        int interval = 3;
        int maxpkt = 1;
    #endif

    ::setsockopt(socket, SOL_SOCKET, SO_KEEPALIVE, &enable, sizeof(int));
    ::setsockopt(socket, IPPROTO_TCP, TCP_KEEPIDLE, &idle, sizeof(int));
    ::setsockopt(socket, IPPROTO_TCP, TCP_KEEPINTVL, &interval, sizeof(int));
    ::setsockopt(socket, IPPROTO_TCP, TCP_KEEPCNT, &maxpkt, sizeof(int));
}

inline DataSize recvSocket(const Socket socket, std::uint8_t *buffer, DataSize size)
{
    DataSize ret = 0;

    #ifdef WIN32
        ret = ::recv(socket, reinterpret_cast<char *>(buffer), size, 0);
    #else
        ret = ::recv(socket, buffer, size, 0);
    #endif

    return ret;
}

inline DataSize sendSocket(const Socket socket, std::uint8_t *buffer, DataSize size)
{
    DataSize ret = 0;

    #ifdef WIN32
        ret = ::send(socket, reinterpret_cast<char *>(&buffer), size, 0);
    #else
        ret = ::send(socket, &buffer, size, 0);
    #endif

    return ret;
}

inline DataSize sendToSocket(const Socket socket, NetworkAddress &address, std::uint8_t *buffer, DataSize size)
{
    DataSize ret = 0;

    #ifdef WIN32
        ret = ::sendto(
            socket,
            reinterpret_cast<const char *>(buffer),
            size,
            0,
            reinterpret_cast<sockaddr *>(&address),
            sizeof(address)
        );
    #else
        ret = ::sendto(
            socket,
            buffer,
            size,
            0,
            reinterpret_cast<sockaddr *>(&address),
            sizeof(address)
        );
    #endif

    return ret;
}
