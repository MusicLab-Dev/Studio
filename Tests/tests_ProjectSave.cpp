/**
 * @ Author: Cédric Lucchese
 * @ Description: Project Save
 */

#include <gtest/gtest.h>

#include "Studio/Project.hpp"
#include "Studio/ProjectSave.hpp"
#include "Studio/Device.hpp"
#include "Studio/Application.hpp"

TEST(ProjectSave, transformPartitionsInVariantList)
{
    Audio::Device::DriverInstance driver;
    Audio::PluginTable::Instance instance;
    Application app;

    ProjectSave save(app.project());

    auto list = save.transformPartitionsInVariantList(*app.project()->master()->partitions());
}

