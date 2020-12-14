/**
 * @ Author: Gonzalez Dorian
 * @ Description: Control Model class
 */

#pragma once

#include <vector>

#include <QObject>
#include <QAbstractListModel>

#include <Audio/Core/Core/Utils.hpp>
#include <Audio/Base.hpp>
#include <Audio/Control.hpp>

#include "AutomationModel.hpp"

/** @brief Exposes an audio control */
class ControlModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(bool _muted READ muted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(Audio::ParamID _paramID READ paramID)

public:
    /** @brief Roles of each Control */
    enum Roles {
        Automation = Qt::UserRole + 1,
        Muted
    };

    /** @brief Default constructor */
    explicit ControlModel(Audio::Control *control, QObject *parent = nullptr) noexcept;

    /** @brief Destruct the ControlModel */
    ~ControlModel(void) noexcept = default;

    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return _automations.size(); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Set a role of children */
    [[nodiscard]] bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    /** @brief Get the index controlModel */
    [[nodiscard]] const AutomationModel *get(const int index) const noexcept_ndebug;
    [[nodiscard]] AutomationModel *get(const int index) noexcept_ndebug
        { return const_cast<AutomationModel *>(std::as_const(*this).get(index)); }

    /** @brief Get PararmID */
    [[nodiscard]] Audio::ParamID paramID(void) const noexcept { return _data->paramID(); }

    /** @brief Get muted */
    [[nodiscard]] bool muted(void) const noexcept { return _data->muted(); }

    /** @brief Set the muted property */
    bool setMuted(const bool muted) noexcept;

    /** @brief Get the muted state of a child automation */
    [[nodiscard]] bool isAutomationMuted(const int index) const noexcept_ndebug;

    /** @brief Set the muted state of a child automation */
    bool setAutomationMutedState(const int index, const bool state) noexcept_ndebug;


    /** @brief Update the internal data */
    void updateInternal(Audio::Control *data);

public slots:
    /** @brief Add a children to the list */
    void add(void);

public /* slots */:

    /** @brief Remove a children from the list */
    Q_INVOKABLE void remove(const int index) noexcept_ndebug;

    /** @brief Move Control from to */
    Q_INVOKABLE void move(const int from, const int to) noexcept_ndebug;

signals:
    /** @brief Notify that muted property has changed */
    void mutedChanged(void);

private:
    Audio::Control *_data { nullptr };
    Core::Vector<Core::UniqueAlloc<AutomationModel>> _automations {};

    /** @brief Refresh children AutomationModel addresses */
    void refreshAutomations(void);
};
