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
#include "ControlsModel.hpp"
#include "PluginModel.hpp"

class Project;

/** @brief The project own the main node and all the project data */
class ProjectSave
{
public:
    explicit ProjectSave(Project *project);

    ~ProjectSave();

    bool save(void);

    bool load(void);
private:
    QString read(void);
    void write(const QString &json);
    QVariantMap getNodeInVariantMap(NodeModel &node);
    QVariantList getPartitionsInVariantList(PartitionsModel &partitions) noexcept;
    QVariantList getControlsInVariantList(ControlsModel &controls) noexcept;
    QVariantMap getPluginInVariantMap(PluginModel &plugin) noexcept;

    Project *_project;
};