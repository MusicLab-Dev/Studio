/**
 * @ Author: Cédric Lucchese
 * @ Description: Project header
 */

#pragma once

#include <QObject>

#include <MLAudio/Project.hpp>

/** @brief The project own the main node and all the project data */
class Project : public QObject
{
    Q_OBJECT

    Q_PROPERTY(NodeModel *master READ master NOTIFY masterChanged)
    Q_PROPERTY(Audio::Project::PlaybackMode playbackMode READ playbackMode WRITE setPlaybackMode NOTIFY playbackModeChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString path READ path NOTIFY pathChanged)

public:
    /** @brief The different types of playback mode */
    enum class PlaybackMode
    {
        Production = Audio::Project::PlaybackMode::Production,
        Live = Audio::Project::PlaybackMode::Live
    };
    Q_ENUM(PlaybackMode)


    /** @brief Construct a new project instance */
    explicit Project(QObject *parent = nullptr);


    /** @brief Get the master node */
    [[nodiscard]] NodeModel *master(void) noexcept { return _master; }
    [[nodiscard]] NodeModel *master(void) const noexcept { return _master; }


    /** @brief Get the playback mode */
    [[nodiscard]] Project::PlaybackMode playbackMode(void) const noexcept { return _playbackMode};

    /** @brief Set the playback mode, return true and emit playbackModeChanged on change */
    bool setPlaybackMode(const PlaybackMode mode) noexcept;


    /** @brief Get the project name */
    const QString &name(void) const noexcept { return _name; }

    /** @brief Set the project name, return true and emit nameChanged on change */
    bool setName(const QString &name) noexcept;


    /** @brief Get the project path */
    const QString &path(void) const noexcept { return _path; }


    /** @brief Load a project file */
    void load(const QString &path);

    /** @brief Save the project in its default file */
    void save(void);

    /** @brief Save the project in given file */
    void saveAs(const QString &path);


signals:
    /** @brief Notify when master node changed */
    void masterChanged(void);

    /** @brief Notify when playback mode changed */
    void playbackModeChanged(void);

    /** @brief Notify when project name changed */
    void nameChanged(void);

    /** @brief Notify when project path changed */
    void pathChanged(void);

private:
    Audio::Project _data {};
    QString _path {};
    UniqueAlloc<NodeModel> _master { nullptr };
};