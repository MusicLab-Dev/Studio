/**
 * @ Author: Paul Creze
 * @ Description: Board
 */

#pragma once

#include <cstdint>
#include <string>
#include <cstring>

#ifdef WIN32

#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "iphlpapi.lib")

// Windows network headers
#include <winsock2.h>
#include <ws2tcpip.h>
#include <iphlpapi.h>

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
    using Port = std::uint16_t;
    using DataSize = std::int64_t;
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

using InterfaceIndex = unsigned int;

inline void printWindowsError(void)
{
    #ifdef WIN32
        wchar_t *s = nullptr;

        FormatMessageW(
            FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, 
            NULL,
            WSAGetLastError(),
            MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
            (LPWSTR)&s,
            0,
            NULL
        );
        fprintf(stderr, "%S\n", s);
        LocalFree(s);
    #endif
}

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
        sizeof(enable)
    );
    if (ret < 0) {
        closeSocket(socket);
        throw std::runtime_error(std::strerror(errno));
    }
}

inline void setSocketDevice(const Socket socket, const InterfaceIndex interfaceIndex)
{
    int ret = 0;

    #ifdef WIN32

    #else
        char name[IF_NAMESIZE];
        std::memset(&name, 0, IF_NAMESIZE);
        if_indextoname(interfaceIndex, name);
        std::string interfaceName(name);
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
        ret = ::bind(
            socket,
            reinterpret_cast<const sockaddr *>(&address),
            sizeof(address)
        );
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

inline void listenSocket(const Socket socket, int backLog)
{
    int ret = 0;

    #ifdef WIN32
        ret = ::listen(socket, backLog);
    #else
        ret = ::listen(socket, backLog);
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

inline DataSize recvSocket(const Socket socket, std::uint8_t *buffer, DataSize maxSize)
{
    DataSize ret = 0;

    #ifdef WIN32
        ret = ::recv(socket, reinterpret_cast<char *>(buffer), maxSize, 0);
    #else
        ret = ::recv(socket, buffer, maxSize, 0);
    #endif

    return ret;
}

inline DataSize sendSocket(const Socket socket, std::uint8_t *buffer, DataSize dataSize)
{
    DataSize ret = 0;

    #ifdef WIN32
        ret = ::send(socket, reinterpret_cast<char *>(buffer), dataSize, 0);
    #else
        ret = ::send(socket, buffer, dataSize, 0);
    #endif

    return ret;
}

inline DataSize sendToSocket(const Socket socket, NetworkAddress &address, std::uint8_t *buffer, DataSize dataSize)
{
    DataSize ret = 0;

    #ifdef WIN32
        ret = ::sendto(
            socket,
            reinterpret_cast<const char *>(buffer),
            dataSize,
            0,
            reinterpret_cast<sockaddr *>(&address),
            sizeof(address)
        );
    #else
        ret = ::sendto(
            socket,
            buffer,
            dataSize,
            0,
            reinterpret_cast<sockaddr *>(&address),
            sizeof(address)
        );
    #endif

    return ret;
}
