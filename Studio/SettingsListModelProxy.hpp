/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Settings model proxy
 */

#pragma once

#include <QSortFilterProxyModel>

#include "SettingsListModel.hpp"

class SettingsListModelProxy : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QString tags READ tags WRITE setTags NOTIFY tagsChanged)
    Q_PROPERTY(QString category READ category WRITE setCategory NOTIFY categoryChanged)

public:
    /** @brief Constructor */
    explicit SettingsListModelProxy(QObject *parent = nullptr) : QSortFilterProxyModel(parent) {
        setSourceModel(new SettingsListModel(this));
    }

    /** @brief Destructor */
    virtual ~SettingsListModelProxy(void) override = default;

    /** @brief Filter each row */
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;


    /** @brief Get tags property */
    [[nodiscard]] const QString &tags(void) const noexcept
        { return _tags; }

    /** @brief Set the filter tag property */
    bool setTags(const QString &tags);


    /** @brief Get category property */
    [[nodiscard]] const QString &category(void) const noexcept
        { return _category; }

    /** @brief Set the filter tag property */
    bool setCategory(const QString &category);

signals:
    /** @brief Notify that the filter tag has changed */
    void tagsChanged(void);

    /** @brief Notify that the category has changed */
    void categoryChanged(void);

private:
    QString _tags;
    QString _category;
};