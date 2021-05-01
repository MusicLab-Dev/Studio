/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio tests
 */

#include <gtest/gtest.h>

#include <Studio/Scheduler.hpp>

TEST(Scheduler, InitDestroy)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    ASSERT_NO_THROW(Scheduler(Audio::ProjectPtr(std::make_shared<Audio::Project>("test"))));
}