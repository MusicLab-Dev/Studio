/**
 * @ Author: Cédric Lucchese
 * @ Description: DeviceModel class
 */

#pragma once

#include <memory>

#include <QObject>
#include <QAbstractListModel>

#include "Device.hpp"

/** @brief Device Model class */
class DeviceModel : public QAbstractListModel
{
    Q_OBJECT

public:
    /** @brief Roles of each instance */
    enum class Roles {
        Name = Qt::UserRole + 1,
        IsInput
    };

    /** @brief Default constructor */
    explicit DevideModel(QObject *parent = nullptr) noexcept;

    /** @brief Destruct the instance */
    ~DeviceModel(void) noexcept = default;


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return  _data->size(); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const noexcept override;

public slots:
    /** @brief Create a new DevicePtr instance */
    DevicePtr instantiate(const QString &name);

private:
    Audio::DeviceCapabilities _devices {};
};