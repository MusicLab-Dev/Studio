/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionModel tests
 */

#include <gtest/gtest.h>

#include <Studio/PartitionsModel.hpp>

TEST(PartitionsModel, InitDestroy)
{
    Audio::Partitions partitions {};

    ASSERT_NO_THROW(PartitionsModel tmp(&partitions));
}

TEST(PartitionsModel, Add)
{
    Audio::Partitions partitions {};

    PartitionsModel model(&partitions);

    model.add({2, 4});

}

/*
TEST(PartitionsModel, Remove)
{
    Audio::Partitions partitions {};

    PartitionsModel model(&partitions);

    model.add({2, 4});
    model.remove(0);
    ASSERT_EQ(model.count(), 0);

}*/