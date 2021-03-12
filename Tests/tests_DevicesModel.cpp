/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio tests
 */

#include <gtest/gtest.h>

#include <Studio/DevicesModel.hpp>

TEST(DevicesModel, InitDestroy)
{
    ASSERT_NO_THROW(DevicesModel());
}