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
    model.setColor(Qt::red);
    ASSERT_EQ(model.color(), Qt::red);

    Audio::PluginTable::Destroy();
}

TEST(NodeModel, Muted)
{
    Audio::PluginTable::Init();
    Audio::Node node {};

    NodeModel model(&node);
    model.setMuted(true);
    ASSERT_EQ(model.muted(), true);
    model.setMuted(false);
    ASSERT_EQ(model.muted(), false);

    Audio::PluginTable::Destroy();
}

TEST(NodeModel, Name)
{
    Audio::PluginTable::Init();
    Audio::Node node {};

    NodeModel model(&node);
    model.setName("testnode");
    ASSERT_EQ(model.name(), "testnode");

    Audio::PluginTable::Destroy();
}