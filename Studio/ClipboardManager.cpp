/**
 * @ Author: Cédric Lucchese
 * @ Description: Clipboard Manager
 */

#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>

#include "ClipboardManager.hpp"

void ClipboardManager::setState(const State &state) noexcept
{
    if (_state == state)
        return;
    _state = state;
    emit stateChanged();
}

void ClipboardManager::setCount(int count) noexcept
{
    if (_count == count)
        return;
    _count = count;
    emit countChanged();
}

void ClipboardManager::setPartitionInstanceNode(NodeModel *node) noexcept
{
    if (_partitionInstanceNode == node)
        return;
    _partitionInstanceNode = node;
    emit partitionInstanceNodeChanged();
}

QString ClipboardManager::notesToJson(const QVector<Note> &notes) noexcept
{
    QJsonDocument doc;
    QJsonObject master;
    QJsonArray arr;

    for (const auto &note : notes) {
        QJsonObject obj;
        obj.insert("from", static_cast<int>(note.range.from));
        obj.insert("to", static_cast<int>(note.range.to));
        obj.insert("key", static_cast<int>(note.key));
        obj.insert("velocity", static_cast<int>(note.velocity));
        obj.insert("tuning", static_cast<int>(note.tuning));
        arr.push_back(obj);
    }
    master.insert("notes", arr); 
    doc.setObject(master);
    
    return doc.toJson(QJsonDocument::Compact);
}

QVector<Note> ClipboardManager::jsonToNotes(const QString &json) const noexcept
{
    QVector<Note> notes;
    QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());

    if (doc.isNull() || !doc.isObject())
        return notes;

    QJsonObject obj = doc.object();
    for (const auto &note : obj["notes"].toArray()) {
        auto noteObj = note.toObject();
        Note n {
            BeatRange {
                static_cast<Beat>(noteObj["from"].toInt()),
                static_cast<Beat>(noteObj["to"].toInt())
            },
            static_cast<Key>(noteObj["key"].toInt()),
            static_cast<Velocity>(noteObj["velocity"].toInt()),
            static_cast<Tuning>(noteObj["tuning"].toInt())
        };
        notes.push_back(n);
    }
    return notes;
}


QString ClipboardManager::partitionInstancesToJson(const QVector<PartitionInstance> &instances) noexcept
{
    QJsonDocument doc;
    QJsonObject master;
    QJsonArray arr;

    for (const auto &instance : instances) {
        QJsonObject obj;
        obj.insert("partitionIndex", static_cast<int>(instance.partitionIndex));
        obj.insert("offset", static_cast<int>(instance.offset));
        obj.insert("from", static_cast<int>(instance.range.from));
        obj.insert("to", static_cast<int>(instance.range.to));
        arr.push_back(obj);
    }
    master.insert("partitionInstances", arr);
    doc.setObject(master);

    return doc.toJson(QJsonDocument::Compact);
}

QVector<PartitionInstance> ClipboardManager::jsonToPartitionInstances(const QString &json) const noexcept
{
    QVector<PartitionInstance> instances;
    QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());

    if (doc.isNull() || !doc.isObject())
        return instances;

    QJsonObject obj = doc.object();
    for (const auto &instance : obj["partitionInstances"].toArray()) {
        auto instanceObj = instance.toObject();
        PartitionInstance inst {
            static_cast<std::uint32_t>(instanceObj["partitionIndex"].toInt()),
            static_cast<Beat>(instanceObj["offset"].toInt()),
            BeatRange {
                static_cast<Beat>(instanceObj["from"].toInt()),
                static_cast<Beat>(instanceObj["to"].toInt())
            }
        };
        instances.push_back(inst);
    }
    return instances;
}
