/**
 * @ Author: Cédric Lucchese
 * @ Description: Main Application implementation
 */

#include "Application.hpp"

Application::Application(QObject *parent) noexcept
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

bool Application::setProject(ProjectModel *project) noexcept
{
    if (_project == project)
        return false;
    _project = project;
    emit projectChanged();
    return true;
}

bool Application::setDevice(DeviceModel *device) noexcept
{
    if (_device == device)
        return false;
    _device = device;
    emit deviceChanged();
    return true;
}

bool Application::setPlugins(PluginTableModel *plugins) noexcept
{
    if (_plugins == plugins)
        return false;
    _plugins = plugins;
    emit pluginsChanged();
    return true;
}