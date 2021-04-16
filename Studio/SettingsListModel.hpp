/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Settings Model
 */

#pragma once

#include <QAbstractListModel>

#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>

/** @brief Settings list model */
class SettingsListModel : public QAbstractListModel
{
    Q_OBJECT
public:
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
    explicit SettingsListModel(QObject *parent = nullptr) : QAbstractListModel(parent) {}

    /** @brief Constructor */
    explicit SettingsListModel(const QString &settings, const QString &values, QObject *parent = nullptr) :
        QAbstractListModel(parent) { read(settings, values); }

    /** @brief Destructor */
    virtual ~SettingsListModel(void) override = default;


    /** @brief Get model roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const override;

    /** @brief Get the row count of the model */
    [[nodiscard]] int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /** @brief Get role data */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    /** @brief Set current value data */
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

public slots:

    /** @brief Load settings from Strings into models */
    bool load(const QString &settings, const QString &values) noexcept;

    /** @brief Save values from models into Values json file */
    bool saveValues(void) noexcept;

private:
    QFile _jsonSettingsFile, _jsonValuesFile;
    QString _jsonSettingsStr, _jsonValuesStr;
    QVector<Model> _models {};

    /** @brief Recursive function. Used into load() function */
    void parse(const QJsonObject &objSettings, QJsonObject &objValues, QString path);

    /** @brief Read the settings and values files into Strings.
     * If Settings file doesn't exist, throw an exception. */
    bool read(const QString &settings, const QString &values);
};
