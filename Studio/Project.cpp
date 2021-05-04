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
    : QObject(parent), _data(project)
{
    recreateMasterMixer();
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
        [bpm] {
            Scheduler::Get()->setBPM(bpm);
        },
        [this] {
            emit bpmChanged();
        }
    );
}

bool Project::save(void) noexcept
{
    if (_path.isEmpty())
        return false;

    ProjectSave psave(this);
    return psave.save();
}

bool Project::saveAs(const QString &path) noexcept
{
    ProjectSave psave(this);
    setPath(path);
    return psave.save();
}

bool Project::loadFrom(const QString &path) noexcept
{
    ProjectSave psave(this);
    setPath(path);
    return psave.load();
}

void Project::clear(void) noexcept
{
    Scheduler::Get()->stopAndWait();
    recreateMasterMixer();
}

void Project::recreateMasterMixer(void)
{
    _master.reset();
    if (_data)
        _data->master().reset();
    _master = std::make_unique<NodeModel>(createMasterMixer(), this);
    emit masterChanged();
}
