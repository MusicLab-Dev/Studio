/**
 * @ Author: Cédric Lucchese
 * @ Description: Main Application header
 */

#pragma once

#include <memory>

#include <QObject>

#include "Project.hpp"
// #include "DevicesModel.hpp"
// #include "PluginTableModel.hpp"
#include "Scheduler.hpp"

/** @brief Application class */
class Application : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Project *project READ project NOTIFY projectChanged)
    // Q_PROPERTY(DevicesModel *device READ device NOTIFY deviceChanged)
    // Q_PROPERTY(PluginTableModel *plugins READ plugins NOTIFY pluginsChanged)
    Q_PROPERTY(Scheduler *scheduler READ scheduler NOTIFY schedulerChanged)

public:
    static constexpr std::string_view DefaultProjectName = "My Project";
    static constexpr auto DefaultPlaybackMode = Audio::Project::PlaybackMode::Production;


    /** @brief Construct a new application */
    explicit Application(QObject *parent = nullptr);


    /** @brief Get the project */
    [[nodiscard]] Project *project(void) noexcept { return &_project; }

    /** @brief Get the audio device */
    // [[nodiscard]] DevicesModel *devices(void) noexcept { return &_devices; }

    /** @brief Get the list of plugins */
    // [[nodiscard]] PluginTableModel *plugins(void) noexcept { return &_plugins; }

    /** @brief Get the scheduler */
    [[nodiscard]] Scheduler *scheduler(void) noexcept { return &_scheduler; }

public slots:
    /** @brief Get the list of devices able to output audio */
    // [[nodiscard]] QStringList getOutputDeviceList(void) const noexcept;

    /** @brief Get the list of devices able to take audio as input */
    // [[nodiscard]] QStringList selectOutputDevice(const QString &device) const noexcept;

signals:
    /** @brief Notify that the project has changed */
    void projectChanged(void);

    /** @brief Notify that the audio device has changed */
    // void deviceChanged(void);

    /** @brief Notify that the plugin list has changed */
    // void plugingsChanged(void);

    /** @brief Notify that the project scheluder has changed */
    void schedulerChanged(void);

private:
    /** @brief Setup the internal scheduler */
    void setupScheduler(void);

private:
    Audio::ProjectPtr _backendProject;
    Scheduler _scheduler;
    Project _project;
    // std::unique_ptr<PluginTableModel> _plugins;
};
