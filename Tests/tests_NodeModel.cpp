
/**
 * @ Author: Cédric Lucchese
 * @ Description: Points tests
 */

#include <gtest/gtest.h>
#include <QColor>

#include <Studio/Application.hpp>

TEST(NodeModel, InitDestroy)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Application app;
    Audio::Node &node = *app.scheduler()->project()->master();

    ASSERT_NO_THROW(NodeModel tmp(&node));
}

TEST(NodeModel, Color)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Application app;
    Audio::Node &node = *app.scheduler()->project()->master();

    NodeModel model(&node);
    model.setColor(Qt::red);
    ASSERT_EQ(model.color(), Qt::red);
}

TEST(NodeModel, Muted)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Application app;
    Audio::Node &node = *app.scheduler()->project()->master();

    NodeModel model(&node);
    model.setMuted(true);
    ASSERT_EQ(model.muted(), true);
    model.setMuted(false);
    ASSERT_EQ(model.muted(), false);
}

TEST(NodeModel, Name)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Application app;
    Audio::Node &node = *app.scheduler()->project()->master();

    NodeModel model(&node);
    model.setName("testnode");
    ASSERT_EQ(model.name().toStdString(), "testnode");
}

TEST(NodeModel, AddRemove)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Application app;
    Audio::Node &node = *app.scheduler()->project()->master();
    NodeModel model(&node);

    model.add("__internal__:/Mixer");
    ASSERT_EQ(model.count(), 1);
    model.remove(0);
    ASSERT_EQ(model.count(), 0);
}
