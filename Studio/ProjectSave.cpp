/**
 * @ Author: Cédric Lucchese
 * @ Description: ProjectSave sources
 */

#include <QVariantMap>
#include <QVariantList>
#include <QMetaEnum>

#include "ProjectSave.hpp"
#include "Note.hpp"
#include "Point.hpp"

ProjectSave::ProjectSave(Project *project)
    : _project(project)
{}

/** -- SAVE PART -- */

bool ProjectSave::save(void)
{
    QVariantMap map;

    map.insert("name", _project->name());
    map.insert("bpm", _project->bpm());
    map.insert("master", transformNodeInVariantMap(*_project->master()));

    QJsonDocument doc(QJsonDocument::fromVariant(map));
    write(doc.toJson(QJsonDocument::Indented));
    qDebug() << "Save Success";
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

    for (auto it = node.nchildren().begin(); it != node.nchildren().end(); ++it) {
        children.push_back(transformNodeInVariantMap(*it->get()));
    }
    map.insert("children", children);

    return map;
}

QVariantList ProjectSave::transformPartitionsInVariantList(PartitionsModel &partitions) noexcept
{
    QVariantList list;

    for (unsigned int i = 0; i < partitions.count(); i++) {
        PartitionModel *partition = partitions.get(i);
        QVariantMap data;

        data.insert("name", partition->name());
        data.insert("muted", partition->muted());

        QVariantList listNotes;
        for (unsigned int y = 0; y < partition->count(); y++) {
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
        for (unsigned int y = 0; y < instances.count(); y++) {
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

    for (unsigned int i = 0; i < controls.count(); i++) {
        ControlModel *control = controls.get(i);
        QVariantMap data;

        data.insert("name", control->name());
        data.insert("paramID", control->paramID());
        data.insert("muted", control->muted());

        QVariantList listAutomations;
        for (unsigned int y = 0; y < control->count(); y++) {
            QVariantMap mapAutomation;
            AutomationModel *automation = control->get(y);

            mapAutomation.insert("name", automation->name());
            mapAutomation.insert("muted", automation->muted());

            QVariantList listPoints;
            for (unsigned p = 0; p < automation->count(); p++) {
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
            for (unsigned p = 0; p < instances.count(); p++) {
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
    for (int i = 0; i < meta.size(); i++) {
        controls.push_back(QVariantList({i, meta[i].defaultValue}));
    }
    map.insert("controls", controls);
    //TODO: ControlsQVecto

    return map;
}

/** -- LOAD PART -- */

bool ProjectSave::load(void)
{
    for (unsigned int i = 0; i < _project->master()->count(); i++)
        _project->master()->remove(i);
    /** TODO: have to remove all informations in the master node */

    QString jsonStr = read();
    if (jsonStr.isEmpty())
        return false;
    QJsonDocument doc = QJsonDocument::fromJson(jsonStr.toUtf8());
    QJsonObject obj = doc.object();

    _project->setName(obj["name"].toString());
    _project->setBPM(obj["bpm"].toDouble());
    initNode(_project->master(), obj["master"].toObject());

    qDebug("Load success");
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

    for (unsigned int i = 0 ; i < obj["children"].toArray().size(); i++) {
        initNode(
            node->add(obj["plugin"]["factory"].toString()),
            obj["children"][i].toObject());
    }

    return true;
}

bool ProjectSave::initPartitions(PartitionsModel *partitions, const QJsonArray &array)
{
    for (unsigned int i = 0; i < array.size(); i++) {
        partitions->add();
        QJsonObject partitionObj = array[i].toObject();
        PartitionModel *partition = partitions->get(i);
        if (!partition)
            continue;

        partition->setName(partitionObj["name"].toString());
        partition->setMuted(partitionObj["muted"].toBool());

        for (unsigned int y = 0; y < partitionObj["notes"].toArray().size(); y++) {
            QJsonObject noteObj = partitionObj["notes"].toArray()[y].toObject();
            Note note;

            note.range.from = noteObj["range"].toArray()[0].toInt();
            note.range.to = noteObj["range"].toArray()[1].toInt();
            note.key = noteObj["key"].toInt();
            note.velocity = noteObj["velocity"].toInt();
            note.tuning = noteObj["tuning"].toInt();
            partition->add(note);
        }

        for (unsigned int y = 0; y < partitionObj["instances"].toArray().size(); y++) {
            QJsonArray instance = partitionObj["instances"].toArray()[y].toArray();
            unsigned int from = instance[0].toInt();
            unsigned int to = instance[1].toInt();

            partition->instances().add(BeatRange({from, to}));
        }
    }
    return true;
}

bool ProjectSave::initControls(ControlsModel *controls, const QJsonArray &array)
{
    for (unsigned int i = 0; i < array.size(); i++) {
        QJsonObject controlObj = array[i].toObject();
        controls->add(controlObj["paramID"].toInt());

        ControlModel *control = controls->get(i);
        if (!control)
            continue;

        control->setMuted(controlObj["muted"].toBool());

        for (unsigned int y = 0; y < controlObj["automations"].toArray().size(); y++) {
            QJsonObject automationObj = controlObj["automations"].toArray()[y].toObject();

            control->add();
            AutomationModel *automation = control->get(y);
            if (!automation)
                continue;

            automation->setName(automationObj["name"].toString());
            automation->setMuted(automationObj["muted"].toBool());

            for (unsigned p = 0; p < automationObj["points"].toArray().size(); p++) {
                QJsonObject pointObj = automationObj["points"].toArray()[p].toObject();

                GPoint point;
                point.beat = pointObj["beat"].toInt();
                point.setType(static_cast<GPoint::CurveType>(QMetaEnum::fromType<GPoint::CurveType>().keyToValue(pointObj["beat"].toString().toStdString().c_str())));
                point.curveRate = pointObj["curveRate"].toInt();
                point.value = pointObj["value"].toDouble();
                automation->add(point);
            }

            for (unsigned p = 0; p < automationObj["instances"].toArray().size(); p++) {
                QJsonArray instance = automationObj["instances"].toArray()[p].toArray();
                unsigned int from = instance[0].toInt();
                unsigned int to = instance[1].toInt();

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
    } catch (const std::exception &e) {}

    auto arr = obj["controls"].toArray();
    for (auto it = arr.begin(); it != arr.end(); it++) {
        plugin->audioPlugin()->getControl(it[0].toInt()) = it[1].toDouble();
    }
    return true;
}
