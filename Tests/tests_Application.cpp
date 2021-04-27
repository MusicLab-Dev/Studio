/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio tests
 */

#include <gtest/gtest.h>

#include <Studio/Application.hpp>

TEST(Application, InitDestroy)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler(Audio::ProjectPtr(std::make_shared<Audio::Project>("test")));

    ASSERT_NO_THROW(Application());
}