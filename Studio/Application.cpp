/**
 * @ Author: Cédric Lucchese
 * @ Description: Main Application implementation
 */

#include <QQmlEngine>

#include "Application.hpp"

Application::Application(QObject *parent)
    :   QObject(parent),
        _settings(this),
        _backendProject(std::make_shared<Audio::Project>(Core::FlatString(DefaultProjectName))),
        _scheduler(Audio::ProjectPtr(_backendProject), this),
        _project(_backendProject.get(), this)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}
