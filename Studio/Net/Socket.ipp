/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Simple socket abstraction
 */


inline Net::Socket Net::Socket::accept(void) noexcept
{
    Address address = 0;
    Port port = 0;

    return acceptFrom(address, port);
}

inline void Net::Socket::disconnectFromHost(void) noexcept
{
    shutdown();
    close();
}