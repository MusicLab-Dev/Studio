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
    Audio::BeatRanges ranges2 { { 2, 3 }, { 3, 4 }, { 5, 6 } };
    Audio::BeatRanges ranges3 { { 7, 8 }, { 9, 10 }, {11, 12}, {13, 14} };

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
    ASSERT_EQ(model.get(2).from, 5);
    ASSERT_EQ(model.get(2).to, 6);

    model.updateInternal(&ranges3);
    ASSERT_EQ(model.get(0).from, 7);
    ASSERT_EQ(model.get(0).to, 8);
    ASSERT_EQ(model.get(1).from, 9);
    ASSERT_EQ(model.get(1).to, 10);
    ASSERT_EQ(model.get(2).from, 11);
    ASSERT_EQ(model.get(2).to, 12);
    ASSERT_EQ(model.get(3).from, 13);
    ASSERT_EQ(model.get(3).to, 14);

    model.updateInternal(&ranges1);
    ASSERT_EQ(model.get(0).from, 0);
    ASSERT_EQ(model.get(0).to, 1);
    ASSERT_EQ(model.get(1).from, 1);
    ASSERT_EQ(model.get(1).to, 2);

}

TEST(InstancesModel, Add)
{
    Audio::BeatRanges ranges { };

    InstancesModel model(&ranges);

    for (unsigned int i = 0; i < 100; i++) {
        Audio::BeatRange range { i, i+1 };
        model.add(range);
        ASSERT_EQ(model.get(i).from, i);
        ASSERT_EQ(model.get(i).to, i+1);
    }
}

TEST(InstancesModel, Remove)
{
    Audio::BeatRanges ranges { {1, 2}, {3, 4}, {5, 6}, {7, 8} };

    InstancesModel model(&ranges);

    model.remove(0);
    ASSERT_EQ(model.count(), 3);
    ASSERT_EQ(model.get(0).from, 3);
    ASSERT_EQ(model.get(0).to, 4);
    ASSERT_EQ(model.get(1).from, 5);
    ASSERT_EQ(model.get(1).to, 6);
    ASSERT_EQ(model.get(2).from, 7);
    ASSERT_EQ(model.get(2).to, 8);

    model.remove(1);
    ASSERT_EQ(model.count(), 2);
    ASSERT_EQ(model.get(0).from, 3);
    ASSERT_EQ(model.get(0).to, 4);
    ASSERT_EQ(model.get(1).from, 7);
    ASSERT_EQ(model.get(1).to, 8);

    model.remove(0);
    ASSERT_EQ(model.count(), 1);
    ASSERT_EQ(model.get(0).from, 7);
    ASSERT_EQ(model.get(0).to, 8);

    model.remove(0);
    ASSERT_EQ(model.count(), 0);
}

TEST(InstancesModel, Move)
{
    Audio::BeatRanges ranges { {1, 2}, {3, 4}, {5, 6}, {7, 8} };

    InstancesModel model(&ranges);

    model.move(0, {3, 4});
    ASSERT_EQ(model.get(0).from, 3);
    ASSERT_EQ(model.get(0).to, 4);

    model.move(2, {10, 100});
    ASSERT_EQ(model.get(2).from, 10);
    ASSERT_EQ(model.get(2).to, 100);

}