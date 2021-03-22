/**
 * @ Author: Cédric Lucchese
 * @ Description: InstancesModel tests
 */

#include <gtest/gtest.h>

#include <Studio/ControlsModel.hpp>
#include <Studio/Scheduler.hpp>

TEST(ControlsModel, InitDestroy)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Controls controls {};

    ASSERT_NO_THROW(ControlsModel tmp(&controls));
}

TEST(ControlsModel, AddRemoveControlCount)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Controls controls {};

    ControlsModel model(&controls);

    const int nb = 100;
    for (int i = 0; i < nb; i++) {
        ASSERT_NO_THROW(model.add(i));
        ASSERT_EQ(model.get(i)->paramID(), i);
        ASSERT_EQ(model.count(), i + 1);
    }
    for (int i = 99; i >= 0; i--) {
        ASSERT_NO_THROW(model.remove(0));
        ASSERT_EQ(model.count(), i);
    }
}

TEST(ControlsModel, MoveControl)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Controls controls {};

    ControlsModel model(&controls);

    model.add(10);
    model.add(12);
    model.move(0, 1);

    ASSERT_EQ(model.get(0)->paramID(), 12);
    ASSERT_EQ(model.get(1)->paramID(), 10);

    model.move(0, 0);

    ASSERT_EQ(model.get(0)->paramID(), 12);
    ASSERT_EQ(model.get(1)->paramID(), 10);
}