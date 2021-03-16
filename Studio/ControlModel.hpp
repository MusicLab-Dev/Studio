/**
 * @ Author: Gonzalez Dorian
 * @ Description: Control Model class
 */

#pragma once

#include <vector>

#include <QAbstractListModel>

#include <Audio/Control.hpp>

#include "Point.hpp"
#include "AutomationModel.hpp"

class ControlModel;

struct ControlWrapper
{
    Q_GADGET

    Q_PROPERTY(ControlModel *instance MEMBER instance)
public:

    ControlModel *instance { nullptr };
};

Q_DECLARE_METATYPE(ControlWrapper)

/** @brief Exposes an audio control */
class ControlModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(ParamID paramID READ paramID WRITE setParamID)
    Q_PROPERTY(bool muted READ muted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(bool manualMode READ manualMode WRITE setManualMode NOTIFY manualModeChanged)
    Q_PROPERTY(GPoint manualPoint READ manualPoint WRITE setManualPoint NOTIFY manualPointChanged)

public:
    /** @brief Roles of each Control */
    enum class Roles : int {
        AutomationInstance = Qt::UserRole + 1
    };

    /** @brief Default constructor */
    explicit ControlModel(Audio::Control *control, QObject *parent = nullptr) noexcept;

    /** @brief Virtual destructor */
    ~ControlModel(void) noexcept override = default;


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Get the index controlModel */
    [[nodiscard]] const AutomationModel *get(const int index) const noexcept_ndebug;
    [[nodiscard]] AutomationModel *get(const int index) noexcept_ndebug
        { return const_cast<AutomationModel *>(std::as_const(*this).get(index)); }


    /** @brief Get PararmID */
    [[nodiscard]] ParamID paramID(void) const noexcept { return _data->paramID(); }

    /** @brief Set the muted property */
    void setParamID(const ParamID paramID);


    /** @brief Get the muted property */
    [[nodiscard]] bool muted(void) const noexcept { return _data->muted(); }

    /** @brief Set the muted property */
    void setMuted(const bool muted);


    /** @brief Get manual mode property */
    [[nodiscard]] bool manualMode(void) const noexcept { return _data->manualMode(); }

    /** @brief Set the manual mode property */
    void setManualMode(const bool muted);


    /** @brief Get manual point property */
    [[nodiscard]] const GPoint &manualPoint(void) const noexcept
        { return reinterpret_cast<const GPoint &>(_data->manualPoint()); }

    /** @brief Set the manual point property */
    void setManualPoint(const GPoint &manualPoint);


    /** @brief Update the internal data */
    void updateInternal(Audio::Control *data);

public slots:
    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return static_cast<int>(_automations.size()); }

    /** @brief Add a children to the list */
    void add(void);

    /** @brief Remove a children from the list */
    void remove(const int index);

    /** @brief Move Control from to */
    void move(const int from, const int to);

signals:
    /** @brief Notify that muted property has changed */
    void paramIDChanged(void);

    /** @brief Notify that muted property has changed */
    void mutedChanged(void);

    /** @brief Notify that muted property has changed */
    void manualModeChanged(void);

    /** @brief Notify that muted property has changed */
    void manualPointChanged(void);

public: // Allow external insert / remove
    using QAbstractListModel::beginRemoveRows;
    using QAbstractListModel::endRemoveRows;
    using QAbstractListModel::beginInsertRows;
    using QAbstractListModel::endInsertRows;

private:
    Audio::Control *_data { nullptr };
    Core::TinyVector<Core::UniqueAlloc<AutomationModel>> _automations {};

    /** @brief Refresh children AutomationModel addresses */
    void refreshAutomations(void);
};
