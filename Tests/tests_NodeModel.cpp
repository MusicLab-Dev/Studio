/**
 * @ Author: Cédric Lucchese
 * @ Description: Points tests
 */

#include <gtest/gtest.h>

#include <Studio/NodeModel.hpp>

TEST(NodeModel, InitDestroy)
{
    PluginTable::Init();
    Audio::Node node {};

    ASSERT_NO_THROW(NodeModel tmp(&node));
    PluginTable::Destroy();
}