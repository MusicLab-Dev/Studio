/**
 * @ Author: Cédric Lucchese
 * @ Description: Project implementation
 */

#include <QQmlEngine>

#include "Project.hpp"

Project::Project(Audio::Project *project, QObject *parent)
    : QObject(parent), _data(project)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

bool Project::setPlaybackMode(const PlaybackMode mode) noexcept
{
    if (this->playbackMode() == mode)
        return false;
    _data->setPlaybackMode(mode);
    emit playbackModeChanged();
    return true;
}

bool Project::setName(const QString &name) noexcept
{
    if (this->name() == name)
        return false;
    _data->setName(name);
    emit nameChanged();
    return true;
}