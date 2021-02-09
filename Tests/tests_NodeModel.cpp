/**
 * @ Author: Cédric Lucchese
 * @ Description: Points tests
 */

#include <gtest/gtest.h>
#include <QColor>

#include <Studio/NodeModel.hpp>

TEST(NodeModel, InitDestroy)
{
    Audio::PluginTable::Init();
    Audio::Node node {};

    ASSERT_NO_THROW(NodeModel tmp(&node));
    Audio::PluginTable::Destroy();
}

TEST(NodeModel, Color)
{
    Audio::PluginTable::Init();
    Audio::Node node {};

    NodeModel model(&node);
    model.setColor("red");
    //ASSERT_EQ(model.color(), QColor::red);

    Audio::PluginTable::Destroy();
}