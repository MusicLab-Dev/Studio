/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio tests
 */

#include <gtest/gtest.h>

#include <Studio/Device.hpp>

TEST(Device, InitDestroy)
{
    ASSERT_NO_THROW(Device());
}