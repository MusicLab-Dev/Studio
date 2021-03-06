/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Automation Model class
 */

#pragma once

#include <vector>

#include <QAbstractListModel>

#include <Core/UniqueAlloc.hpp>
#include <Audio/Automation.hpp>

#include "Point.hpp"

class AutomationModel;

struct AutomationWrapper
{
    Q_GADGET

    Q_PROPERTY(AutomationModel *instance MEMBER instance)
public:

    AutomationModel *instance { nullptr };
};

Q_DECLARE_METATYPE(AutomationWrapper)

/** @brief Exposes an audio automation */
class AutomationModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(bool muted READ muted WRITE setMuted NOTIFY mutedChanged)

public:
    /** @brief Roles of each Control */
    enum class Roles : int {
        Point = Qt::UserRole + 1
    };

    /** @brief Default constructor */
    explicit AutomationModel(Audio::Automation *automation, QObject *parent = nullptr) noexcept;

    /** @brief Virtual destructor */
    ~AutomationModel(void) noexcept override = default;

    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;


    /** @brief Get point at index */
    [[nodiscard]] const GPoint &get(const int index) const noexcept_ndebug;


    /** @brief Get the muted property */
    [[nodiscard]] bool muted(void) const noexcept;

    /** @brief Set the muted property (can fail if no points is set in the automation which force muted to true) */
    void setMuted(const bool muted);


    /** @brief Update the internal data */
    void updateInternal(Audio::Automation *data);

public slots:
    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return static_cast<int>(_data->size()); }

    /** @brief Add point */
    bool add(const GPoint &point);

    /** @brief Remove point at index */
    bool remove(const int index);

    /** @brief Get point at index */
    QVariant getPoint(const int index) const { return QVariant::fromValue(get(index)); }

    /** @brief Set point at index */
    bool set(const int index, const GPoint &point);

    /** @brief Remove all points between a given range*/
    bool removeSelection(const BeatRange &range);

signals:
    /** @brief Notify that the muted property has changed */
    void mutedChanged(void);

    /** @brief Notify that the name property has changed */
    void nameChanged(void);

private:
    Audio::Automation *_data { nullptr };
};
