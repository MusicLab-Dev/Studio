/**
 * @ Author: Cédric Lucchese
 * @ Description: Project test
 */

#include <gtest/gtest.h>

#include <Studio/Project.hpp>
#include <Audio/Project.hpp>
#include <Audio/PluginTable.hpp>
#include <Studio/Scheduler.hpp>

TEST(Project, InitDestroy)
{
    Scheduler scheduler;
    Audio::PluginTable::Init();
    // F5 PLZ <3
    Audio::Project project(Core::FlatString("test"));

    ASSERT_NO_THROW(Project tmp(&project));
    Audio::PluginTable::Destroy();
}

TEST(Project, name)
{
    Scheduler scheduler;
    Audio::Project data(Core::FlatString("test"));
    Project project(&data);

    ASSERT_EQ(project.name().toStdString(), "test");
    project.setName("1");
    ASSERT_EQ(project.name().toStdString(), "1");
    project.setName("grossedubstep");
    ASSERT_EQ(project.name().toStdString(), "grossedubstep");
}

TEST(Project, path)
{
    Scheduler scheduler;
    Audio::Project data(Core::FlatString("test"));
    Project project(&data);
    QString str1 = "/ici/la";
    QString str2 = "/enfaitela/ok";

    project.setPath(str1);
    ASSERT_EQ(project.path(), str1);
    project.setPath(str2);
    ASSERT_EQ(project.path(), str2);
}

TEST(Project, playbackMode)
{
    Scheduler scheduler;
    Audio::Project data(Core::FlatString("test"));
    Project project(&data);

    project.setPlaybackMode(Project::PlaybackMode::Live);
    ASSERT_EQ(project.playbackMode(), Project::PlaybackMode::Live);
    project.setPlaybackMode(Project::PlaybackMode::Production);
    ASSERT_EQ(project.playbackMode(), Project::PlaybackMode::Production);
}

TEST(Project, Save)
{

}