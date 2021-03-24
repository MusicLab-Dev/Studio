/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Settings Model
 */

#pragma once

#include <QAbstractListModel>

/** @brief Settings list model */
class SettingsListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    /** @brief Settings model roles */
    enum Role {
        Category = Qt::UserRole + 1,
        Subcategory,
        Name,
        Description,
        Tags,
        Type,
        Value,
        Range
    };

    /** @brief Settings model */
    struct Model
    {
        QString category;
        QString subcategory;
        QString name;
        QString description;
        QStringList tags;
        QString type;
        QVariant value;
        QVariantList range;
    };


    /** @brief Data used to test the model without JSON */
    static inline const QVector<Model> DefaultData = {
        Model {
            category: "Audio",
            subcategory: "Device",
            name: "CheckBox Delegate",
            description: "Select the used output hardware device",
            tags: QStringList { "output" },
            type: "CheckBox",
            value: "0",
            range: QVariantList { "-50", "50", "25", "false" }
        },

        Model {
            category: "Audio",
            subcategory: "Device",
            name: "ComboBox Delegate",
            description: "Select the used output hardware device",
            tags: QStringList { "output" },
            type: "ComboBox",
            value: "0",
            range: QVariantList { "-50", "50", "25", "false" }
        },

        Model {
            category: "Audio",
            subcategory: "Device",
            name: "FloatingTextBox Delegate",
            description: "Select the used output hardware device",
            tags: QStringList { "output" },
            type: "FloatingTextBox",
            value: "0",
            range: QVariantList { "-50", "50", "25", "false" }
        },

        Model {
            category: "Audio",
            subcategory: "Device",
            name: "IntegerTextBox Delegate",
            description: "Select the used output hardware device",
            tags: QStringList { "output" },
            type: "IntegerTextBox",
            value: "0",
            range: QVariantList { "-50", "50", "25", "false" }
        },

        Model {
            category: "Audio",
            subcategory: "Device",
            name: "RadioButton Delegate",
            description: "Select the used output hardware device",
            tags: QStringList { "output" },
            type: "RadioButton",
            value: "0",
            range: QVariantList { "-50", "50", "25", "false" }
        },

        Model {
            category: "Audio",
            subcategory: "Device",
            name: "Slider Delegate",
            description: "Select the used output hardware device",
            tags: QStringList { "output" },
            type: "Slider",
            value: "0",
            range: QVariantList { "-50", "50", "25", "false" }
        },

        Model {
            category: "Audio",
            subcategory: "Device",
            name: "SpinBox Delegate",
            description: "Select the used output hardware device",
            tags: QStringList { "output" },
            type: "SpinBox",
            value: "0",
            range: QVariantList { "-50", "50", "25", "false" }
        },

        Model {
            category: "Audio",
            subcategory: "Device2",
            name: "TextBox Delegate",
            description: "Select the used output hardware device",
            tags: QStringList { "output" },
            type: "TextBox",
            value: "0",
            range: QVariantList { "-50", "50", "25", "false" }
        }
    };


    /** @brief Constructor */
    explicit SettingsListModel(QObject *parent = nullptr) : QAbstractListModel(parent) {}

    /** @brief Destructor */
    virtual ~SettingsListModel(void) override = default;


    /** @brief Get model roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const override;

    /** @brief Get the row count of the model */
    [[nodiscard]] int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /** @brief Get role data */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

private:
    QVector<Model> _models = DefaultData;
};