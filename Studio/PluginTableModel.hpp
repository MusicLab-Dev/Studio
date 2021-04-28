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

    /** @brief Factory tags */
    enum class Tags : std::uint32_t {
        Effect          = 1,
        Analyzer        = 1 << 1,
        Delay           = 1 << 2,
        Distortion      = 1 << 3,
        Dynamics        = 1 << 4,
        EQ              = 1 << 5,
        Filter          = 1 << 6,
        Spatial         = 1 << 7,
        Generator       = 1 << 8,
        Mastering       = 1 << 9,
        Modulation      = 1 << 10,
        PitchShift      = 1 << 11,
        Restoration     = 1 << 12,
        Reverb          = 1 << 13,
        Surround        = 1 << 14,
        Tools           = 1 << 15,
        Network         = 1 << 16,
        Drum            = 1 << 17,
        Instrument      = 1 << 18,
        Piano           = 1 << 20,
        Sampler         = 1 << 21,
        Synth           = 1 << 22,
        External        = 1 << 23
    };
    Q_ENUM(Tags)

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
