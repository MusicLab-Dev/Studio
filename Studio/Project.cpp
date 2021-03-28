/**
 * @ Author: Cédric Lucchese
 * @ Description: Project implementation
 */

#include <QQmlEngine>

#include "Models.hpp"
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

void Project::setPlaybackMode(const PlaybackMode mode) noexcept
{
    Models::AddProtectedEvent(
        [this, mode] {
            _data->setPlaybackMode(static_cast<Audio::Project::PlaybackMode>(mode));
        },
        [this] {
            emit playbackModeChanged();
        }
    );
}
