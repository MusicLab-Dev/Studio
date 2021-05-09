/**
 * @ Author: Cédric Lucchese
 * @ Description: Settings Model Proxy
 */

#include "SettingsListModelProxy.hpp"

bool SettingsListModelProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QModelIndex index0 = sourceModel()->index(sourceRow, 0, sourceParent);
    QString name = sourceModel()->data(index0, static_cast<int>(SettingsListModel::Roles::Name)).toString();
    QVariant tags = sourceModel()->data(index0, static_cast<int>(SettingsListModel::Roles::Tags));
    QString category = sourceModel()->data(index0, static_cast<int>(SettingsListModel::Roles::Category)).toString();

    // Filter by tag
    if (_tags != "") {
        if (name.indexOf(_tags, 0, Qt::CaseInsensitive) != -1)
            return true;
        else if (category.indexOf(_tags, 0, Qt::CaseInsensitive) != -1)
            return true;
        QSequentialIterable iterable = tags.value<QSequentialIterable>();
        for (const QVariant &v: iterable) {
            if (v.toString().indexOf(_tags, 0, Qt::CaseInsensitive) != -1)
                return true;
        }
    // Filter by category only
    } else if (_category != "") {
        if (category.indexOf(_category, 0, Qt::CaseInsensitive) != -1)
            return true;
    }
    return false;
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
