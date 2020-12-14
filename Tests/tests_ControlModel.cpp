/**
 * @ Author: Cédric Lucchese
 * @ Description: InstancesModel tests
 */

#include <gtest/gtest.h>

#include <Studio/ControlModel.hpp>

TEST(ControlModel, InitDestroy)
{
    Audio::Control control {1, 2.0};

    ASSERT_NO_THROW(ControlModel tmp(&control));
}

TEST(ControlModel, AddAutomation)
{
    Audio::Control control {1, 2.0};

    ControlModel model(&control);
    model.add();
    ASSERT_EQ(model.count(), 1);
}

TEST(ControlModel, RemoveAutomation)
{
    Audio::Control control {1, 2.0};

    ControlModel model(&control);
    model.add();
    model.remove(0);
    ASSERT_EQ(model.count(), 0);
}

TEST(ControlModel, Muted)
{
    Audio::Control control {1, 2.0};

    ControlModel model(&control);
    model.setAutomationMutedState(0, false);
    ASSERT_EQ(model.isAutomationMuted(0), false);
    model.setAutomationMutedState(0, true);
    ASSERT_EQ(model.isAutomationMuted(0), true);
}

TEST(ControlModel, ParamId)
{
    Audio::Control control1 {1, 2.0};
    ControlModel model(&control1);

    ASSERT_EQ(model.paramID(), 1);

}

TEST(ControlModel, UpdateInternal)
{
    Audio::Control control1 {1, 2.0};
    Audio::Control control2 {2, 4.0};
    ControlModel model(&control1);

    model.updateInternal(&control2);

    ASSERT_EQ(model.paramID(), 2);
}