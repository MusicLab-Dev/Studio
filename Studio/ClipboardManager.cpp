/**
 * @ Author: Cédric Lucchese
 * @ Description: Clipboard Manager
 */

#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>

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
            BeatRange(Beat(noteObj["from"].toInt()), Beat(noteObj["to"].toInt())),
            Key(noteObj["key"].toInt()),
            Velocity(noteObj["velocity"].toInt()),
            Tuning(noteObj["tuning"].toInt())
        };
        notes.push_back(n);
    }
    return notes;
}
