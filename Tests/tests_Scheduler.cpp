/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio tests
 */

#include <gtest/gtest.h>

#include <Studio/Application.hpp>

TEST(Scheduler, InitDestroy)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Application app;
}