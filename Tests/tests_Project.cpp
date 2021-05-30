/**
 * @ Author: Cédric Lucchese
 * @ Description: Project test
 */

#include <gtest/gtest.h>

#include <Studio/Project.hpp>
#include <Audio/Project.hpp>
#include <Audio/PluginTable.hpp>
#include <Studio/Application.hpp>

TEST(Project, InitDestroy)
{
    // Audio::Device::DriverInstance driver;
    // Audio::PluginTable::Instance instance;
    // Application app;
}

TEST(Project, name)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Application app;
    auto &project = *app.project();

    project.setName("test");
    ASSERT_EQ(project.name().toStdString(), "test");
    project.setName("1");
    ASSERT_EQ(project.name().toStdString(), "1");
    project.setName("grossedubstep");
    ASSERT_EQ(project.name().toStdString(), "grossedubstep");
}

TEST(Project, path)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Application app;
    auto &project = *app.project();
    QString str1 = "/ici/la";
    QString str2 = "/enfaitela/ok";

    project.setPath(str1);
    ASSERT_EQ(project.path(), str1);
    project.setPath(str2);
    ASSERT_EQ(project.path(), str2);
}