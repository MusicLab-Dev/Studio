/**
 * @ Author: Cédric Lucchese
 * @ Description: Clipboard Manager
 */

#pragma once

#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>

#include "ClipboardManager.hpp"

QString ClipboardManager::transformNotesInJson(const QVector<Note> &notes) const noexcept
{
    QJsonDocument doc;
    QJsonObject master;
    QJsonArray arr;

    for (const Note &note : notes) {
        QJsonObject obj;
        obj.insert("from", int(note.range.from));
        obj.insert("to", int(note.range.to));
        obj.insert("key", note.key);
        obj.insert("velocity", note.velocity);
        obj.insert("tuning", note.tuning);
        arr.push_back(obj);
    }
    master.insert("notes", arr);
    doc.setObject(master);

    return doc.toJson(QJsonDocument::Compact);
}

QVector<Note> ClipboardManager::transformJsonInNotes(const QString &json) const noexcept
{
    QVector<Note> notes;
    QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());

    if (doc.isNull() || !doc.isObject())
        return notes;

    QJsonObject obj = doc.object();
    for (const auto &note : obj["notes"].toArray()) {
        auto noteObj = note.toObject();
        Note n {
            Audio::BeatRange(Audio::Beat(noteObj["from"].toInt()), Audio::Beat(noteObj["to"].toInt())),
            Audio::Key(noteObj["key"].toInt()),
            Audio::Velocity(noteObj["velocity"].toInt()),
            Audio::Tuning(noteObj["tuning"].toInt())
        };
        notes.push_back(n);
    }
    return notes;
}
