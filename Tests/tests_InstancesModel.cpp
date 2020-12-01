/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: InstancesModel tests
 */

#include <gtest/gtest.h>

#include <Studio/InstancesModel.hpp>

TEST(InstancesModel, InitDestroy)
{
    Audio::BeatRanges ranges {};
    ASSERT_NO_THROW(InstancesModel tmp(&ranges));
}

TEST(InstancesModel, UpdateInternal)
{
    Audio::BeatRanges ranges1 { { 0, 1 }, { 1, 2 } };
    Audio::BeatRanges ranges2 { { 2, 3 }, { 3, 4 } };

    InstancesModel model(&ranges1);
    ASSERT_EQ(model.get(0).from, 0);
    ASSERT_EQ(model.get(0).to, 1);
    ASSERT_EQ(model.get(1).from, 1);
    ASSERT_EQ(model.get(1).to, 2);

    model.updateInternal(&ranges2);
    ASSERT_EQ(model.get(0).from, 2);
    ASSERT_EQ(model.get(0).to, 3);
    ASSERT_EQ(model.get(1).from, 3);
    ASSERT_EQ(model.get(1).to, 4);
}