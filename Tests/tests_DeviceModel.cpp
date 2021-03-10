/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio tests
 */

#include <gtest/gtest.h>

#include <Studio/DeviceModel.hpp>

TEST(DeviceModel, InitDestroy)
{
    ASSERT_NO_THROW(DeviceModel());
}