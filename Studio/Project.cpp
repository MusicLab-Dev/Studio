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
    if (!_data->setPlaybackMode(static_cast<Audio::Project::PlaybackMode>(mode)))
        return false;
    emit playbackModeChanged();
    return true;
}

bool Project::setName(const QString &name) noexcept
{
    if (this->name() == name)
        return false;
    _data->name() = name.toStdString();
    emit nameChanged();
    return true;
}

bool Project::setPath(const QString &path) noexcept
{
    if (_path == path)
        return false;
    _path = path;
    emit pathChanged();
    return true;
}
