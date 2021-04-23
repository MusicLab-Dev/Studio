/**
 * @ Author: Cédric Lucchese
 * @ Description: Project Save
 */

#include <gtest/gtest.h>

#include "Studio/Project.hpp"
#include "Studio/ProjectSave.hpp"
#include "Studio/Device.hpp"
#include "Studio/Scheduler.hpp"

TEST(ProjectSave, transformPartitionsInVariantList)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Scheduler scheduler(Audio::ProjectPtr(std::make_shared<Audio::Project>("test")));

    Project project(scheduler.project().get());
    ProjectSave save(&project);

    auto list = save.transformPartitionsInVariantList(*project.master()->partitions());
}

