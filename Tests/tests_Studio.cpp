/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio tests
 */

#include <gtest/gtest.h>

#include <Studio/Studio.hpp>

TEST(Studio, InitDestroy)
{
    ASSERT_NO_THROW(Studio());
}