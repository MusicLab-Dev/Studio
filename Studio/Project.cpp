/**
 * @ Author: Cédric Lucchese
 * @ Description: Project implementation
 */

#include <QQmlEngine>

#include "Models.hpp"
#include "Project.hpp"
#include "ProjectSave.hpp"

Audio::Node *Project::createMasterMixer(void)
{
    std::string path = "__internal__:/Mixer";

    auto plugin = Audio::PluginTable::Get().instantiate("__internal__:/Mixer");

    auto &backendChild = _data->master();
    backendChild = std::make_unique<Audio::Node>(nullptr, std::move(plugin));
    backendChild->setName(Core::FlatString("Master"));
    backendChild->prepareCache(Scheduler::Get()->audioSpecs());
    return backendChild.get();
}

Project::Project(Audio::Project *project, QObject *parent)
    : QObject(parent), _data(project), _master(createMasterMixer(), this)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

void Project::setName(const QString &name) noexcept
{
    auto str = name.toStdString();

    if (_data->name() == str)
        return;
    _data->name() = str;
    emit nameChanged();
}

void Project::setPath(const QString &path) noexcept
{
    if (_path == path)
        return;
    _path = path;
    emit pathChanged();
}

void Project::setBPM(const BPM bpm) noexcept
{
    if (_data->bpm() == bpm)
        return;
    Scheduler::Get()->addEvent(
        [this, bpm] {
            _data->setBPM(bpm);
        },
        [this] {
            emit bpmChanged();
        }
    );
}

void Project::save()
{
    ProjectSave psave(this);

    /** debug */
    setPath("save.json");
    psave.save();
}

void Project::saveAs(const QString &path)
{

}

void Project::load()
{

}