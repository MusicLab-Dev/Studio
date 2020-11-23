/**
 * @ Author: Gonzalez Dorian
 * @ Description: Automation Model class
 */

#pragma once

#include <vector>

#include <QObject>
#include <QAbstractListModel>

#include <MLCore/Utils.hpp>
#include <MLCore/UniqueAlloc.hpp>
#include <MLAudio/Base.hpp>

struct Point : public Audio::Point
{
    Q_GADGET

    Q_ENUM(CurveType);

    Q_PROPERTY(Beat beat MEMBER beat)
    Q_PROPERTY(CurveType curveType MEMBER curveType)
};

/** @brief Exposes an audio automation */
class AutomationModel : public QAbstractListModel
{
    Q_OBJECT

public:
    /** @brief Roles of each Control */
    enum class Roles {
        Point = Qt::UserRole + 1
    };

    /** @brief Default constructor */
    explicit AutomationModel(QObject *parent, Audio::Automation *automation) noexcept;

    /** @brief Destruct the AutomationModel */
    ~AutomationModel(void) noexcept = default;

    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return  _data->size(); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Modify a role from children */
    [[nodiscard]] void setData(const QModelIndex &index, const QVariant &value, int role) override;

    /** @brief Get the internal data pointer */
    [[nodiscard]] Audio::Automation *getInternal(void) noexcept { return _data; }
    [[nodiscard]] const Audio::Automation *getInternal(void) const noexcept { return _data; }

    /** @brief Update the internal data */
    void updateIternal(Audio::Automation *data);

public slots:
    /** @brief Insert point at index */
    void add(const Point &point) noexcept;

    /** @brief Remove point at index */
    void remove(const int index) noexcept_ndebug;

    /** @brief Get point from index */
    [[nodiscard]] const Point &get(const int index) const noexcept_ndebug;

    /** @brief Set point index */
    void set(const int index, const Point &point) noexcept_ndebug;

private:
    Audio::Automation *_data { nullptr };
    Core::UniqueAlloc<InstancesModel> _instancesModel;
};