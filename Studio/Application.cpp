/**
 * @ Author: Cédric Lucchese
 * @ Description: Main Application implementation
 */

#include <QQmlEngine>

#include "Application.hpp"

Application::Application(QObject *parent)
    :   _backendProject(std::make_shared<Audio::Project>(Core::FlatString(DefaultProjectName), DefaultPlaybackMode)),
        _scheduler(this),
        _project(_backendProject.get(), this)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
    _scheduler.setProject(Audio::ProjectPtr(_backendProject));
}
