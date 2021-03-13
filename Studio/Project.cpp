/**
 * @ Author: Cédric Lucchese
 * @ Description: Project implementation
 */

#include <QQmlEngine>

#include "Project.hpp"

Audio::Node *Project::createMasterMixer(void)
{
    std::string path = "__internal__:/Mixer";

    auto plugin = Audio::PluginTable::Get().instantiate("__internal__:/Mixer");

    auto &backendChild = _data->master();
    backendChild = std::make_unique<Audio::Node>(std::move(plugin));
    backendChild->setName(Core::FlatString("Master"));
    // backendChild->prepareCache(specs);
    return backendChild.get();
}

Project::Project(Audio::Project *project, QObject *parent)
    : QObject(parent), _data(project), _master(createMasterMixer(), this)
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
