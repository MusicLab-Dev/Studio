/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionModel tests
 */

#include <gtest/gtest.h>

#include <Studio/PartitionModel.hpp>

TEST(PartitionModel, InitDestroy)
{
    Audio::Partition partition {};

    ASSERT_NO_THROW(PartitionModel tmp(&partition));
}

TEST(PartitionModel, AddNote)
{
    Audio::Partition partition {};

    PartitionModel model(&partition);

    model.addNote(
        Audio::Note(
            Audio::BeatRange {1, 2},
            1,
            10)
    );

}

TEST(PartitionModel, RemoveNote)
{
    Audio::Partition partition {};

    PartitionModel model(&partition);

    model.addNote(
        Audio::Note(
            Audio::BeatRange {1, 2},
            1,
            10)
    );

    model.removeNote(0);
    ASSERT_EQ(model.count(), 0);

}

TEST(PartitionModel, UpdateInternal)
{
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
}