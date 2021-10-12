/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionManager
 */

#pragma once

#include <QString>
#include <QVariantMap>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
// #include <QDir>
// #include <QStandardPaths>

#include "Audio/Partitions.hpp"

/** @brief Helper and Process to save and load partition files */
class PartitionManager
{
public:
    /** @brief Constructor */
    explicit PartitionManager(const QString &path) : _path(path) {}

    /** @brief Save the partition into the JSON partition file */
    bool save(const Audio::Partitions &partitions, const QString &name = "partition set") const;

    /** @brief Load the partition from the JSON project file */
    Audio::Partitions load(void) const;


private:
    QString _path;

    /** @brief Read the partition file into a QString */
    [[nodiscard]] QString read(void) const;

    /** Write string into the JSON project file */
    void write(const QString &data) const;

    [[nodiscard]] float getBeatDivider(const QString &divider) const;

    [[nodiscard]] Audio::BeatRange convertToBeatRange(const int from, const int to, const float divider) const noexcept
    {
        return {
            static_cast<Audio::Beat>(static_cast<float>(from * Audio::BeatPrecision) * divider),
            static_cast<Audio::Beat>(static_cast<float>(to * Audio::BeatPrecision) * divider)
        };
    }

    void loadPartition(const QJsonValue &data, const QString &type, Audio::Partitions &partitions) const;

    void loadPartitionBasic(const QJsonValue &data, Audio::Partitions &partitions) const;
    void loadPartitionChord(const QJsonValue &data, Audio::Partitions &partitions) const;
};

#include "PartitionManager.ipp"
