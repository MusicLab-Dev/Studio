/*
 * @ Author: Matthieu Moinvaziri
 * @ Description: PluginTable Proxy
 */

#pragma once

#include <QSortFilterProxyModel>
#include <QDebug>

#include "PluginTableModel.hpp"

class PluginTableModelProxy : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(quint32 tagsFilter READ tagsFilter WRITE setTagsFilter NOTIFY tagsFilterChanged)
    Q_PROPERTY(QString nameFilter READ nameFilter WRITE setNameFilter NOTIFY nameFilterChanged)

public:
    /** @brief Constructor */
    PluginTableModelProxy(QObject *parent = nullptr) : QSortFilterProxyModel(parent) {}

    /** @brief Destructor */
    ~PluginTableModelProxy(void) override = default;

    /** @brief Get the tags filter property */
    [[nodiscard]] quint32 tagsFilter(void) const noexcept { return _tagsFilter; }

    /** @brief Set the tags filter property */
    void setTagsFilter(const quint32 tagsFilter) noexcept
    {
        if (_tagsFilter == tagsFilter)
            return;
        _tagsFilter = tagsFilter;
        emit tagsFilterChanged();
        invalidateFilter();
    }

    /** @brief Get the name filter property */
    [[nodiscard]] const QString &nameFilter(void) const noexcept { return _nameFilter; }

    /** @brief Set the name filter property */
    void setNameFilter(const QString &nameFilter) noexcept
    {
        if (_nameFilter == nameFilter)
            return;
        _nameFilter = nameFilter;
        emit nameFilterChanged();
        invalidateFilter();
    }

public slots:
    /** @brief Get the number of plugins that match a category */
    int getPluginsCount(PluginTableModel::Tags tags) const noexcept
    {
        auto *table = reinterpret_cast<const PluginTableModel *>(sourceModel());
        int count = 0;

        if (!table)
            return 0;
        for (auto i = 0, end = rowCount(); i < end; ++i) {
            QModelIndex proxyIdx = index(i, 0);
            QModelIndex sourceIdx = mapToSource(proxyIdx);
            if (static_cast<quint32>(table->get(sourceIdx.row())->getTags()) & static_cast<quint32>(tags))
                ++count;
        }
        return count;
    }


signals:
    /** @brief Notify that the tags filter property has changed */
    void tagsFilterChanged(void);

    /** @brief Notify that the name filter property has changed */
    void nameFilterChanged(void);

private:
    quint32 _tagsFilter { 0 };
    QString _nameFilter {};

    /** @brief Reimplementation of the filter virtual function */
    [[nodiscard]] bool filterAcceptsRow(int sourceRow, const QModelIndex &) const override
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
            if (!name.contains(_nameFilter)) {
                sName = factory->getDescription();
                name.clear();
                name = QString::fromLocal8Bit(sName.data(), static_cast<int>(sName.length()));
                if (!name.contains(_nameFilter))
                    return false;
            }
        }
        return true;
    }
};
