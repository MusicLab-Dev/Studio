/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Board
 */

#pragma once

#include <iostream>

#include <Core/MacroUtils.hpp>

#ifndef NETWORK_LOG_ENABLED
# define NETWORK_LOG_ENABLED false
#endif

#if NETWORK_LOG_ENABLED
# define NETWORK_LOG(...) _CONCATENATE(_NETWORK_LOG, VA_ARGC(__VA_ARGS__))(__VA_ARGS__)
# define _NETWORK_LOG1(a)                            std::cout << a << std::endl;
# define _NETWORK_LOG2(a, b)                         std::cout << a << b << std::endl;
# define _NETWORK_LOG3(a, b, c)                      std::cout << a << b << c << std::endl;
# define _NETWORK_LOG4(a, b, c, d)                   std::cout << a << b << c << d << std::endl;
# define _NETWORK_LOG5(a, b, c, d, e)                std::cout << a << b << c << d << e << std::endl;
# define _NETWORK_LOG6(a, b, c, d, e, f)             std::cout << a << b << c << d << e << f << std::endl;
# define _NETWORK_LOG7(a, b, c, d, e, f, g)          std::cout << a << b << c << d << e << f << g << std::endl;
# define _NETWORK_LOG8(a, b, c, d, e, f, g, h)       std::cout << a << b << c << d << e << f << g << h << std::endl;
#else
# define NETWORK_LOG(...)
#endif
