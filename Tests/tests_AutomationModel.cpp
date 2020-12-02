/**
 * @ Author: Cédric Lucchese
 * @ Description: InstancesModel tests
 */

#include <gtest/gtest.h>

#include <Studio/AutomationModel.hpp>
#include <Studio/Point.hpp>

TEST(AutomationModel, InitDestroy)
{
    Audio::Automation automation {};

    ASSERT_NO_THROW(AutomationModel tmp(&automation));
}

TEST(AutomationModel, InitWithValueDestroy)
{
    Audio::Automation automation {};
    automation.instances().push<Audio::BeatRange>({1, 2});

    AutomationModel tmp(&automation);

    ASSERT_EQ(tmp.instances().get()->get(0).from, 1);
    ASSERT_EQ(tmp.instances().get()->get(0).to, 2);
}

TEST(AutomationModel, UpdateInternal)
{
    Audio::Automation automation1 {};
    Audio::Automation automation2 {};

    automation1.instances().push<Audio::BeatRange>({1, 2});
    automation2.instances().push<Audio::BeatRange>({3, 4});

    AutomationModel model(&automation1);
    ASSERT_EQ(model.instances().get()->get(0).from, 1);
    ASSERT_EQ(model.instances().get()->get(0).to, 2);

    model.updateInternal(&automation2);
    ASSERT_EQ(model.instances().get()->get(0).from, 3);
    ASSERT_EQ(model.instances().get()->get(0).to, 4);
}

TEST(AutomationModel, AddPoint)
{
    Audio::Automation automation {};

    AutomationModel model(&automation);

    Point point;
    point.beat = 4;
    point.curveRate = 2;

    model.add(point);

    ASSERT_EQ(model.count(), 1);
    ASSERT_EQ(model.get(1).beat, 4);
    ASSERT_EQ(model.get(1).curveRate, 2);
}