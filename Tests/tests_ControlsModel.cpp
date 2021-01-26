/**
 * @ Author: Cédric Lucchese
 * @ Description: InstancesModel tests
 */

#include <gtest/gtest.h>

#include <Studio/ControlsModel.hpp>

TEST(ControlsModel, InitDestroy)
{
    Audio::Controls controls {};

    ASSERT_NO_THROW(ControlsModel tmp(&controls));
}

TEST(ControlsModel, AddControlCount)
{
    Audio::Controls controls {};

    ControlsModel model(&controls);

    const int nb = 10;
    for (int i = 0; i < nb; i++) {
        ASSERT_NO_THROW(model.add(i));
        ASSERT_EQ(model.get(i)->paramID(), i);
        ASSERT_EQ(model.count(), i + 1);
    }

}

TEST(ControlsModel, RemoveControl)
{
    Audio::Controls controls {};

    ControlsModel model(&controls);

    model.add(10);

    ASSERT_EQ(model.count(), 1);
    model.remove(0);
    ASSERT_EQ(model.count(), 0);
}

TEST(ControlsModel, MoveControl)
{
    Audio::Controls controls {};

    ControlsModel model(&controls);

    model.add(10);
    model.add(12);
    //model.move(0, 1);

    ASSERT_EQ(model.get(0)->paramID(), 12);
    ASSERT_EQ(model.get(1)->paramID(), 10);
}