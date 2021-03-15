/**
 * @ Author: Gonzalez Dorian
 * @ Description: Automation Model class
 */

#pragma once

#include <vector>

#include <QAbstractListModel>

#include <Core/UniqueAlloc.hpp>
#include <Audio/Automation.hpp>

#include "InstancesModel.hpp"
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
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

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


    /** @brief Get the muted property */
    [[nodiscard]] bool muted(void) const noexcept { return _data->muted(); }

    /** @brief Set the muted property */
    void setMuted(const bool muted);


    /** @brief Get the name property */
    [[nodiscard]] QString name(void) const noexcept
        { return QString::fromLocal8Bit(_data->name().data(), _data->name().size()); }

    /** @brief Set the name property */
    void setName(const QString &name);


    /** @brief Update the internal data */
    void updateInternal(Audio::Automation *data);

public slots:
    /** @brief Insert point at index */
    void add(const GPoint &point);

    /** @brief Remove point at index */
    void remove(const int index);

    /** @brief Get point from index */
    const GPoint &get(const int index) const;

    /** @brief Set point index */
    void set(const int index, const GPoint &point);

    /** @brief Get the internal list of instances */
    InstancesModel *getInstances(void) noexcept { return _instances.get(); }

signals:
    /** @brief Notify that the muted property has changed */
    void mutedChanged(void);

    /** @brief Notify that the name property has changed */
    void nameChanged(void);

private:
    Audio::Automation *_data { nullptr };
    Core::UniqueAlloc<InstancesModel> _instances;
};
