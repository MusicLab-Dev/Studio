/**
 * @ Author: Cédric Lucchese
 * @ Description: Plugin Table Model class
 */

#pragma once

#include <QAbstractListModel>

#include <Core/Assert.hpp>
#include <Audio/PluginTable.hpp>


/** @brief Plugin Table Model class */
class PluginTableModel : public QAbstractListModel
{
    Q_OBJECT

public:
    /** @brief Roles of each instance */
    enum class Roles : int {
        Name = Qt::UserRole + 1,
        Description,
        Path,
        SDK,
        Tags
    };

    enum class ExternalInputType {
        None,
        Single,
        Multiple
    };
    Q_ENUM(ExternalInputType)

    /** @brief Default constructor */
    explicit PluginTableModel(QObject *parent = nullptr) noexcept;

    /** @brief Virtual destructor */
    ~PluginTableModel(void) noexcept override = default;


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return _data.factories().size(); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;


    /** @brief Get an factory instance */
    [[nodiscard]] Audio::IPluginFactory *get(const int index) const noexcept_ndebug;

public slots:
    /** @brief Add an new instance */
    void add(const QString &path);

    /** @brief Get the external input type of a factory */
    PluginTableModel::ExternalInputType getExternalInputType(const QString &path) const noexcept;

private:
    Audio::PluginTable &_data { Audio::PluginTable::Get() };
};
