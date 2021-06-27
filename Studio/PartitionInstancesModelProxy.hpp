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
    PartitionInstancesModelProxy(QObject *parent = nullptr) : QSortFilterProxyModel(parent) {}

    /** @brief Destructor */
    ~PartitionInstancesModelProxy(void) override = default;

    /** @brief Get / Set the range property */
    [[nodiscard]] const BeatRange &range(void) noexcept { return _range; }
    void setRange(const BeatRange &range)
    {
        if (_range == range)
            return;
        _range = range;
        const auto rangeWidth = (_range.to - _range.from);
        const auto usedRangeWidth = rangeWidth + (rangeWidth & 1u);
        const auto rangeMargins = usedRangeWidth / 2u;
        const auto totalLoadedWidth = usedRangeWidth * 2u;

        if (_range.from < _filterRange.from || _range.to > _filterRange.to || totalLoadedWidth != _lastTheoricalFilterWidth) {
            if (rangeMargins <= _range.from)
                _filterRange.from = _range.from - rangeMargins;
            else
                _filterRange.from = 0u;
            _filterRange.to = _range.to + rangeMargins;
            _lastTheoricalFilterWidth = totalLoadedWidth;
            invalidateFilter();
        }

        emit rangeChanged();
    }

signals:
    /** @brief Notify that the range property has changed */
    void rangeChanged(void);

private:
    BeatRange _range {};
    BeatRange _filterRange {};
    Beat _lastTheoricalFilterWidth {};

    /** @brief Reimplementation of the filter virtual function */
    [[nodiscard]] bool filterAcceptsRow(int sourceRow, const QModelIndex &) const override
    {
        auto *source = reinterpret_cast<const PartitionInstancesModel *>(sourceModel());
        if (!source)
            return false;
        const auto &instance = source->get(sourceRow);
        return instance.range.from <= _filterRange.to && instance.range.to >= _filterRange.from;
    }
};
