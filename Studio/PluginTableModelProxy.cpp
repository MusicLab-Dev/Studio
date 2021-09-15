/*
 * @ Author: Matthieu Moinvaziri
 * @ Description: PluginTable Proxy
 */

#include "PluginTableModelProxy.hpp"


void PluginTableModelProxy::setTagsFilter(const int tagsFilter) noexcept
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
    const int tagsBits = static_cast<int>(tags);
    const int mask = (tagsBits & static_cast<int>(PluginModel::Tags::Group))
            | (tagsBits & static_cast<int>(PluginModel::Tags::Instrument))
            | (tagsBits & static_cast<int>(PluginModel::Tags::Effect));
    const int tagsWithoutMask = tagsBits & ~mask;
    for (int i = 0, end = table->count(); i < end; ++i) {
        const auto elemTags = static_cast<int>(table->get(i)->getTags());
        if (elemTags & mask && (!tagsWithoutMask || elemTags & tagsWithoutMask))
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
    if (_tagsFilter) {;
        const int tagsBits = _tagsFilter;
        const int mask = (tagsBits & static_cast<int>(PluginModel::Tags::Group))
                | (tagsBits & static_cast<int>(PluginModel::Tags::Instrument))
                | (tagsBits & static_cast<int>(PluginModel::Tags::Effect));
        const int tagsWithoutMask = tagsBits & ~mask;
        const int elemTags = static_cast<int>(factory->getTags());
        if (!(elemTags & mask && (!tagsWithoutMask || elemTags & tagsWithoutMask)))
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