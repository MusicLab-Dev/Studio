/*
 * @ Author: Matthieu Moinvaziri
 * @ Description: PluginModel Proxy
 */

#include "PluginModelProxy.hpp"

void PluginModelProxy::addControl(const int index)
{
    if (_filterIndexes.indexOf(index) == -1) {
        _filterIndexes.append(index);
        invalidateFilter();
    }
}

void PluginModelProxy::removeControl(const int index)
{
    if (auto idx = _filterIndexes.indexOf(index); idx != -1) {
        _filterIndexes.remove(idx);
        invalidateFilter();
    }
}

bool PluginModelProxy::filterAcceptsRow(int sourceRow, const QModelIndex &) const
{
    return _filterIndexes.indexOf(sourceRow) != -1;
}