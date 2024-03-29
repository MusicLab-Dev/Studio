/*
 * @ Author: Matthieu Moinvaziri
 * @ Description: PluginTable Proxy
 */

#pragma once

#include <QSortFilterProxyModel>

#include "PluginTableModel.hpp"
#include "PluginModel.hpp"

class PluginTableModelProxy : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(int tagsFilter READ tagsFilter WRITE setTagsFilter NOTIFY tagsFilterChanged)
    Q_PROPERTY(QString nameFilter READ nameFilter WRITE setNameFilter NOTIFY nameFilterChanged)

public:
    /** @brief Constructor */
    PluginTableModelProxy(QObject *parent = nullptr) : QSortFilterProxyModel(parent) {}

    /** @brief Destructor */
    ~PluginTableModelProxy(void) override = default;

    /** @brief Get the tags filter property */
    [[nodiscard]] int tagsFilter(void) const noexcept { return _tagsFilter; }

    /** @brief Set the tags filter property */
    void setTagsFilter(const int tagsFilter) noexcept;

    /** @brief Get the name filter property */
    [[nodiscard]] const QString &nameFilter(void) const noexcept { return _nameFilter; }

    /** @brief Set the name filter property */
    void setNameFilter(const QString &nameFilter) noexcept;

public slots:
    /** @brief Get the number of plugins that match a category */
    int getPluginsCount(PluginModel::Tags tags) const noexcept;


signals:
    /** @brief Notify that the tags filter property has changed */
    void tagsFilterChanged(void);

    /** @brief Notify that the name filter property has changed */
    void nameFilterChanged(void);

private:
    int _tagsFilter { 0 };
    QString _nameFilter {};

    /** @brief Reimplementation of the filter virtual function */
    [[nodiscard]] bool filterAcceptsRow(int sourceRow, const QModelIndex &) const override;
};
