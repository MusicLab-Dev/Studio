/**
 * @ Author: Cédric Lucchese
 * @ Description: DevicesModel class
 */

#pragma once

#include <memory>

#include <QObject>
#include <QAbstractListModel>

#include "Device.hpp"

/** @brief Device Model class */
class DevicesModel : public QAbstractListModel
{
    Q_OBJECT

public:
    /** @brief Roles of each instance */
    enum class Roles : int {
        Name = Qt::UserRole + 1,
        IsInput
    };

    /** @brief Default constructor */
    explicit DevicesModel(QObject *parent = nullptr) noexcept;

    /** @brief Destruct the instance */
    ~DevicesModel(void) noexcept = default;


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return  _data->size(); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

public slots:
    /** @brief Create a new DevicePtr instance */
    DevicePtr instantiate(const QString &name);

private:
    Audio::DeviceCapabilities _devices {};
};