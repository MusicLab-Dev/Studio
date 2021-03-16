/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionModel tests
 */

#include <gtest/gtest.h>

#include <Studio/PartitionModel.hpp>
#include <Studio/Scheduler.hpp>

TEST(PartitionModel, InitDestroy)
{
    Audio::Partition partition {};

    ASSERT_NO_THROW(PartitionModel tmp(&partition));
}

TEST(PartitionModel, AddNote)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;

    Audio::Partition partition {};

    PartitionModel model(&partition);

    model.add(
        Note(
            Audio::BeatRange {1, 2},
            1,
            10)
    );
    model.add(
        Note(
            Audio::BeatRange {4, 6},
            3,
            20)
    );
    ASSERT_EQ(model.count(), 2);

}

TEST(PartitionModel, RemoveNote)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;

    Audio::Partition partition {};

    PartitionModel model(&partition);

    model.add(
        Note(
            Audio::BeatRange {1, 2},
            1,
            10
        )
    );

    model.remove(0);
    ASSERT_EQ(model.count(), 0);

}

TEST(PartitionModel, UpdateInternal)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler;

    Audio::Partition partition1 {};
    Audio::Partition partition2 {};

    partition1.instances().push<Audio::BeatRange>({1, 2});
    partition2.instances().push<Audio::BeatRange>({3, 4});

    PartitionModel model(&partition1);
    ASSERT_EQ(model.instances().get(0).from, 1);
    ASSERT_EQ(model.instances().get(0).to, 2);

    model.updateInternal(&partition2);
    ASSERT_EQ(model.instances().get(0).from, 3);
    ASSERT_EQ(model.instances().get(0).to, 4);

    model.updateInternal(&partition1);
    ASSERT_EQ(model.instances().get(0).from, 1);
    ASSERT_EQ(model.instances().get(0).to, 2);
}