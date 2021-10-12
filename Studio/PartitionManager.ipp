/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionManager
 */

inline QVariantList mapPartitionsToVariantList(const Audio::Partitions &partitions, const QString &partitionBaseName)
{
    QVariantList partitionList;

    for (auto i = 0u; i < partitions.size(); i++) {
        const auto &partition = partitions[i];
        QVariantMap mapPartition;

        QVariantList listNotes;
        for (auto j = 0u; j < partition.size(); j++) {
            QVariantMap mapNote;
            const auto note = partition[j];
            mapNote.insert("range", QVariantList({note.range.from, note.range.to}));
            mapNote.insert("key", note.key);
            mapNote.insert("velocity", note.velocity);
            mapNote.insert("tuning", note.tuning);
            listNotes.push_back(mapNote);
        }
        mapPartition.insert("beginOffset", 0);
        mapPartition.insert("beatDivider", "1/128");
        mapPartition.insert("type", "note");
        mapPartition.insert("name", partitionBaseName + " " + QString::number(i + 1));
        mapPartition.insert("data", listNotes);
        partitionList.push_back(mapPartition);
    }
    return partitionList;
}

inline bool PartitionManager::save(const Audio::Partitions &partitions, const QString &name) const
{
    QVariantMap map;

    map.insert("name", name);
    map.insert("partitions", mapPartitionsToVariantList(partitions, name));

    QJsonDocument doc(QJsonDocument::fromVariant(map));
    qDebug() << "[Studio] - PartitionManager: saving" << name << "collection...";
    try {
        write(doc.toJson(QJsonDocument::Compact));
        qDebug() << "[Studio] - PartitionManager: save success" << name;
    } catch (const std::logic_error &e) {
        qDebug() << "[Studio] - PartitionManager: saving failed " + QString(e.what());
        return false;
    }
    return true;
}

inline void PartitionManager::loadPartition(const QJsonValue &data, const QString &type, Audio::Partitions &partitions) const
{
    if (type == "note") {
        loadPartitionBasic(data, partitions);
    } else if (type == "chord") {
        loadPartitionChord(data, partitions);
    } else {
        throw std::logic_error("Invalid file: '" + _path.toStdString() + "' -> type property must be either 'note' or 'chord'");
    }
}

inline void PartitionManager::loadPartitionBasic(const QJsonValue &data, Audio::Partitions &partitions) const
{
    const auto divider = getBeatDivider(data["beatDivider"].toString());
    const auto offset = data["beginOffset"].toInt();
    const auto notes = data["data"].toArray();
    const auto noteCount = notes.count();
    Audio::Partition newPartition;

    // qDebug() << "  - notes:";
    for (auto i = 0; i < noteCount; ++i) {
        const auto note = notes[i];
        newPartition.push(Audio::Note {
            convertToBeatRange(note["range"][0].toInt() + offset, note["range"][1].toInt() + offset, divider),
            static_cast<Audio::Key>(note["key"].toInt()),
            static_cast<Audio::Velocity>(note["velocity"].toInt()),
            0
        });
        // qDebug() << "    -" << notes[i]["range"][0] << notes[i]["range"][1] << "-" << newPartition[i].range.from << newPartition[i].range.to;
        // qDebug() << "    -" << notes[i]["key"];
        // qDebug() << "    -" << notes[i]["velocity"];
        // qDebug() << "";
    }
    partitions.push(newPartition);
}

inline void PartitionManager::loadPartitionChord(const QJsonValue &data, Audio::Partitions &partitions) const
{
    const auto divider = getBeatDivider(data["beatDivider"].toString());
    const auto offset = data["beginOffset"].toInt();
    const auto chords = data["data"].toArray();
    const auto chordCount = chords.count();
    Audio::Partition newPartition;

    // qDebug() << "  - chords:";
    for (auto i = 0; i < chordCount; ++i) {
        const auto chord = chords[i];
        const auto keys = chord["key"].toArray();
        const auto velocities = chord["velocity"].toArray();
        if (keys.count() != velocities.count())
            throw std::logic_error("Invalid file: '" + _path.toStdString() + "' -> key and velocity properties must be array of the same size");

        const auto noteCount = keys.count();
        for (auto j = 0; j < noteCount; ++j) {
            newPartition.push(Audio::Note {
                convertToBeatRange(chord["range"][0].toInt() + offset, chord["range"][1].toInt() + offset, divider),
                static_cast<Audio::Key>(keys[j].toInt()),
                static_cast<Audio::Velocity>(velocities[j].toInt()),
                0
            });
        }
        // qDebug() << "    -" << chords[i]["range"][0] << chords[i]["range"][1] << "-" << newPartition[i].range.from << newPartition[i].range.to;
        // qDebug() << "    -" << chords[i]["key"];
        // qDebug() << "    -" << chords[i]["velocity"];
        // qDebug() << "";
    }
    partitions.push(newPartition);
}

inline Audio::Partitions PartitionManager::load(void) const
{
    Audio::Partitions partitions;

    try {
        QString jsonStr = read();
        if (jsonStr.isEmpty())
            return partitions;
        const auto doc = QJsonDocument::fromJson(jsonStr.toUtf8());
        if (!doc.isObject())
            throw std::logic_error("Invalid file: '" + _path.toStdString() + "'");
        const auto obj = doc.object();

        const auto collectionName = obj["name"].toString();
        qDebug() << "[Studio] - PartitionManager: loading" << collectionName << "collection...";
        // qDebug() << "partitions: ";
        if (!obj["partitions"].isArray())
            throw std::logic_error("Invalid file: '" + _path.toStdString() + "' -> data property must be an array");

        const auto parts = obj["partitions"].toArray();
        const auto partCount = parts.count();
        for (auto i = 0; i < partCount; ++i) {
            // qDebug() << "  -" << parts[i]["name"];
            // qDebug() << "  -" << parts[i]["type"];
            // qDebug() << "  -" << parts[i]["beatDivider"];
            // qDebug() << "  -" << parts[i]["beginOffset"];
            if (!parts[i]["data"].isArray())
                throw std::logic_error("Invalid file: '" + _path.toStdString() + "' -> notes property must be an array");
            loadPartition(parts[i], parts[i]["type"].toString(), partitions);
        }
        qDebug() << "[Studio] - PartitionManager: load success" << collectionName;
    } catch (const std::logic_error &e) {
        qDebug() << "[Studio] - PartitionManager: loading failed: " + QString(e.what());
    }
    return partitions;
}

inline float PartitionManager::getBeatDivider(const QString &divider) const
{
    const auto delim = divider.indexOf('/');
    if (delim <= 0 || delim == divider.size() - 1)
        throw std::logic_error("Invalid file: '" + _path.toStdString() + "' -> beatDivider format must be '1/N'");

    const QStringRef num(&divider, 0, delim);
    const QStringRef den(&divider, delim + 1, divider.size() - delim - 1);
    return num.toFloat() / den.toFloat();
}
