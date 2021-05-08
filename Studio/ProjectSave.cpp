/**
 * @ Author: Cédric Lucchese
 * @ Description: ProjectSave sources
 */

#include <QVariantMap>
#include <QVariantList>
#include <QMetaEnum>

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
    map.insert("partitions", transformPartitionsInVariantList(*node.partitions()));
    map.insert("controls", transformControlsInVariantList(*node.controls()));
    map.insert("plugin", transformPluginInVariantMap(*node.plugin()));

    for (auto it = node.children().begin(); it != node.children().end(); ++it) {
        children.push_back(transformNodeInVariantMap(*it->get()));
    }
    map.insert("children", children);

    return map;
}

QVariantList ProjectSave::transformPartitionsInVariantList(PartitionsModel &partitions) noexcept
{
    QVariantList list;

    for (int i = 0; i < partitions.count(); i++) {
        PartitionModel *partition = partitions.get(i);
        if (!partition)
            continue;

        QVariantMap data;

        data.insert("name", partition->name());
        data.insert("muted", partition->muted());

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
        data.insert("notes", listNotes);

        auto &instances = partition->instances();
        QVariantList listInstances;
        for (int y = 0; y < instances.count(); y++) {
            auto &instance = instances.get(y);
            listInstances.push_back(QVariantList({instance.from, instance.to}));
        }
        data.insert("instances", listInstances);

        list.push_back(data);
    }
    return list;
}

QVariantList ProjectSave::transformControlsInVariantList(ControlsModel &controls) noexcept
{
    QVariantList list;

    for (int i = 0; i < controls.count(); i++) {
        ControlModel *control = controls.get(i);
        if (!control)
            continue;

        QVariantMap data;

        data.insert("name", control->name());
        data.insert("paramID", control->paramID());
        data.insert("muted", control->muted());

        QVariantList listAutomations;
        for (int y = 0; y < control->count(); y++) {
            QVariantMap mapAutomation;
            AutomationModel *automation = control->get(y);
            if (!automation)
                continue;

            mapAutomation.insert("name", automation->name());
            mapAutomation.insert("muted", automation->muted());

            QVariantList listPoints;
            for (int p = 0; p < automation->count(); p++) {
                QVariantMap mapPoint;
                GPoint point = automation->get(p);

                mapPoint.insert("beat", point.beat);
                mapPoint.insert("curveType", QVariant::fromValue(point.getType()).toJsonValue());
                mapPoint.insert("curveRate", point.curveRate);
                mapPoint.insert("value", point.value);
                listPoints.push_back(mapPoint);
            }
            mapAutomation.insert("points", listPoints);

            auto &instances = automation->instances();
            QVariantList listInstances;
            for (int p = 0; p < instances.count(); p++) {
                auto &instance = instances.get(p);
                listInstances.push_back(QVariantList({instance.from, instance.to}));
            }
            mapAutomation.insert("instances", listInstances);

            listAutomations.push_back(mapAutomation);
        }
        data.insert("automations", listAutomations);

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
        QJsonObject obj = doc.object();

        _project->setName(obj["name"].toString());
        Scheduler::Get()->setBPM(static_cast<float>(obj["bpm"].toDouble()));
        initNode(_project->master(), obj["master"].toObject());

        qDebug() << "Debug: ProjectSave::Load success";
    } catch (const std::logic_error &e) {
        qDebug() << "Debug: ProjectSave::Load: " + QString(e.what());
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
    initPartitions(node->partitions(), obj["partitions"].toArray());
    initControls(node->controls(), obj["controls"].toArray());

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

bool ProjectSave::initPartitions(PartitionsModel *partitions, const QJsonArray &array)
{
    for (int i = 0; i < array.size(); i++) {
        partitions->add();
        QJsonObject partitionObj = array[i].toObject();
        PartitionModel *partition = partitions->get(i);
        if (!partition)
            continue;

        partition->setName(partitionObj["name"].toString());
        partition->setMuted(partitionObj["muted"].toBool());

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

        auto instances = partitionObj["instances"].toArray();
        for (int y = 0; y < instances.size(); y++) {
            QJsonArray instance = instances[y].toArray();
            Beat from = static_cast<Beat>(instance[0].toInt());
            Beat to = static_cast<Beat>(instance[1].toInt());

            partition->instances().add(BeatRange({from, to}));
        }
    }
    return true;
}

bool ProjectSave::initControls(ControlsModel *controls, const QJsonArray &array)
{
    for (int i = 0; i < array.size(); i++) {
        QJsonObject controlObj = array[i].toObject();
        controls->add(controlObj["paramID"].toInt());

        ControlModel *control = controls->get(i);
        if (!control)
            continue;

        control->setMuted(controlObj["muted"].toBool());

        auto automations = controlObj["automations"].toArray();
        for (int y = 0; y < automations.size(); y++) {
            QJsonObject automationObj = automations[y].toObject();

            control->add();
            AutomationModel *automation = control->get(y);
            if (!automation)
                continue;

            automation->setName(automationObj["name"].toString());
            automation->setMuted(automationObj["muted"].toBool());

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

            auto instances = automationObj["instances"].toArray();
            for (int p = 0; p < instances.size(); p++) {
                QJsonArray instance = instances[p].toArray();
                Beat from = static_cast<Beat>(instance[0].toInt());
                Beat to = static_cast<Beat>(instance[1].toInt());

                automation->instances().add(BeatRange({from, to}));
            }
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
        plugin->audioPlugin()->getControl(static_cast<ParamID>(it[0].toInt())) = it[1].toDouble();
    }
    return true;
}
