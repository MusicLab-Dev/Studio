/*
 * @ Author: Matthieu Moinvaziri
 * @ Description: PluginTable Proxy
 */

#include <QQmlEngine>

#include "PartitionInstancesModelProxy.hpp"

PartitionInstancesModelProxy::PartitionInstancesModelProxy(QObject *parent)
    : QSortFilterProxyModel(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

void PartitionInstancesModelProxy::setRange(const BeatRange &range)
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

bool PartitionInstancesModelProxy::filterAcceptsRow(int sourceRow, const QModelIndex &) const
{
    auto *source = reinterpret_cast<const PartitionInstancesModel *>(sourceModel());
    if (!source)
        return false;
    const auto &instance = source->get(sourceRow);
    return instance.range.from <= _filterRange.to && instance.range.to >= _filterRange.from;
}
