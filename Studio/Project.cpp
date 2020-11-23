/**
 * @ Author: Cédric Lucchese
 * @ Description: Project implementation
 */

#include "Project.hpp"

Project::Project(QObject *parent) noexcept
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

bool Project::setPlaybackMode(const PlaybackMode mode) noexcept
{
    if (_playbackMode == mode)
        return false;
    _playbackMode = mode;
    emit playbackModeChanged();
    return true;
}

bool Project::setName(const QString &name) noexcept
{
    if (_name == name)
        return false;
    _name = name;
    emit nameChanged();
    return true;
}