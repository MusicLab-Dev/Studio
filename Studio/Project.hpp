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
    Q_PROPERTY(PlaybackMode playbackMode READ playbackMode WRITE setPlaybackMode NOTIFY playbackModeChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString path READ path NOTIFY pathChanged)

public:
    /** @brief The different types of playback mode */
    enum class PlaybackMode : int {
        Production = static_cast<int>(Audio::Project::PlaybackMode::Production),
        Live = static_cast<int>(Audio::Project::PlaybackMode::Live),
        Partition = static_cast<int>(Audio::Project::PlaybackMode::Partition)
    };
    Q_ENUM(PlaybackMode)


    /** @brief Construct a new project instance */
    explicit Project(Audio::Project *project, QObject *parent = nullptr);


    /** @brief Get the master node */
    [[nodiscard]] NodeModel *master(void) noexcept { return &_master; }
    [[nodiscard]] const NodeModel *master(void) const noexcept { return &_master; }

    /** @brief Get the dummy node */
    [[nodiscard]] NodeModel *dummyNode(void) noexcept { return &_master; }
    [[nodiscard]] const NodeModel *dummyNode(void) const noexcept { return &_master; }


    /** @brief Get the playback mode */
    [[nodiscard]] PlaybackMode playbackMode(void) const noexcept { return static_cast<Project::PlaybackMode>(_data->playbackMode()); }

    /** @brief Set the playback mode, return true and emit playbackModeChanged on change */
    void setPlaybackMode(const PlaybackMode playbackMode) noexcept;


    /** @brief Get the project name */
    [[nodiscard]] QString name(void) const noexcept
        { return QString::fromLocal8Bit(_data->name().data(), _data->name().size()); }

    /** @brief Set the project name, return true and emit nameChanged on change */
    void setName(const QString &name) noexcept { _data->name() = name.toStdString(); }


    /** @brief Get the project path */
    [[nodiscard]] const QString &path(void) const noexcept { return _path; }

    /** @brief Set the project path, return true and emit pathChanged on change */
    void setPath(const QString &path) noexcept { _path = path; }


    /** @brief Load a project file */
    void load(const QString &path);

    /** @brief Save the project in its default file */
    void save(void);

    /** @brief Save the project in given file */
    void saveAs(const QString &path);


signals:
    /** @brief Notify when master node changed */
    void masterChanged(void);

    /** @brief Notify when dummy node changed */
    void dummyNodeChanged(void);

    /** @brief Notify when playback mode changed */
    void playbackModeChanged(void);

    /** @brief Notify when project name changed */
    void nameChanged(void);

    /** @brief Notify when project path changed */
    void pathChanged(void);

private:
    Audio::Project *_data { nullptr };
    QString _path {};
    NodeModel _master;


    /** @brief Instantiate the master node and return a pointer referencing to it */
    [[nodiscard]] Audio::Node *createMasterMixer(void);
};