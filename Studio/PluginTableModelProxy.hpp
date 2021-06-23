/*
 * @ Author: Matthieu Moinvaziri
 * @ Description: PluginTable Proxy
 */

#pragma once

#include <QSortFilterProxyModel>

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
    void setTagsFilter(const quint32 tagsFilter) noexcept;

    /** @brief Get the name filter property */
    [[nodiscard]] const QString &nameFilter(void) const noexcept { return _nameFilter; }

    /** @brief Set the name filter property */
    void setNameFilter(const QString &nameFilter) noexcept;

public slots:
    /** @brief Get the number of plugins that match a category */
    int getPluginsCount(PluginTableModel::Tags tags) const noexcept;


signals:
    /** @brief Notify that the tags filter property has changed */
    void tagsFilterChanged(void);

    /** @brief Notify that the name filter property has changed */
    void nameFilterChanged(void);

private:
    quint32 _tagsFilter { 0 };
    QString _nameFilter {};

    /** @brief Reimplementation of the filter virtual function */
    [[nodiscard]] bool filterAcceptsRow(int sourceRow, const QModelIndex &) const override;
};
