/*
 * @ Author: Matthieu Moinvaziri
 * @ Description: PluginTable Proxy
 */

#pragma once

#include <QSortFilterProxyModel>

#include "PartitionInstancesModel.hpp"

class PartitionInstancesModelProxy : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(BeatRange range READ range WRITE setRange NOTIFY rangeChanged)

public:
    /** @brief Constructor */
    PartitionInstancesModelProxy(QObject *parent = nullptr);

    /** @brief Destructor */
    ~PartitionInstancesModelProxy(void) override = default;


    /** @brief Get / Set the range property */
    [[nodiscard]] const BeatRange &range(void) noexcept { return _range; }
    void setRange(const BeatRange &range);

signals:
    /** @brief Notify that the range property has changed */
    void rangeChanged(void);

private:
    BeatRange _range {};
    BeatRange _filterRange {};
    Beat _lastTheoricalFilterWidth {};

    /** @brief Reimplementation of the filter virtual function */
    [[nodiscard]] bool filterAcceptsRow(int sourceRow, const QModelIndex &) const override;
};
