/**
 * @ Author: Cédric Lucchese
 * @ Description: Points tests
 */

#include <gtest/gtest.h>
#include <QColor>

#include <Studio/NodeModel.hpp>
#include <Studio/Scheduler.hpp>

TEST(NodeModel, InitDestroy)
{
    Scheduler scheduler;
    Audio::PluginTable::Init();
    Audio::Node node {};

    ASSERT_NO_THROW(NodeModel tmp(&node));
    Audio::PluginTable::Destroy();
}

TEST(NodeModel, Color)
{
    Scheduler scheduler;
    Audio::PluginTable::Init();
    Audio::Node node {};

    NodeModel model(&node);
    model.setColor(Qt::red);
    ASSERT_EQ(model.color(), Qt::red);

    Audio::PluginTable::Destroy();
}

TEST(NodeModel, Muted)
{
    Scheduler scheduler;
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
    Scheduler scheduler;
    Audio::PluginTable::Init();
    Audio::Node node {};

    NodeModel model(&node);
    model.setName("testnode");
    ASSERT_EQ(model.name().toStdString(), "testnode");

    Audio::PluginTable::Destroy();
}

TEST(NodeModel, Add)
{
    Scheduler scheduler;
    Audio::PluginTable::Init();
    Audio::Node node {};
}