/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio tests
 */

#include <gtest/gtest.h>

#include <Studio/Application.hpp>

TEST(Application, InitDestroy)
{
    ASSERT_NO_THROW(Application());
}