/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio tests
 */

#include <gtest/gtest.h>

#include <Studio/Scheduler.hpp>

TEST(Scheduler, InitDestroy)
{
    ASSERT_NO_THROW(Scheduler());
}