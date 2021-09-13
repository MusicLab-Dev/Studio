/*
 * @ Author: Matthieu Moinvaziri
 * @ Description: PluginTable Proxy
 */

#include "PluginTableModelProxy.hpp"


void PluginTableModelProxy::setTagsFilter(const quint32 tagsFilter) noexcept
{
    if (_tagsFilter == tagsFilter)
        return;
    _tagsFilter = tagsFilter;
    emit tagsFilterChanged();
    invalidateFilter();
}

void PluginTableModelProxy::setNameFilter(const QString &nameFilter) noexcept
{
    if (_nameFilter == nameFilter)
        return;
    _nameFilter = nameFilter;
    emit nameFilterChanged();
    invalidateFilter();
}

int PluginTableModelProxy::getPluginsCount(PluginModel::Tags tags) const noexcept
{
    auto *table = reinterpret_cast<const PluginTableModel *>(sourceModel());
    int count = 0;

    if (!table)
        return 0;
    for (auto i = 0, end = rowCount(); i < end; ++i) {
        QModelIndex proxyIdx = index(i, 0);
        QModelIndex sourceIdx = mapToSource(proxyIdx);
        if (static_cast<int>(table->get(sourceIdx.row())->getTags()) & static_cast<int>(tags))
            ++count;
    }
    return count;
}

bool PluginTableModelProxy::filterAcceptsRow(int sourceRow, const QModelIndex &) const
{
    auto *table = reinterpret_cast<const PluginTableModel *>(sourceModel());
    if (!table)
        return false;

    auto factory = table->get(sourceRow);

    if (!factory)
        return false;
    if (_tagsFilter) {
        if (!(static_cast<quint32>(factory->getTags()) & _tagsFilter))
            return false;
    }
    if (!_nameFilter.isEmpty()) {
        auto sName = factory->getName();
        QString name = QString::fromLocal8Bit(sName.data(), static_cast<int>(sName.length()));
        if (!name.contains(_nameFilter, Qt::CaseInsensitive)) {
            sName = factory->getDescription();
            name = QString::fromLocal8Bit(sName.data(), static_cast<int>(sName.length()));
            if (!name.contains(_nameFilter, Qt::CaseInsensitive))
                return false;
        }
    }
    return true;
}