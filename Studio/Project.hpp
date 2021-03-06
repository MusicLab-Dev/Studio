/**
 * @ Author: Cédric Lucchese
 * @ Description: Project header
 */

#pragma once

#include <QObject>

#include <Core/UniqueAlloc.hpp>
#include <Audio/Project.hpp>

#include "NodeModel.hpp"

/** @brief The project own the main node and all the project data */
class Project : public QObject
{
    Q_OBJECT

    Q_PROPERTY(NodeModel *master READ master NOTIFY masterChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)

public:
    /** @brief Construct a new project instance */
    explicit Project(Audio::Project *project, QObject *parent = nullptr);


    /** @brief Get the master node */
    [[nodiscard]] NodeModel *master(void) noexcept { return _master.get(); }
    [[nodiscard]] const NodeModel *master(void) const noexcept { return _master.get(); }


    /** @brief Get the project name */
    [[nodiscard]] QString name(void) const noexcept
        { return QString::fromLocal8Bit(_data->name().data(), static_cast<int>(_data->name().size())); }

    /** @brief Set the project name, return true and emit nameChanged on change */
    void setName(const QString &name) noexcept;

    /** @brief Get the project path */
    [[nodiscard]] const QString &path(void) const noexcept { return _path; }

    /** @brief Set the project path, return true and emit pathChanged on change */
    void setPath(const QString &path) noexcept;

    /** @brief Instantiate a new master node */
    void recreateMasterMixer(void);

public slots:
    /** @brief Load a project file from a given path */
    bool loadFrom(const QString &path) noexcept;

    /** @brief Save the project in its default file */
    bool save(void) noexcept;

    /** @brief Save the project in given file */
    bool saveAs(const QString &path) noexcept;

    /** @brief clear the project */
    void clear(void) noexcept;

signals:
    /** @brief Notify when master node changed */
    void masterChanged(void);

    /** @brief Notify when project name changed */
    void nameChanged(void);

    /** @brief Notify when project path changed */
    void pathChanged(void);

private:
    Audio::Project *_data { nullptr };
    QString _path {};
    std::unique_ptr<NodeModel> _master;

    /** @brief Instantiate the master node and return a pointer referencing to it */
    [[nodiscard]] Audio::Node *createMasterMixer(void);
};
