/**
 * @ Author: Dorian Gonzalez
 * @ Description: InsatancesModel class
 */

#pragma once

#include <QAbstractListModel>

#include "Base.hpp"

/** @brief The studio is the instance running the application process */
class InstancesModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(Beat latestInstance READ latestInstance NOTIFY latestInstanceChanged)

public:
    /** @brief Roles of each instance */
    enum class Roles {
        From = Qt::UserRole + 1,
        To
    };

    /** @brief Default constructor */
    explicit InstancesModel(Audio::BeatRanges *beatRanges, QObject *parent = nullptr) noexcept;

    /** @brief Virtual destructor */
    ~InstancesModel(void) noexcept override = default;

    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return  static_cast<int>(_data->size()); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;


    /** @brief Get the current latest instance */
    [[nodiscard]] Beat latestInstance(void) const noexcept { return _latestInstance; }


    /** @brief Get instance at index */
    [[nodiscard]] const BeatRange &get(const int idx) const noexcept_ndebug;

    /** @brief Update internal data pointer if it changed */
    void updateInternal(Audio::BeatRanges *data);

    /** @brief Get the audio instances */
    [[nodiscard]] Audio::BeatRanges *audioInstances(void) noexcept { return _data; }
    [[nodiscard]] const Audio::BeatRanges *audioInstances(void) const noexcept { return _data; }

public slots:
    /** @brief Add instance */
    bool add(const BeatRange &range);

    /** @brief Find an instance in the list using a single beat point */
    int find(const quint32 beat) const noexcept;

    /** @brief Find an instance in the list using a two beat points */
    int findOverlap(const BeatRange &range) const noexcept;

    /** @brief Remove instance at index */
    bool remove(const int index);

    /** @brief Get instance at index */
    QVariant getInstance(const int index) const { return QVariant::fromValue(get(index)); }

    /** @brief Get All instances */
    QVariantList getInstances(void) const;

    /** @brief Set instance at index */
    void set(const int index, const BeatRange &range);

    /** @brief Add a group of notes */
    bool addRange(const QVariantList &notes);

    /** @brief Remove a group of notes */
    bool removeRange(const QVariantList &indexes);

    /** @brief Select all notes within a specified range (returns indexes) */
    QVariantList select(const BeatRange &range);

signals:
    /** @brief Notify that the latest instance of the list has changed */
    void latestInstanceChanged(void);

private:
    Audio::BeatRanges *_data { nullptr };
    Beat _latestInstance { 0u };
};
