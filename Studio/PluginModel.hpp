/**
 * @ Author: Cédric Lucchese
 * @ Description: PluginModel class
 */

#pragma once

#include <vector>

#include <QAbstractListModel>
#include <Core/UniqueAlloc.hpp>

#include <Audio/IPlugin.hpp>

/** @brief class that contaign plugin's controls */
class PluginModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)

public:
    /** @brief Roles of each controls */
    enum class Roles : int {
        Value = Qt::UserRole + 1,
        Title,
        Description
    };

    /** @brief Default constructor */
    explicit PluginModel(Audio::IPlugin *plugin, QObject *parent = nullptr) noexcept;

    /** @brief Virtual destructor */
    ~PluginModel(void) noexcept override = default;


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return static_cast<int>(_data->getMetaData().controls.size()); }

    /** @brief Return the count of element in the model */
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;


        /** @brief Get the title property */
    [[nodiscard]] QString title(void) const noexcept
        { return QString::fromLocal8Bit(_data->getMetaData().translations.names[0].text.data(), _data->getMetaData().translations.names[0].text.size()); }

        /** @brief Get the description property */
    [[nodiscard]] QString description(void) const noexcept
        { return QString::fromLocal8Bit(_data->getMetaData().translations.descriptions[0].text.data(), _data->getMetaData().translations.descriptions[0].text.size()); }

signals:
    /** @brief Notify that the title has changed */
    void titleChanged(void);

    /** @brief Notify that the description has changed */
    void descriptionChanged(void);

private:
    Audio::IPlugin *_data { nullptr };
};