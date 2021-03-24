/**
 * @ Author: Cédric Lucchese
 * @ Description: AutomationModel tests
 */

#include <gtest/gtest.h>

#include <Studio/AutomationModel.hpp>
#include <Studio/Scheduler.hpp>
#include <Studio/Point.hpp>
#include <Studio/Scheduler.hpp>

TEST(AutomationModel, InitDestroy)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Automation automation {};

    ASSERT_NO_THROW(AutomationModel tmp(&automation));
}

TEST(AutomationModel, InitWithValueDestroy)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Automation automation {};
    automation.instances().push<Audio::BeatRange>({1, 2});

    AutomationModel tmp(&automation);

    ASSERT_EQ(tmp.instances().get(0).from, 1);
    ASSERT_EQ(tmp.instances().get(0).to, 2);
}

TEST(AutomationModel, UpdateInternal)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Automation automation1 {};
    Audio::Automation automation2 {};

    automation1.instances().push<Audio::BeatRange>({1, 2});
    automation2.instances().push<Audio::BeatRange>({3, 4});

    AutomationModel model(&automation1);
    ASSERT_EQ(model.instances().get(0).from, 1);
    ASSERT_EQ(model.instances().get(0).to, 2);

    model.updateInternal(&automation2);
    ASSERT_EQ(model.instances().get(0).from, 3);
    ASSERT_EQ(model.instances().get(0).to, 4);
}

TEST(AutomationModel, AddPoint)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Automation automation {};

    AutomationModel model(&automation);

    GPoint point;
    point.beat = 4;
    point.curveRate = 2;

    model.add(point);

    ASSERT_EQ(model.count(), 1);
    ASSERT_EQ(model.get(0).beat, 4);
    ASSERT_EQ(model.get(0).curveRate, 2);
}

TEST(AutomationModel, Count)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Automation automation {};

    AutomationModel model(&automation);

    GPoint point;
    point.beat = 4;
    point.curveRate = 2;

    model.add(point);
    model.add(point);
    model.add(point);

    ASSERT_EQ(model.count(), 3);
}

TEST(AutomationModel, RemovePoint)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Automation automation {};

    AutomationModel model(&automation);

    GPoint point;

    model.add(point);
    model.remove(0);

    ASSERT_EQ(model.count(), 0);
}

TEST(AutomationModel, InstancesAddRemoveBasics)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;

    Audio::Automation automation {};

    AutomationModel model(&automation);
    auto &instances = model.instances();

    instances.add(BeatRange(1u, 1u));
    ASSERT_EQ(instances.get(0).from, 1); ASSERT_EQ(instances.get(0).to, 1);
    ASSERT_EQ(instances.count(), 1);

    instances.add(BeatRange(2u, 2u));
    ASSERT_EQ(instances.get(0).from, 1); ASSERT_EQ(instances.get(0).to, 1);
    ASSERT_EQ(instances.get(1).from, 2); ASSERT_EQ(instances.get(1).to, 2);
    ASSERT_EQ(instances.count(), 2);

    instances.add(BeatRange(3u, 3u));
    ASSERT_EQ(instances.get(0).from, 1); ASSERT_EQ(instances.get(0).to, 1);
    ASSERT_EQ(instances.get(1).from, 2); ASSERT_EQ(instances.get(1).to, 2);
    ASSERT_EQ(instances.get(2).from, 3); ASSERT_EQ(instances.get(2).to, 3);
    ASSERT_EQ(instances.count(), 3);

    instances.remove(1);
    ASSERT_EQ(instances.get(0).from, 1); ASSERT_EQ(instances.get(0).to, 1);
    ASSERT_EQ(instances.get(1).from, 3); ASSERT_EQ(instances.get(1).to, 3);
    ASSERT_EQ(instances.count(), 2);

    instances.remove(1);
    ASSERT_EQ(instances.get(0).from, 1); ASSERT_EQ(instances.get(0).to, 1);
    ASSERT_EQ(instances.count(), 1);

    instances.remove(0);
    ASSERT_EQ(instances.count(), 0);
}

TEST(AutomationModel, SetPoint)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Automation automation {};

    AutomationModel model(&automation);

    GPoint point1;
    point1.beat = 4;
    point1.curveRate = 2;

    GPoint point2;
    point2.beat = 6;
    point2.curveRate = 7;

    model.add(point1);

    ASSERT_NO_THROW(model.set(0, point2));
    ASSERT_EQ(model.get(0).beat, 6);
    ASSERT_EQ(model.get(0).curveRate, 7);
}

TEST(AutomationModel, Muted)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;
    Audio::Automation automation {};

    AutomationModel model(&automation);

    model.setMuted(false);
    ASSERT_EQ(model.muted(), false);
    model.setMuted(true);
    ASSERT_EQ(model.muted(), true);
}