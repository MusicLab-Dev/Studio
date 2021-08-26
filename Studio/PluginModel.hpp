/**
 * @ Author: Cédric Lucchese
 * @ Description: PluginModel class
 */

#pragma once

#include <vector>

#include <QAbstractListModel>
#include <Core/UniqueAlloc.hpp>

#include <Audio/IPlugin.hpp>

#include "ControlEvent.hpp"

class NodeModel;

/** @brief class that contaign plugin's controls */
class PluginModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)
    Q_PROPERTY(QString path READ path NOTIFY pathChanged)

public:
    /** @brief Roles of each controls */
    enum class Roles : int {
        ParamID = Qt::UserRole + 1,
        Type,
        MinValue,
        MaxValue,
        StepValue,
        DefaultValue,
        Value,
        RangeNames,
        Title,
        Description,
        ShortName,
        UnitName
    };

    /** @brief Parameter type */
    enum class ParamType : int {
        Boolean,
        Integer,
        Floating,
        Enum
    };
    Q_ENUM(ParamType)

    /** @brief Default constructor */
    explicit PluginModel(Audio::IPlugin *plugin, QObject *parent = nullptr) noexcept;

    /** @brief Virtual destructor */
    ~PluginModel(void) noexcept override = default;


    /** @brief Get the parent node if it exists */
    [[nodiscard]] NodeModel *parentNode(void) noexcept
        { return reinterpret_cast<NodeModel *>(parent()); }


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return static_cast<int>(_data->getMetaData().controls.size()); }

    /** @brief Return the count of element in the model */
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Set a role */
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;


    /** @brief Get the title property */
    [[nodiscard]] QString title(void) const noexcept;

    /** @brief Get the description property */
    [[nodiscard]] QString description(void) const noexcept;

    /** @brief Get the path property */
    [[nodiscard]] QString path(void) const noexcept;

    /** @brief Get underlying audio plugin */
    [[nodiscard]] Audio::IPlugin *audioPlugin(void) noexcept { return _data; }
    [[nodiscard]] const Audio::IPlugin *audioPlugin(void) const noexcept { return _data; }

    /** @brief Notify that a control's value has changed */
    void processControlValueChanged(const ParamID paramID);

public slots:
    /** @brief Get a control's value */
    ParamValue getControl(const ParamID paramID) const noexcept
        { return _data->getControl(paramID); }

    /** @brief Set a control on the fly */
    void setControl(const ControlEvent &event);

signals:
    /** @brief Notify that the title has changed */
    void titleChanged(void);

    /** @brief Notify that the description has changed */
    void descriptionChanged(void);

    /** @brief Notify that the path has changed */
    void pathChanged(void);

    /** @brief Notify that a control has changed */
    void controlValueChanged(const ParamID paramID);

private:
    Audio::IPlugin *_data { nullptr };

    /** @brief Get the current language */
    [[nodiscard]] int language(void) const noexcept;

};