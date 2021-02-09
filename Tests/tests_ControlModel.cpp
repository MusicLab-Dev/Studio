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


TEST(ControlModel, AddRemoveAutomation)
{
    Audio::Control control {1, 2.0};

    ControlModel model(&control);
    for (int i = 0; i < 100; i++) {
        model.add();
        ASSERT_EQ(model.count(), i + 1);
    }
    for (int i = 99; i > 0; i--) {
        model.remove(0);
        ASSERT_EQ(model.count(), i);
    }
}


TEST(ControlModel, Muted)
{
    Audio::Control control(1, 2.0);

    ControlModel model(&control);
    model.add();

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
    model.updateInternal(&control1);
    ASSERT_EQ(model.paramID(), 1);
}