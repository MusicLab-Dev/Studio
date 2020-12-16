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