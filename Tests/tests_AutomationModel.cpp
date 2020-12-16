/**
 * @ Author: Cédric Lucchese
 * @ Description: AutomationModel tests
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
    Audio::Automation automation {};

    AutomationModel model(&automation);

    GPoint point;

    model.add(point);
    model.remove(0);

    ASSERT_EQ(model.count(), 0);
}

TEST(AutomationModel, SetPoint)
{
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