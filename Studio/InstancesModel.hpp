/**
 * @ Author: Dorian Gonzalez
 * @ Description: InsatancesModel class
 */

#pragma once

#include <QObject>
#include <QAbstractListModel>

#include <Audio/Core/Core/Utils.hpp>
#include <Audio/Base.hpp>

/** @brief The studio is the instance running the application process */
class InstancesModel : public QAbstractListModel
{
    Q_OBJECT

public:

    /** @brief Roles of each instance */
    enum Roles {
        From = Qt::UserRole + 1,
        To
    };

    /** @brief Default constructor */
    explicit InstancesModel(QObject *parent = nullptr) noexcept;

    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return  static_cast<int>(_data->size()); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Get a beat range from internal list */
    [[nodiscard]] const Audio::BeatRange &get(const int index) const noexcept_ndebug;

    /** @brief Update internal data pointer if it changed */
    void updateInternal(Audio::BeatRanges *data) { _data = data; }

    /** @brief Get internal data pointer */
    Audio::BeatRanges *internal(void) { return _data; }

public slots:
    /** @brief Add a children to the list */
    void add(const Audio::BeatRange &range) noexcept;

public /* slots */:
    /** @brief Remove a children from the list */
    Q_INVOKABLE void remove(const int index) noexcept_ndebug;

    /** @brief Move beatrange at index */
    Q_INVOKABLE void move(const int index, const Audio::BeatRange &range) noexcept_ndebug;

private:
    Audio::BeatRanges *_data;
};
