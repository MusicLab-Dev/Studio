/**
 * @ Author: Cédric Lucchese
 * @ Description: InstancesModel tests
 */

#include <gtest/gtest.h>

#include <Studio/ControlModel.hpp>
#include <Studio/Scheduler.hpp>
#include <Studio/Point.hpp>

TEST(ControlModel, InitDestroy)
{
    Audio::Control control { 1 };

    ASSERT_NO_THROW(ControlModel tmp(&control));
}


TEST(ControlModel, AddRemoveAutomation)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;

    Audio::Control control { 1 };

    ControlModel model(&control);
    for (int i = 0; i < 100; ++i) {
        model.add();
        ASSERT_EQ(model.count(), i + 1);
    }
    for (int i = 99; i > 0; --i) {
        model.remove(0);
        ASSERT_EQ(model.count(), i);
    }
}
#include <QDebug>
TEST(ControlModel, MoveAutomation)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;

    Audio::Control control { 1 };

    ControlModel model(&control);
    model.add();
    model.get(0)->setName("0");
    model.add();
    model.get(1)->setName("1");
    model.move(0, 1);
    ASSERT_EQ(model.get(0)->name(), "1");
    ASSERT_EQ(model.get(1)->name(), "0");
    model.move(0, 0);
    ASSERT_EQ(model.get(0)->name(), "1");
    ASSERT_EQ(model.get(1)->name(), "0");
}

TEST(ControlModel, ParamId)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Control control1 { 1 };

    ControlModel model(&control1);

    ASSERT_EQ(model.paramID(), 1);
    model.setParamID(3);
    ASSERT_EQ(model.paramID(), 3);
}

TEST(ControlModel, UpdateInternal)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Control control1 { 1 };
    Audio::Control control2 { 2 };

    ControlModel model(&control1);

    model.updateInternal(&control2);
    ASSERT_EQ(model.paramID(), 2);
    model.updateInternal(&control1);
    ASSERT_EQ(model.paramID(), 1);
}

TEST(ControlModel, Muted)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Control control1 {1, 2.0};

    ControlModel model(&control1);
    model.setMuted(false);
    ASSERT_EQ(model.muted(), false);
    model.setMuted(true);
    ASSERT_EQ(model.muted(), true);
}

TEST(ControlModel, ManualMode)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Control control1 {1, 2.0};

    ControlModel model(&control1);
    model.setManualMode(false);
    ASSERT_EQ(model.manualMode(), false);
    model.setManualMode(true);
    ASSERT_EQ(model.manualMode(), true);
}

TEST(ControlModel, ManualPoint)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Control control {1, 2.0};

    ControlModel model(&control);

    GPoint point;
    point.beat = 4;
    point.curveRate = 2;

    model.setManualPoint(point);
    ASSERT_EQ(model.manualPoint().beat, point.beat);
    ASSERT_EQ(model.manualPoint().curveRate, point.curveRate);
}