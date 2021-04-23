/**
 * @ Author: Cédric Lucchese
 * @ Description: ProjectSave header
 */

#pragma once

#include <gtest/gtest.h>
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
#include "ControlsModel.hpp"
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

private:
    Project *_project;

    /** @brief Read the JSON project file in project and return String */
    QString read(void);

    /** Write string into the JSON project file */
    void write(const QString &json);

    /** @brief return node in QVariantMap */
    QVariantMap transformNodeInVariantMap(NodeModel &node);

    /** @brief return partitions in QVariantList */
    QVariantList transformPartitionsInVariantList(PartitionsModel &partitions) noexcept;

    /** @brief return controls in QVariantList */
    QVariantList transformControlsInVariantList(ControlsModel &controls) noexcept;

    /** @brief return partition in QVariantList */
    QVariantMap transformPluginInVariantMap(PluginModel &plugin) noexcept;

    /** @brief Init a node model by a QJsonObject */
    bool initNode(NodeModel *node, const QJsonObject &obj);

    /** @brief Init a partitions model model by a QJsonArray */
    bool initPartitions(PartitionsModel *partitions, const QJsonArray &obj);

    /** @brief Init a controls model model by a QJsonArray */
    bool initControls(ControlsModel *controls, const QJsonArray &obj);

    /** @brief Init a plugin model model by a QJsonObject */
    bool initPlugin(PluginModel *plugin, const QJsonObject &obj);

    FRIEND_TEST(ProjectSave, transformPartitionsInVariantList);
};