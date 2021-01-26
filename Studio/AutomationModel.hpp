/**
 * @ Author: Gonzalez Dorian
 * @ Description: Automation Model class
 */

#pragma once

#include <vector>

#include <QObject>
#include <QAbstractListModel>

#include <Core/Utils.hpp>
#include <Core/UniqueAlloc.hpp>
#include <Audio/Base.hpp>
#include <Audio/Automation.hpp>

#include "InstancesModel.hpp"
#include "Point.hpp"

/** @brief Exposes an audio automation */
class AutomationModel : public QAbstractListModel
{
    Q_OBJECT

public:
    /** @brief Roles of each Control */
    enum class Roles : int {
        Point = Qt::UserRole + 1
    };

    /** @brief Default constructor */
    explicit AutomationModel(Audio::Automation *automation, QObject *parent = nullptr) noexcept;

    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return static_cast<int>(_data->points().size()); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Modify a role from children */
    [[nodiscard]] bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    /** @brief Get the internal data pointer */
    [[nodiscard]] Audio::Automation *internal(void) noexcept { return _data; }
    [[nodiscard]] const Audio::Automation *internal(void) const noexcept { return _data; }

    /** @brief Get the instances */
    [[nodiscard]] InstancesModel &instances(void) noexcept { return *_instances; }
    [[nodiscard]] const InstancesModel &instances(void) const noexcept { return *_instances; }

    /** @brief Update the internal data */
    void updateInternal(Audio::Automation *data);

public slots:
    /** @brief Insert point at index */
    void add(const GPoint &point) noexcept;

    /** @brief Get the internal list of instances */
    [[nodiscard]] InstancesModel *getInstances(void) noexcept { return _instances.get(); }

public /* slots */:
    /** @brief Remove point at index */
    Q_INVOKABLE void remove(const int index) noexcept_ndebug;

    /** @brief Get point from index */
    Q_INVOKABLE [[nodiscard]] GPoint get(const int index) const noexcept_ndebug;

    /** @brief Set point index */
    Q_INVOKABLE void set(const int index, const GPoint &point) noexcept_ndebug;

private:
    Audio::Automation *_data { nullptr };
    Core::UniqueAlloc<InstancesModel> _instances;
};
