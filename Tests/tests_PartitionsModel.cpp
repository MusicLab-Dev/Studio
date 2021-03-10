/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionModel tests
 */

#include <gtest/gtest.h>

#include <Studio/PartitionsModel.hpp>
#include <Studio/Scheduler.hpp>


TEST(PartitionsModel, InitDestroy)
{
    Audio::Partitions partitions {};

    ASSERT_NO_THROW(PartitionsModel tmp(&partitions));
}

TEST(PartitionsModel, AddRemove)
{
    Scheduler scheduler;

    Audio::Partitions partitions {};

    PartitionsModel model(&partitions);

    for (unsigned int i = 0; i < 100; i++) {
        model.add({i, i+1});
        ASSERT_EQ(model.count(), i+1);
    }
    for (unsigned int i = 99; i > 0; i--) {
        model.remove(0);
        ASSERT_EQ(model.count(), i);
    }
}