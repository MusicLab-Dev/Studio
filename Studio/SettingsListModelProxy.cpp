/**
 * @ Author: Cédric Lucchese
 * @ Description: Settings Model Proxy
 */

#include "SettingsListModelProxy.hpp"

bool SettingsListModelProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QModelIndex index0 = sourceModel()->index(sourceRow, 0, sourceParent);
    QVariant tags = sourceModel()->data(index0, SettingsListModel::Tags);
    QVariant category = sourceModel()->data(index0, SettingsListModel::Category);

    if (_category != "")
        if (category.toString().indexOf(_category, 0, Qt::CaseInsensitive) == -1)
            return false;
    if (_tags != "") {
        if (tags.canConvert<QVariantList>()) {
            QSequentialIterable iterable = tags.value<QSequentialIterable>();
            for (const QVariant& v: iterable) {
                if (v.toString().indexOf(_tags, 0, Qt::CaseInsensitive) != -1)
                    return true;
            }
            return false;
        }
    }
    return true;
}

bool SettingsListModelProxy::setTags(const QString &tags)
{
    if (_tags == tags)
        return false;
    _tags = tags;
    emit tagsChanged();
    invalidateFilter();
    return true;
}

bool SettingsListModelProxy::setCategory(const QString &category)
{
    if (_category == category)
        return false;
    _category = category;
    emit categoryChanged();
    invalidateFilter();
    return true;
}
