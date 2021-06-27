/**
 * @ Author: Cédric Lucchese
 * @ Description: ProjectSave header
 */

#pragma once

#include <QVariantMap>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QDir>
#include <QStandardPaths>

#include "Project.hpp"
#include "NodeModel.hpp"
#include "PartitionsModel.hpp"
#include "AutomationsModel.hpp"
#include "PluginModel.hpp"

class Project;

/** @brief Helper and Process to save and load project*/
class ProjectSave
{
public:
    /** @brief Constructor */
    explicit ProjectSave(Project *project);


    /** @brief Save the project into the JSON project file */
    bool save(void);

    /** @brief Load the project from the JSON project file */
    bool load(void);

public: // Reserved for unit tests
    /** @brief Return automations in QVariantList */
    QVariantList transformAutomationsInVariantList(AutomationsModel &automations) noexcept;

    /** @brief Return node in QVariantMap */
    QVariantMap transformNodeInVariantMap(NodeModel &node);

    /** @brief Return partitions in QVariantList */
    QVariantMap transformPartitionsInVariantMap(PartitionsModel &partitions) noexcept;

    /** @brief Return partition in QVariantList */
    QVariantMap transformPluginInVariantMap(PluginModel &plugin) noexcept;

    /** @brief Init a node model by a QJsonObject */
    bool initNode(NodeModel *node, const QJsonObject &obj);

    /** @brief Init a partitions model model by a QJsonObject */
    bool initPartitions(PartitionsModel *partitions, const QJsonObject &obj);

    /** @brief Init an automations model model by a QJsonArray */
    bool initAutomations(AutomationsModel *automations, const QJsonArray &obj);

    /** @brief Init a plugin model model by a QJsonObject */
    bool initPlugin(PluginModel *plugin, const QJsonObject &obj);

private:
    Project *_project { nullptr };

    /** @brief Read the JSON project file in project and return String */
    QString read(void);

    /** Write string into the JSON project file */
    void write(const QString &json);
};