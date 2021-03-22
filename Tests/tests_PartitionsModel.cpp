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
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;

    Audio::Partitions partitions {};

    PartitionsModel model(&partitions);

    for (unsigned int i = 0; i < 100; i++) {
        model.add();
        ASSERT_EQ(model.count(), i+1);
    }
    for (unsigned int i = 99; i > 0; i--) {
        model.remove(0);
        ASSERT_EQ(model.count(), i);
    }
}

TEST(PartitionsModel, MovePartitions)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;

    Audio::Partitions partitions {};

    PartitionsModel model(&partitions);

    model.add("first");
    model.add("second");
    model.move(0, 1);

    ASSERT_EQ(model.get(0)->name(), "second");
    ASSERT_EQ(model.get(1)->name(), "first");
}