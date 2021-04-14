/**
 * @ Author: Paul Creze
 * @ Description: Board
 */

#include <cstdint>

#ifdef WIN32
    using Socket = std::uint64_t;
    static constexpr Internal NullSock = ~0u;
    static constexpr std::int32_t SocketError = -1;
#else
    using Socket = int;
    static constexpr Socket NullSock = -1;
    static constexpr std::int32_t SocketError = -1;
#endif
    static constexpr std::int32_t DefaultBacklog = 3;
