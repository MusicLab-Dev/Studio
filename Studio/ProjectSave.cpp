/**
 * @ Author: Cédric Lucchese
 * @ Description: ProjectSave sources
 */

#include <QVariantMap>
#include <QVariantList>

#include "ProjectSave.hpp"
#include "Note.hpp"

ProjectSave::ProjectSave(Project *project)
    : _project(project)
{
}

ProjectSave::~ProjectSave()
{}

bool ProjectSave::save(void)
{
    QVariantMap map;

    map.insert("name", _project->name());
    map.insert("bpm", _project->bpm());
    map.insert("master", getNodeInVariantMap(*_project->master()));

    QJsonDocument doc(QJsonDocument::fromVariant(map));
    write(doc.toJson(QJsonDocument::Indented));
    qDebug() << "save success";
    return true;
}

bool ProjectSave::load(void)
{
    return true;
}

QString ProjectSave::read(void)
{
    QFile file(_project->path());
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    if (!file.exists())
        throw std::logic_error("ProjectSave::read: not found");
    auto str = file.readAll();
    file.close();
    return str;
}

void ProjectSave::write(const QString &json)
{
    QFile file(_project->path());
    file.open(QIODevice::WriteOnly | QFile::Truncate);
    if (!file.exists())
        throw std::logic_error("ProjectSave::write: not created");
    file.write(json.toUtf8());
    file.close();
}

QVariantMap ProjectSave::getNodeInVariantMap(NodeModel &node)
{
    if (!_project)
        throw std::runtime_error("ProjectSave::getNodeInVariantMap: pointer exception");

    QVariantMap map;

    map.insert("name", node.name());
    map.insert("color", node.color());
    map.insert("muted", node.muted());

    map.insert("partitions", getPartitionsInVariantList(*node.partitions()));
    map.insert("controls", getControlsInVariantList(*node.controls()));
    map.insert("plugin", getPluginInVariantMap(*node.plugin()));

    QVariantList children;

    for (auto it = node.nchildren().begin(); it != node.nchildren().end(); ++it) {
        children.push_back(getNodeInVariantMap(*it->get()));
    }
    map.insert("children", children);

    return map;
}

QVariantList ProjectSave::getPartitionsInVariantList(PartitionsModel &partitions) noexcept
{
    QVariantList list;

    for (unsigned int i = 0; i < partitions.count(); i++) {
        PartitionModel *partition = partitions.get(i);
        QVariantMap data;

        data.insert("name", partition->name());
        data.insert("muted", partition->muted());

        QVariantList listNotes;
        for (unsigned int y = 0; y < partition->count(); y++) {
            QVariantMap notes;
            Note note = partition->get(y);

            notes.insert("range", QVariantList({note.range.from, note.range.to}));
            notes.insert("key", note.key);
            notes.insert("velocity", note.velocity);
            notes.insert("tuning", note.tuning);
            listNotes.push_back(notes);
        }
        data.insert("notes", listNotes);

        auto &instances = partition->instances();
        QVariantList listInstances;
        for (unsigned int y = 0; y < instances.count(); y++) {
            auto &instance = instances.get(y);
            listInstances.push_back(QVariantList({instance.from, instance.to}));
        }
        data.insert("instances", listInstances);

        list.push_back(data);
    }
    return list;
}

QVariantList ProjectSave::getControlsInVariantList(ControlsModel &controls) noexcept
{
    return QVariantList();
}

QVariantMap ProjectSave::getPluginInVariantMap(PluginModel &plugin) noexcept
{
    return QVariantMap();
}


