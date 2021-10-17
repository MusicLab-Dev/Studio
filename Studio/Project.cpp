/**
 * @ Author: Cédric Lucchese
 * @ Description: Project implementation
 */

#include <QQmlEngine>
#include <QJsonDocument>
#include <QJsonObject>

#include "Models.hpp"
#include "Project.hpp"
#include "ProjectSave.hpp"
#include "ProjectSerializer.hpp"

Audio::Node *Project::createMaster(const std::string &path)
{
    auto plugin = Audio::PluginTable::Get().instantiate(path);

    auto &backendChild = _data->master();
    backendChild = std::make_unique<Audio::Node>(nullptr, std::move(plugin));
    backendChild->setName(Core::FlatString(DefaultMasterName));
    backendChild->prepareCache(Scheduler::Get()->audioSpecs());
    return backendChild.get();
}

Project::Project(Audio::Project *project, QObject *parent)
    : QObject(parent), _data(project)
{
    recreateMaster();
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

bool Project::save(void) noexcept
{
    if (_path.isEmpty())
        return false;
    return saveAs(_path);
}

bool Project::saveAs(const QString &path) noexcept
{
    Scheduler::Get()->stopAndWait();
    QFile file(path);
    if (!file.open(QFile::WriteOnly)) {
        qCritical() << "Project::saveAs: Couldn't create file" << path;
        return false;
    }
    QJsonDocument doc;
    doc.setObject(ProjectSerializer::Serialize(*this));
    const auto data = doc.toJson(QJsonDocument::JsonFormat::Indented);
    if (!file.write(data)) {
        qCritical() << "Project::saveAs: Couldn't write file" << path;
        return false;
    }
    setPath(path);
    return true;
}

bool Project::loadFrom(const QString &path) noexcept
{
    Scheduler::Get()->stopAndWait();
    recreateMaster();
    try {
        QFile file(path);
        if (!file.open(QFile::ReadOnly)) {
            qCritical() << "Project::loadFrom: Invalid project file path" << path;
            return false;
        }
        const auto doc = QJsonDocument::fromJson(file.readAll());
        if (!ProjectSerializer::Deserialize(*this, doc.object())) {
            qCritical() << "Project::loadFrom: Couldn't deserialize project file object" << path;
            return false;
        }
        setPath(path);
        return true;
    } catch (const std::exception &e) {
        qCritical() << "Project::loadFrom: Exception thrown:" << e.what();
        return false;
    }
}

bool Project::loadOldCompatibilityFrom(const QString &path) noexcept
{
    Scheduler::Get()->stopAndWait();
    recreateMaster();
    ProjectSave psave(this);
    setPath(path);
    emit nameChanged();
    return psave.load();
}

void Project::clear(void) noexcept
{
    Scheduler::Get()->stopAndWait();
    recreateMaster();
}

void Project::recreateMaster(void)
{
    emplaceMaster(NodePtr::Make(createMaster(), this));
}

void Project::emplaceMaster(NodePtr &&master)
{
    if (_master)
        disconnect(_master.get(), &NodeModel::latestInstanceChanged, this, &Project::latestInstanceChanged);
    _master = std::move(master);
    connect(_master.get(), &NodeModel::latestInstanceChanged, this, &Project::latestInstanceChanged);
    emit masterChanged();
    emit latestInstanceChanged();
}
