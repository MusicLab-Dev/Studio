/**
 * @ Author: Cédric Lucchese
 * @ Description: ProjectSave sources
 */

#include <QVariantMap>
#include <QVariantList>
#include <QMetaEnum>

#include "ControlEvent.hpp"
#include "Scheduler.hpp"
#include "ProjectSave.hpp"
#include "Note.hpp"
#include "Point.hpp"

ProjectSave::ProjectSave(Project *project)
    : _project(project)
{}


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
    qDebug() << _project->path();
    if (!file.exists())
        throw std::logic_error("ProjectSave::write: not created");
    file.write(json.toUtf8());
    file.close();
}

/** -- SAVE PART -- */

bool ProjectSave::save(void)
{
    QVariantMap map;

    map.insert("name", _project->name());
    map.insert("bpm", Scheduler::Get()->bpm());
    map.insert("master", transformNodeInVariantMap(*_project->master()));

    QJsonDocument doc(QJsonDocument::fromVariant(map));
    try {
        write(doc.toJson(QJsonDocument::Compact));
        qDebug() << "Debug: ProjectSave::save Success";
    } catch (const std::logic_error &e) {
        qDebug() << "Debug: ProjectSave::save: " + QString(e.what());
        return false;
    }
    return true;
}

QVariantMap ProjectSave::transformNodeInVariantMap(NodeModel &node)
{
    if (!_project)
        throw std::runtime_error("ProjectSave::transformNodeInVariantMap: pointer exception");
    QVariantMap map;
    QVariantList children;

    map.insert("name", node.name());
    map.insert("color", node.color());
    map.insert("muted", node.muted());
    map.insert("partitions", transformPartitionsInVariantMap(*node.partitions()));
    map.insert("controls", transformAutomationsInVariantList(*node.controls()));
    map.insert("plugin", transformPluginInVariantMap(*node.plugin()));

    for (auto it = node.children().begin(); it != node.children().end(); ++it) {
        children.push_back(transformNodeInVariantMap(*it->get()));
    }
    map.insert("children", children);

    return map;
}

QVariantMap ProjectSave::transformPartitionsInVariantMap(PartitionsModel &partitions) noexcept
{
    QVariantMap data;
    QVariantList partitionList;

    for (int i = 0; i < partitions.count(); i++) {
        PartitionModel *partition = partitions.get(i);
        if (!partition)
            continue;

        QVariantMap mapPartition;

        mapPartition.insert("name", partition->name());

        QVariantList listNotes;
        for (int y = 0; y < partition->count(); y++) {
            QVariantMap mapNote;
            Note note = partition->get(y);
            mapNote.insert("range", QVariantList({note.range.from, note.range.to}));
            mapNote.insert("key", note.key);
            mapNote.insert("velocity", note.velocity);
            mapNote.insert("tuning", note.tuning);
            listNotes.push_back(mapNote);
        }
        mapPartition.insert("notes", listNotes);
        partitionList.push_back(mapPartition);
    }
    data.insert("partitions", partitionList);
    QJsonArray instanceList;
    for (auto &instance : *partitions.instances()->audioInstances()) {
        QJsonMap mapInstance;
        mapInstance.insert("partitionIndex", instance.partitionIndex);
        mapInstance.insert("offset", instance.offset);
        QJsonArray rangeList;
        rangeList.push_back(instance.range.from);
        rangeList.push_back(instance.range.to);
        mapInstance.insert("range", rangeList);
        instanceList.push_back(mapInstance);
    }
    data.insert("instances", instanceList);
    return data;
}

QVariantList ProjectSave::transformAutomationsInVariantList(AutomationsModel &automations) noexcept
{
    QVariantList list;

    for (int i = 0; i < automations.count(); i++) {
        AutomationModel *automation = automations.get(i);
        if (!automation)
            continue;

        QVariantMap data;

        data.insert("name", automation->name());
        data.insert("muted", automation->muted());

        QVariantList listPoints;
        for (int p = 0; p < automation->count(); p++) {
            QVariantMap mapPoint;
            const GPoint point = automation->get(p);
            mapPoint.insert("beat", point.beat);
            mapPoint.insert("curveType", QVariant::fromValue(point.getType()).toJsonValue());
            mapPoint.insert("curveRate", point.curveRate);
            mapPoint.insert("value", point.value);
            listPoints.push_back(mapPoint);
        }
        data.insert("points", listPoints);
        list.push_back(data);
    }
    return list;
}

QVariantMap ProjectSave::transformPluginInVariantMap(PluginModel &plugin) noexcept
{
    QVariantMap map;

    map.insert("factory", plugin.audioPlugin()->factory()->getPath().data());

    try {
        QStringList paths;
        for (auto it = plugin.audioPlugin()->getExternalPaths().begin(); it != plugin.audioPlugin()->getExternalPaths().end(); ++it) {
            paths.push_back(it->data());
        }
        map.insert("externalPaths", paths);
    } catch (const std::runtime_error &e) {}

    QVariantList controls;
    auto &meta = plugin.audioPlugin()->getMetaData().controls;
    const auto size = static_cast<int>(meta.size());
    for (int i = 0; i < size; i++) {
        controls.push_back(QVariantList({i, plugin.audioPlugin()->getControl(static_cast<ParamID>(i))}));
    }
    map.insert("controls", controls);

    return map;
}

/** -- LOAD PART -- */

bool ProjectSave::load(void)
{
    try {
        QString jsonStr = read();
        if (jsonStr.isEmpty())
            return false;
        QJsonDocument doc = QJsonDocument::fromJson(jsonStr.toUtf8());
        if (!doc.isObject())
            throw std::logic_error("ProjectSave::load: Invalid file");
        QJsonObject obj = doc.object();

        _project->setName(obj["name"].toString());
        Scheduler::Get()->setBPM(static_cast<float>(obj["bpm"].toDouble()));
        initNode(_project->master(), obj["master"].toObject());

        qDebug() << "ProjectSave::load success";
    } catch (const std::logic_error &e) {
        qDebug() << "ProjectSave::load: " + QString(e.what());
        return false;
    }
    return true;
}

bool ProjectSave::initNode(NodeModel *node, const QJsonObject &obj)
{
    if (!node)
        return false;

    node->setName(obj["name"].toString());
    node->setColor(obj["color"].toString());
    node->setMuted(obj["muted"].toBool());
    initPlugin(node->plugin(), obj["plugin"].toObject());
    initPartitions(node->partitions(), obj["partitions"].toObject());
    initAutomations(node->automations(), obj["automations"].toArray());

    auto children = obj["children"].toArray();
    for (int i = 0 ; i < children.size(); i++) {
        auto child = children[i].toObject();
        auto childPlugin = child["plugin"].toObject();
        initNode(
            node->add(childPlugin["factory"].toString()),
            child
        );
    }

    return true;
}

bool ProjectSave::initPartitions(PartitionsModel *partitions, const QJsonObject &obj)
{
    // Load partitions
    QJsonArray array = obj["partitions"].toArray();

    for (int i = 0; i < array.size(); i++) {
        partitions->add();
        QJsonObject partitionObj = array[i].toObject();
        PartitionModel *partition = partitions->get(i);
        if (!partition)
            continue;

        partition->setName(partitionObj["name"].toString());

        auto notes = partitionObj["notes"].toArray();
        for (int y = 0; y < notes.size(); y++) {
            QJsonObject noteObj = notes[y].toObject();
            Note note;

            auto range = noteObj["range"].toArray();
            note.range.from = static_cast<Beat>(range[0].toInt());
            note.range.to = static_cast<Beat>(range[1].toInt());
            note.key = static_cast<Key>(noteObj["key"].toInt());
            note.velocity = static_cast<Velocity>(noteObj["velocity"].toInt());
            note.tuning = static_cast<Tuning>(noteObj["tuning"].toInt());
            partition->add(note);
        }
    }

    // Load instances
    auto instances = obj["instances"].toArray();
    const auto partitionCount = partitions->count();
    for (int y = 0; y < instances.size(); y++) {
        QJsonObject instanceObj = instances[y].toObject();
        const std::uint32_t partitionIndex = static_cast<std::uint32_t>(instanceObj["partitionIndex"].toInt());
        const Beat offset = static_cast<Beat>(instanceObj["offset"].toInt());
        const QJsonArray rangeObj = instanceObj["range"].toArray();
        const Beat from = static_cast<Beat>(rangeObj[0].toInt());
        const Beat to = static_cast<Beat>(rangeObj[1].toInt());

        if (partitionIndex >= partitionCount) {
            qDebug() << "ProjectSave::initPartitions: Invalid partition instance, out of range partition index"
                    << partitionIndex << "/" << partitionCount;
            continue;
        }

        partition->instances().add(PartitionInstance {
            partitionIndex,
            offset,
            BeatRange { from, to }
        });
    }
    return true;
}

bool ProjectSave::initAutomations(AutomationsModel *automations, const QJsonArray &array)
{
    if (array.size() >= automations->count()) {
        qDebug() << "ProjectSave::initAutomations: mismatching automation count";
        return false;
    }
    for (int i = 0; i < array.size(); i++) {
        QJsonObject automationObj = array[i].toObject();
        AutomationModel *automation = automations->get(i);
        automation->setMuted(automationObj["muted"].toBool());
        automation->setName(automationObj["name"].toString());

        auto points = automationObj["points"].toArray();
        for (int p = 0; p < points.size(); p++) {
            QJsonObject pointObj = points[p].toObject();
            GPoint point;
            point.beat = static_cast<Beat>(pointObj["beat"].toInt());
            point.setType(static_cast<GPoint::CurveType>(QMetaEnum::fromType<GPoint::CurveType>().keyToValue(pointObj["beat"].toString().toStdString().c_str())));
            point.curveRate = static_cast<GPoint::CurveRate>(pointObj["curveRate"].toInt());
            point.value = pointObj["value"].toDouble();
            automation->add(point);
        }
    }
    return true;
}

bool ProjectSave::initPlugin(PluginModel *plugin, const QJsonObject &obj)
{
    try {
        plugin->audioPlugin()->setExternalPaths([](const QJsonObject &obj) -> Audio::ExternalPaths {
            QJsonArray list = obj["externalPaths"].toArray();
            Audio::ExternalPaths paths;
            for (auto it = list.begin(); it != list.end(); it++)
                paths.push(it->toString().toStdString());
            return paths;
        }(obj));
    } catch (const std::runtime_error &e) {}

    auto arr = obj["controls"].toArray();
    for (auto it = arr.begin(); it != arr.end(); it++) {
        auto values = it->toArray();
        plugin->setControl(ControlEvent(values[0].toInt(), values[1].toDouble()));
    }
    return true;
}
