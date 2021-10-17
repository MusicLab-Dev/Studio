/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Project Serializer
 */

#include "Application.hpp"
#include "ProjectSerializer.hpp"

#define DeserializeCritical() qWarning() << DeserializeMessage

#define DeserializeFindValue(iterator, serialString, serial, message) \
    const auto iterator = serial.find(serialString); \
    if (iterator == serial.end()) { \
        DeserializeCritical() << message ; \
        return false; \
    }

static const auto DeserializeMessage = "ProjectSerializer::Deserialize:";

static const auto DefaultProjectNameString = QLatin1String(Application::DefaultProjectName.data(), static_cast<int>(Application::DefaultProjectName.length()));

static const auto SerialVersion = QLatin1String("version");
static const auto SerialName = QLatin1String("name");
static const auto SerialBpm = QLatin1String("bpm");
static const auto SerialMaster = QLatin1String("master");
static const auto SerialColor = QLatin1String("color");
static const auto SerialMuted = QLatin1String("muted");
static const auto SerialPlugin = QLatin1String("plugin");
static const auto SerialPartitions = QLatin1String("partitions");
static const auto SerialAutomations = QLatin1String("automations");
static const auto SerialChildren = QLatin1String("children");
static const auto SerialPath = QLatin1String("path");
static const auto SerialExternalPaths = QLatin1String("externalPaths");
static const auto SerialControls = QLatin1String("controls");
static const auto SerialInstances = QLatin1String("instances");
static const auto SerialPartitionIndex = QLatin1String("partitionIndex");
static const auto SerialOffset = QLatin1String("offset");
static const auto SerialNotes = QLatin1String("notes");
static const auto SerialRange = QLatin1String("range");
static const auto SerialKey = QLatin1String("key");
static const auto SerialVelocity = QLatin1String("velocity");
static const auto SerialTuning = QLatin1String("tuning");
static const auto SerialBeat = QLatin1String("beat");
static const auto SerialCurveType = QLatin1String("curveType");
static const auto SerialCurveRate = QLatin1String("curveRate");
static const auto SerialValue = QLatin1String("value");

QJsonObject ProjectSerializer::Serialize(const Project &project) noexcept
{
    QJsonObject obj;

    obj.insert(SerialVersion, CurrentSerializerVersion);
    obj.insert(SerialName, project.name());
    obj.insert(SerialBpm, Scheduler::Get()->bpm());
    obj.insert(SerialMaster, Serialize(*project.master()));
    return obj;
}

QJsonObject ProjectSerializer::Serialize(const NodeModel &node) noexcept
{
    QJsonObject obj;

    obj.insert(SerialName, node.name());
    obj.insert(SerialColor, node.color().name(QColor::NameFormat::HexArgb));
    obj.insert(SerialMuted, node.muted());
    obj.insert(SerialPath, node.plugin()->path());
    obj.insert(SerialPlugin, Serialize(*node.plugin()));
    obj.insert(SerialAutomations, Serialize(*node.automations()));
    obj.insert(SerialPartitions, Serialize(*node.partitions()));
    obj.insert(SerialInstances, Serialize(*node.partitions()->instances()));
    obj.insert(SerialChildren, SerializeArray(node.count(), [&node](const auto idx) { return Serialize(*node.get(idx)); }));
    return obj;
}

QJsonObject ProjectSerializer::Serialize(const PluginModel &plugin) noexcept
{
    const auto flags = plugin.flags();
    const bool hasExternal = (static_cast<int>(flags) & static_cast<int>(PluginModel::Flags::SingleExternalInput))
            || static_cast<int>(flags) & static_cast<int>(PluginModel::Flags::MultipleExternalInputs);
    QJsonObject obj;
    QJsonArray paths;

    if (hasExternal) {
        const auto &externalPaths = plugin.audioPlugin()->getExternalPaths();
        paths = SerializeArray(externalPaths.begin(), externalPaths.end(), [](const auto &str) { return QString::fromStdString(str); });
    }
    obj.insert(SerialControls, SerializeArray(plugin.count(), [audioPlugin = plugin.audioPlugin()](const auto idx) { return audioPlugin->getControl(idx); }));
    obj.insert(SerialExternalPaths, paths);
    return obj;
}

QJsonArray ProjectSerializer::Serialize(const AutomationsModel &automations) noexcept
{
    return SerializeArray(automations.count(), [&automations](const auto idx) { return Serialize(*automations.get(idx)); });
}

QJsonArray ProjectSerializer::Serialize(const AutomationModel &automation) noexcept
{
    return SerializeArray(automation.count(), [&automation](const auto idx) { return Serialize(automation.get(idx)); });
}

QJsonArray ProjectSerializer::Serialize(const PartitionsModel &partitions) noexcept
{
    return SerializeArray(partitions.count(), [&partitions](const auto idx) { return Serialize(*partitions.get(idx)); });
}

QJsonArray ProjectSerializer::Serialize(const PartitionInstancesModel &instances) noexcept
{
    return SerializeArray(instances.count(), [&instances](const auto idx) { return Serialize(instances.get(idx)); });
}

QJsonObject ProjectSerializer::Serialize(const PartitionInstance &instance) noexcept
{
    QJsonObject obj;

    obj.insert(SerialPartitionIndex, static_cast<int>(instance.partitionIndex));
    obj.insert(SerialOffset, static_cast<int>(instance.offset));
    obj.insert(SerialRange, Serialize(instance.range));
    return obj;
}

QJsonObject ProjectSerializer::Serialize(const PartitionModel &partition) noexcept
{
    QJsonObject obj;

    obj.insert(SerialName, partition.name());
    obj.insert(SerialNotes, SerializeArray(partition.count(), [&partition](const auto idx) { return Serialize(partition.get(idx)); }));
    return obj;
}

QJsonObject ProjectSerializer::Serialize(const Note &note) noexcept
{
    QJsonObject obj;

    obj.insert(SerialRange, Serialize(note.range));
    obj.insert(SerialKey, note.key);
    obj.insert(SerialVelocity, note.velocity);
    obj.insert(SerialTuning, note.tuning);
    return obj;
}

QJsonObject ProjectSerializer::Serialize(const GPoint &point) noexcept
{
    QJsonObject obj;

    obj.insert(SerialBeat, static_cast<int>(point.beat));
    obj.insert(SerialCurveType, static_cast<int>(point.type));
    obj.insert(SerialCurveRate, point.curveRate);
    obj.insert(SerialValue, point.value);
    return obj;
}

QJsonArray ProjectSerializer::Serialize(const Audio::BeatRange &range) noexcept
{
    QJsonArray array;

    array.append(static_cast<int>(range.from));
    array.append(static_cast<int>(range.to));
    return array;
}

bool ProjectSerializer::Deserialize(Project &project, const QJsonObject &serial)
{
    DeserializeFindValue(version, SerialVersion, serial, "Couldn't deserialize project, version not found")
    DeserializeFindValue(name, SerialName, serial, "Couldn't deserialize project, name not found")
    DeserializeFindValue(bpm, SerialBpm, serial, "Couldn't deserialize project, bpm not found")
    DeserializeFindValue(master, SerialMaster, serial, "Couldn't deserialize project, master not found")

    if (const auto fileVersion = version->toInt(); fileVersion != CurrentSerializerVersion) {
        DeserializeCritical() << "File is encoded with seriliazer version" << fileVersion << "while the current version is " << CurrentSerializerVersion;
        return false;
    }
    project.setName(name->toString(DefaultProjectNameString));
    Scheduler::Get()->setBPM(bpm->toInt(120));
    if (!DeserializeProjectImpl(project, master->toObject())) {
        DeserializeCritical() << "Couldn't deserialize project, invalid master node";
        return false;
    }
    return true;
}

bool ProjectSerializer::Deserialize(NodeModel &parent, const QJsonObject &serial)
{
    DeserializeFindValue(path, SerialPath, serial, "Couldn't deserialize node, plugin path not found")
    NodeModel *target { nullptr };

    if (const auto pluginPath = path->toString(); pluginPath.isEmpty()) {
        DeserializeCritical() << "Invalid empty plugin path in children of parent" << parent.name();
        return false;
    } else {
        target = parent.add(pluginPath);
        if (!target) {
            DeserializeCritical() << "Couldn't create plugin with path" << pluginPath << "of parent" << parent.name();
            return false;
        }
    }
    return DeserializeNodeImpl(*target, serial);
}

bool ProjectSerializer::Deserialize(PluginModel &plugin, const QJsonObject &serial)
{
    Core::TinySmallVector<ControlEvent, 14> events;
    Audio::ExternalPaths paths;
    DeserializeFindValue(externalPaths, SerialExternalPaths, serial, "Couldn't deserialize plugin, external paths not found")
    DeserializeFindValue(controls, SerialControls, serial, "Couldn't deserialize plugin, controls not found")
    const auto controlsArray = controls->toArray();

    if (controlsArray.size() != plugin.count()) {
        DeserializeCritical() << "Mismatching controls count" << controlsArray.size() << "/" << plugin.count();
        return false;
    }

    const auto &meta = plugin.audioPlugin()->getMetaData();
    ParamID index = 0u;
    for (const auto &control : controlsArray) {
        auto &event = events.push();
        event.value = control.toDouble();
        event.paramID = index;
        const auto &controlMeta = meta.controls[static_cast<std::uint32_t>(index)];
        ++index;
        if (event.value < controlMeta.rangeValues.min || event.value > controlMeta.rangeValues.max)
            DeserializeCritical() << "Skiped invalid control value in plugin (" << plugin.parentNode()->name()
                    << "->" << QString::fromStdString(std::string(controlMeta.translations.names[0].text)) << ")";
        else
            plugin.setControl(event);
    }
    for (const auto &path : externalPaths->toArray()) {
        const auto str = path.toString();
        if (str.isEmpty()) {
            DeserializeCritical() << "Couldn't deserialize plugin, empty external path";
            return false;
        }
        paths.push(str.toStdString());
    }
    const auto flags = plugin.flags();
    const bool hasExternal = (static_cast<int>(flags) & static_cast<int>(PluginModel::Flags::SingleExternalInput))
            || static_cast<int>(flags) & static_cast<int>(PluginModel::Flags::MultipleExternalInputs);
    if (hasExternal)
        plugin.audioPlugin()->setExternalPaths(paths);
    else if (!paths.empty())
        DeserializeCritical() << "Plugin doesn't have external input capabilities, skiped external paths" << plugin.parentNode()->name();
    return true;
}

bool ProjectSerializer::Deserialize(AutomationsModel &automations, const QJsonArray &serial)
{
    if (automations.count() != serial.size()) {
        DeserializeCritical() << "Mismatching automation count" << serial.size() << "/" << automations.count();
        return false;
    }
    int index = 0;
    for (const auto &automation : serial) {
        auto &target = *automations.get(index);
        if (!Deserialize(static_cast<ParamID>(index), target, automation.toArray())) {
            DeserializeCritical() << "Couldn't deserialize automation list, invalid automation";
            return false;
        }
        ++index;
    }
    return true;
}

bool ProjectSerializer::Deserialize(const ParamID automationIndex, AutomationModel &automation, const QJsonArray &serial)
{
    const auto &meta = automation.parentAutomations()->parentNode()->plugin()->audioPlugin()->getMetaData();
    const auto &controlMeta = meta.controls[static_cast<std::uint32_t>(automationIndex)];

    for (const auto &point : serial) {
        GPoint target;
        if (!Deserialize(target, point.toObject())) {
            DeserializeCritical() << "Couldn't deserialize automation, invalid point";
            return false;
        }
        if (target.value < controlMeta.rangeValues.min || target.value > controlMeta.rangeValues.max) {
            DeserializeCritical() << "Invalid value in automation, skipped point (" << automation.parentAutomations()->parentNode()->name()
                    << "->" << QString::fromStdString(std::string(controlMeta.translations.names[0].text)) << ")";
            continue;
       }
        if (!automation.add(target)) {
            DeserializeCritical() << "Couldn't create a new point into automation";
            return false;
        }
    }
    return true;
}

bool ProjectSerializer::Deserialize(PartitionsModel &partitions, const QJsonArray &serial)
{
    for (const auto &partition : serial) {
        if (!partitions.add()) {
            DeserializeCritical() << "Couldn't create a new partition into partition list";
            return false;
        }
        if (!Deserialize(*partitions.get(partitions.count() - 1), partition.toObject())) {
            DeserializeCritical() << "Couldn't deserialize partition list, invalid partition";
            return false;
        }
    }
    return true;
}

bool ProjectSerializer::Deserialize(PartitionInstancesModel &instances, const QJsonArray &serial)
{
    QVector<PartitionInstance> list;
    int index = 0;

    list.resize(serial.size());
    for (const auto &instance : serial) {
        if (!Deserialize(list[index], instance.toObject())) {
            DeserializeCritical() << "Couldn't deserialize partition instances, invalid instance";
            return false;
        } else
            ++index;
    }
    const auto count = static_cast<std::uint32_t>(instances.parentPartitions()->count());
    if (!count) {
        if (!list.size())
            return true;
        DeserializeCritical() << "Unexpected partition instances when a node doesn't have any partition";
        return false;
    }
    for (const auto &instance : list) {
        if (instance.partitionIndex >= count) {
            DeserializeCritical() << "Couldn't deserialize partition instances, invalid partition index" << instance.partitionIndex;
            return false;
        }
    }
    if (!instances.addRange(list)) {
        DeserializeCritical() << "Couldn't add instances into partition instance list";
        return false;
    }
    return true;
}

bool ProjectSerializer::Deserialize(PartitionInstance &instance, const QJsonObject &serial)
{
    DeserializeFindValue(partitionIndex, SerialPartitionIndex, serial, "Couldn't deserialize partition instance, partition index not found")
    DeserializeFindValue(offset, SerialOffset, serial, "Couldn't deserialize partition instance, beat offset not found")
    DeserializeFindValue(range, SerialRange, serial, "Couldn't deserialize partition instance, beat range not found")

    instance.partitionIndex = static_cast<std::uint32_t>(partitionIndex->toInt(std::numeric_limits<std::uint32_t>::max()));
    instance.offset = static_cast<Beat>(offset->toInt(0));
    if (!Deserialize(instance.range, range->toArray())) {
        DeserializeCritical() << "Couldn't deserialize partition instance, invalid beat range";
        return false;
    }
    return true;
}

bool ProjectSerializer::Deserialize(PartitionModel &partition, const QJsonObject &serial)
{
    DeserializeFindValue(name, SerialName, serial, "Couldn't deserialize partition, name not found")
    DeserializeFindValue(notes, SerialNotes, serial, "Couldn't deserialize partition, notes not found")
    QVector<Note> list;
    const auto noteArray = notes->toArray();

    list.resize(noteArray.size());
    partition.setName(name->toString("Partition"));
    int index = 0;
    for (const auto &note : notes->toArray()) {
        auto &target = list[index];
        if (!Deserialize(target, note.toObject())) {
            DeserializeCritical() << "Couldn't deserialize partition, invalid note in partition" << partition.name();
            return false;
        }
        ++index;
    }
    if (!partition.addRange(list)) {
        DeserializeCritical() << "Couldn't add notes into partition";
        return false;
    }
    return true;
}

bool ProjectSerializer::Deserialize(GPoint &point, const QJsonObject &serial)
{
    DeserializeFindValue(beat, SerialBeat, serial, "Couldn't deserialize point, beat not found")
    DeserializeFindValue(type, SerialCurveType, serial, "Couldn't deserialize point, curve type not found")
    DeserializeFindValue(curveRate, SerialCurveRate, serial, "Couldn't deserialize point, curve rate not found")
    DeserializeFindValue(value, SerialValue, serial, "Couldn't deserialize point, value not found")

    point.beat = beat->toInt(0);
    point.type = static_cast<Audio::Point::CurveType>(type->toInt(0));
    point.curveRate = static_cast<Audio::Point::CurveRate>(curveRate->toInt(0));
    point.value = static_cast<ParamValue>(value->toDouble(0.0));
    return true;
}

bool ProjectSerializer::Deserialize(Note &note, const QJsonObject &serial)
{
    DeserializeFindValue(key, SerialKey, serial, "Couldn't deserialize note, key not found")
    DeserializeFindValue(velocity, SerialVelocity, serial, "Couldn't deserialize note, velocity not found")
    DeserializeFindValue(tuning, SerialTuning, serial, "Couldn't deserialize note, tuning not found")
    DeserializeFindValue(range, SerialRange, serial, "Couldn't deserialize note, beat range not found")

    if (!Deserialize(note.range, range->toArray())) {
        DeserializeCritical() << "Couldn't deserialize note, invalid beat range";
        return false;
    }
    note.key = static_cast<Key>(key->toInt(69));
    note.velocity = static_cast<Velocity>(velocity->toInt(static_cast<int>(std::numeric_limits<Velocity>::max())));
    note.tuning = static_cast<Tuning>(tuning->toInt(0));
    return true;
}

bool ProjectSerializer::Deserialize(Audio::BeatRange &range, const QJsonArray &serial)
{
    if (serial.size() != 2) {
        DeserializeCritical() << "Couldn't deserialize beat range, it must have 2 values, not" << serial.size();
        return false;
    }
    range.from = static_cast<Beat>(serial[0].toInt(0));
    range.to = static_cast<Beat>(serial[1].toInt(0));
    return true;
}

bool ProjectSerializer::DeserializeProjectImpl(Project &project, const QJsonObject &serial)
{
    DeserializeFindValue(path, SerialPath, serial, "Couldn't deserialize node, plugin path not found")
    NodePtr node;

    if (const auto pluginPath = path->toString(); pluginPath.isEmpty()) {
        DeserializeCritical() << "Invalid empty plugin path of master node";
        return false;
    } else {
        node = NodePtr::Make(project.createMaster(pluginPath.toStdString()), &project);
    }
    if (!DeserializeNodeImpl(*node, serial))
        return false;
    project.emplaceMaster(std::move(node));
    return true;
}

bool ProjectSerializer::DeserializeNodeImpl(NodeModel &node, const QJsonObject &serial)
{
    DeserializeFindValue(name, SerialName, serial, "Couldn't deserialize node, name not found")
    DeserializeFindValue(color, SerialColor, serial, "Couldn't deserialize node, color not found")
    DeserializeFindValue(muted, SerialMuted, serial, "Couldn't deserialize node, muted not found")
    DeserializeFindValue(plugin, SerialPlugin, serial, "Couldn't deserialize node, plugin not found")
    DeserializeFindValue(partitions, SerialPartitions, serial, "Couldn't deserialize node, partitions not found")
    DeserializeFindValue(instances, SerialInstances, serial, "Couldn't deserialize node, instances not found")
    DeserializeFindValue(automations, SerialAutomations, serial, "Couldn't deserialize node, automations not found")
    DeserializeFindValue(children, SerialChildren, serial, "Couldn't deserialize node, children not found")

    node.setName(name->toString());
    node.setColor(QColor(color->toString()));
    node.setMuted(muted->toBool(false));
    if (!Deserialize(*node.plugin(), plugin->toObject()))
        DeserializeCritical() << "Couldn't deserialize plugin of node" << node.name();
    else if (!Deserialize(*node.partitions(), partitions->toArray()))
        DeserializeCritical() << "Couldn't deserialize partitions of node" << node.name();
    else if (!Deserialize(*node.partitions()->instances(), instances->toArray()))
        DeserializeCritical() << "Couldn't deserialize partition instances of node" << node.name();
    else if (!Deserialize(*node.automations(), automations->toArray()))
        DeserializeCritical() << "Couldn't deserialize automations of node" << node.name();
    else {
        for (const auto child : children->toArray()) {
            if (!Deserialize(node, child.toObject())) {
                DeserializeCritical() << "Couldn't deserialize child of node" << node.name();
                return false;
            }
        }
        return true;
    }
    return false;
}
