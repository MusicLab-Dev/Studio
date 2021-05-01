/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Settings Model
 */

#pragma once

#include <QAbstractListModel>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>

/** @brief Settings list model */
class SettingsListModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QStringList categories READ categories NOTIFY categoriesChanged)

public:
    /** @brief Path to the settings model file */
    static inline const QString SettingsPath = ":/Templates/SettingsModel.json";
    /** @brief Path to the lexo directory */
    static inline const QString LexoDir = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/Lexo/";
    /** @brief Path to the lexo settings directory */
    static inline const QString LexoSettingsDir = LexoDir + "Settings/";
    /** @brief Path to the default lexo settings values file */
    static inline const QString LexoDefaultSettingsPath = LexoSettingsDir + "UserSettings.json";

    /** @brief Settings model roles */
    enum Role {
        Category = Qt::UserRole + 1,
        ID,
        Name,
        Help,
        Tags,
        Type,
        CurrentValue,
        Values
    };

    /** @brief Settings model */
    struct Model
    {
        QString category;
        QString id;
        QString name;
        QString help;
        QVariantList tags;
        QString type;
        QVariant start;
        QVariant currentValue;
        QVariantList values;
    };

    /** @brief Constructor */
    explicit SettingsListModel(QObject *parent = nullptr) : QAbstractListModel(parent) { load(QString()); }

    /** @brief Destructor */
    virtual ~SettingsListModel(void) override = default;


    /** @brief Get model roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const override;

    /** @brief Get the row count of the model */
    [[nodiscard]] int rowCount(const QModelIndex & = QModelIndex()) const override
        { return static_cast<int>(_models.size()); }

    /** @brief Get role data */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    /** @brief Set current value data */
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    /** @brief Get the list of categories */
    [[nodiscard]] QStringList categories(void) const noexcept { return _categories; }

public slots:

    /** @brief set model currentValue */
    bool set(const QString &id, const QVariant &value) noexcept;

    /** @brief get currentValue from model */
    QVariant get(const QString &id) const noexcept;

    /** @brief Load settings from Strings into models */
    bool load(const QString &values) noexcept;

    /** @brief Save values from models into Values json file */
    bool saveValues(void) noexcept;

signals:
    /** @brief Notify when the categories change */
    void categoriesChanged(void);

private:
    QFile _jsonSettingsFile, _jsonValuesFile;
    QString _jsonSettingsStr, _jsonValuesStr;
    QVector<Model> _models {};
    QStringList _categories {};

    /** @brief Recursive function. Used into load() function */
    void parse(const QJsonObject &objSettings, QJsonObject &objValues, QString path);

    /** @brief Read the settings and values files into Strings.
     * If Settings file doesn't exist, throw an exception. */
    [[nodiscard]] bool read(const QString &values);
};
