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
    Scheduler scheduler(Audio::ProjectPtr(std::make_shared<Audio::Project>("test")));

    Audio::Partition partition {};

    PartitionModel model(&partition);

    model.add(
        Note(
            Audio::BeatRange {1u, 2u},
            static_cast<Key>(1),
            static_cast<Velocity>(10),
            static_cast<Tuning>(0)
        )
    );
    model.add(
        Note(
            Audio::BeatRange {4u, 6u},
            static_cast<Key>(3),
            static_cast<Velocity>(20),
            static_cast<Tuning>(0)
        )
    );
    ASSERT_EQ(model.count(), 2);

}

TEST(PartitionModel, RemoveNote)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler(Audio::ProjectPtr(std::make_shared<Audio::Project>("test")));

    Audio::Partition partition {};

    PartitionModel model(&partition);

    model.add(
        Note(
            Audio::BeatRange {1u, 2u},
            static_cast<Key>(1),
            static_cast<Velocity>(10),
            static_cast<Tuning>(0)
        )
    );

    model.remove(0);
    ASSERT_EQ(model.count(), 0);

}

TEST(PartitionModel, UpdateInternal)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler(Audio::ProjectPtr(std::make_shared<Audio::Project>("test")));

    Audio::Partition partition1 {};
    Audio::Partition partition2 {};

    partition1.instances().push<Audio::BeatRange>({1u, 2u});
    partition2.instances().push<Audio::BeatRange>({3u, 4u});

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

TEST(PartitionModel, Name)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler(Audio::ProjectPtr(std::make_shared<Audio::Project>("test")));

    Audio::Partition partition {};

    PartitionModel model(&partition);

    model.setName("hello");
    ASSERT_EQ(model.name(), "hello");
}

TEST(PartitionModel, Muted)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler(Audio::ProjectPtr(std::make_shared<Audio::Project>("test")));

    Audio::Partition partition {};

    PartitionModel model(&partition);

    model.setMuted(false);
    ASSERT_EQ(model.muted(), false);
    model.setMuted(true);
    ASSERT_EQ(model.muted(), true);
}

TEST(PartitionModel, MidiChannels)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler(Audio::ProjectPtr(std::make_shared<Audio::Project>("test")));

    Audio::Partition partition {};

    PartitionModel model(&partition);

    model.setMidiChannels(10);
    ASSERT_EQ(model.midiChannels(), 10);
}