/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Board
 */

#pragma once

#include <iostream>

#include <Core/MacroUtils.hpp>

#ifndef NETWORK_LOG_ENABLED
# define NETWORK_LOG_ENABLED true
#endif

#if NETWORK_LOG_ENABLED
# define NETWORK_LOG(...) _CONCATENATE(NETWORK_LOG, VA_ARGC(__VA_ARGS__))(__VA_ARGS__)
# define NETWORK_LOG1(a)                std::cout << a << std::endl;
# define NETWORK_LOG2(a, b)             std::cout << a << b << std::endl;
# define NETWORK_LOG3(a, b, c)          std::cout << a << b << c << std::endl;
# define NETWORK_LOG4(a, b, c, d)       std::cout << a << b << c << d << std::endl;
# define NETWORK_LOG5(a, b, c, d, e)    std::cout << a << b << c << d << e << std::endl;
#else
# define NETWORK_LOG(...)
#endif

// Automatically give names to a list of up to 16 arguments
// #define RSHIFT_EACH(what, ...)         _RSHIFT_EACH(VA_ARGC(__VA_ARGS__), what, __VA_ARGS__)
// #define _RSHIFT_EACH(N, what, ...)     _CONCATENATE(_RSHIFT_EACH_, N)(what __VA_OPT__(,) __VA_ARGS__)
// #define _RSHIFT_EACH_0(what)
// #define _RSHIFT_EACH_1(what, x)        << x
// #define _RSHIFT_EACH_2(what, x, ...)   << x _RSHIFT_EACH_1(what,  __VA_ARGS__)
// #define _RSHIFT_EACH_3(what, x, ...)   << x _RSHIFT_EACH_2(what,  __VA_ARGS__)
// #define _RSHIFT_EACH_4(what, x, ...)   << x _RSHIFT_EACH_3(what,  __VA_ARGS__)
// #define _RSHIFT_EACH_5(what, x, ...)   << x _RSHIFT_EACH_4(what,  __VA_ARGS__)
// #define _RSHIFT_EACH_6(what, x, ...)   << x _RSHIFT_EACH_5(what,  __VA_ARGS__)
// #define _RSHIFT_EACH_7(what, x, ...)   << x _RSHIFT_EACH_6(what,  __VA_ARGS__)
// #define _RSHIFT_EACH_8(what, x, ...)   << x _RSHIFT_EACH_7(what,  __VA_ARGS__)
// #define _RSHIFT_EACH_9(what, x, ...)   << x _RSHIFT_EACH_8(what,  __VA_ARGS__)
// #define _RSHIFT_EACH_10(what, x, ...)  << x _RSHIFT_EACH_9(what,  __VA_ARGS__)
// #define _RSHIFT_EACH_11(what, x, ...)  << x _RSHIFT_EACH_10(what, __VA_ARGS__)
// #define _RSHIFT_EACH_12(what, x, ...)  << x _RSHIFT_EACH_11(what, __VA_ARGS__)
// #define _RSHIFT_EACH_13(what, x, ...)  << x _RSHIFT_EACH_12(what, __VA_ARGS__)
// #define _RSHIFT_EACH_14(what, x, ...)  << x _RSHIFT_EACH_13(what, __VA_ARGS__)
// #define _RSHIFT_EACH_15(what, x, ...)  << x _RSHIFT_EACH_14(what, __VA_ARGS__)
// #define _RSHIFT_EACH_16(what, x, ...)  << x _RSHIFT_EACH_15(what, __VA_ARGS__)