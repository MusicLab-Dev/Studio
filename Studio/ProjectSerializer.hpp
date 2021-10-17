/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Project Serializer
 */

#pragma once

#include <QJsonObject>
#include <QJsonArray>

#include "Project.hpp"

namespace ProjectSerializer
{
    /** @brief Current version of the serializer */
    constexpr int CurrentSerializerVersion = 1;

    /** @brief Serialize a project */
    [[nodiscard]] QJsonObject Serialize(const Project &project) noexcept;

    /** @brief Serialize a node */
    [[nodiscard]] QJsonObject Serialize(const NodeModel &node) noexcept;

    /** @brief Serialize a plugin */
    [[nodiscard]] QJsonObject Serialize(const PluginModel &plugin) noexcept;

    /** @brief Serialize a list of automations */
    [[nodiscard]] QJsonArray Serialize(const AutomationsModel &automations) noexcept;

    /** @brief Serialize an automation */
    [[nodiscard]] QJsonArray Serialize(const AutomationModel &automation) noexcept;

    /** @brief Serialize a list of partitions */
    [[nodiscard]] QJsonArray Serialize(const PartitionsModel &partitions) noexcept;

    /** @brief Serialize a list of partition instances */
    [[nodiscard]] QJsonArray Serialize(const PartitionInstancesModel &instances) noexcept;

    /** @brief Serialize a partition instance */
    [[nodiscard]] QJsonObject Serialize(const PartitionInstance &instance) noexcept;

    /** @brief Serialize a partition */
    [[nodiscard]] QJsonObject Serialize(const PartitionModel &partition) noexcept;

    /** @brief Serialize a note */
    [[nodiscard]] QJsonObject Serialize(const Note &note) noexcept;

    /** @brief Serialize a point */
    [[nodiscard]] QJsonObject Serialize(const GPoint &point) noexcept;

    /** @brief Serialize a beat range */
    [[nodiscard]] QJsonArray Serialize(const Audio::BeatRange &range) noexcept;


    /** @brief Deserialize a project */
    [[nodiscard]] bool Deserialize(Project &project, const QJsonObject &serial);

    /** @brief Deserialize a node using its parent */
    [[nodiscard]] bool Deserialize(NodeModel &parent, const QJsonObject &serial);

    /** @brief Deserialize a plugin */
    [[nodiscard]] bool Deserialize(PluginModel &plugin, const QJsonObject &serial);

    /** @brief Deserialize a list of automations */
    [[nodiscard]] bool Deserialize(AutomationsModel &automations, const QJsonArray &serial);

    /** @brief Deserialize an automation */
    [[nodiscard]] bool Deserialize(const ParamID automationIndex, AutomationModel &automation, const QJsonArray &serial);

    /** @brief Deserialize a list of partitions */
    [[nodiscard]] bool Deserialize(PartitionsModel &partitions, const QJsonArray &serial);

    /** @brief Deserialize a list of partition instances */
    [[nodiscard]] bool Deserialize(PartitionInstancesModel &instances, const QJsonArray &serial);

    /** @brief Deserialize a partition instance */
    [[nodiscard]] bool Deserialize(PartitionInstance &instance, const QJsonObject &serial);

    /** @brief Deserialize a partition */
    [[nodiscard]] bool Deserialize(PartitionModel &partition, const QJsonObject &serial);

    /** @brief Deserialize a point */
    [[nodiscard]] bool Deserialize(GPoint &point, const QJsonObject &serial);

    /** @brief Deserialize a note */
    [[nodiscard]] bool Deserialize(Note &note, const QJsonObject &serial);

    /** @brief Deserialize a beat range */
    [[nodiscard]] bool Deserialize(Audio::BeatRange &range, const QJsonArray &serial);


    /** @brief Implementation of the deserialization of a project */
    [[nodiscard]] bool DeserializeProjectImpl(Project &project, const QJsonObject &serial);

    /** @brief Implementation of the deserialization of a node */
    [[nodiscard]] bool DeserializeNodeImpl(NodeModel &node, const QJsonObject &serial);


    /** @brief Utility used to serialize an array */
    template<typename Iterator>
    [[nodiscard]] QJsonArray SerializeArray(Iterator begin, const Iterator end) noexcept;

    /** @brief Utility used to serialize an array using a map function */
    template<typename Iterator, typename Functor>
    [[nodiscard]] QJsonArray SerializeArray(Iterator begin, const Iterator end, Functor &&functor) noexcept;

    /** @brief Utility used to serialize an array using a range and a get function */
    template<typename Range, typename Functor>
    [[nodiscard]] QJsonArray SerializeArray(const Range range, Functor &&functor) noexcept;
}

#include "ProjectSerializer.ipp"
