/**
 * @ Author: Cédric Lucchese
 * @ Description: Main Application implementation
 */

#include <QQmlEngine>

#include "Application.hpp"

#include <Audio/Plugins/Mixer.hpp>

Application::Application(QObject *parent)
    : _scheduler(this), _backendProject(Core::FlatString(DefaultProjectName), DefaultPlaybackMode), _project(&_backendProject, this) /*_devices(), _plugins(),*/ 
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}
