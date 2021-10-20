/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Community API abstraction
 */

#pragma once

#include <memory>
#include <QObject>

class QNetworkReply;

class CommunityAPI : public QObject
{
    Q_OBJECT
public:
    /** @brief Name of the token file */
    static constexpr auto DefaultTokenFile = "LexoToken";

    /** @brief Url of the API */
    static constexpr auto BaseURL = "https://api.lexostudio.com/";


    /** @brief Cache of a pending upload */
    struct UploadCache
    {
        QString path {};
        QNetworkReply *reply { nullptr };
    };


    /** @brief Destructor */
    ~CommunityAPI(void) override;

    /** @brief Object constructor */
    CommunityAPI(QObject *parent = nullptr);


public slots:
    /** @brief Start the authentification request */
    void authentificate(const QString &username, const QString &password);

    /** @brief Request upload project */
    void requestUploadProject(const QString &projectPath, const QString &exportPath);


signals:
    /** @brief Notify that a request failed */
    void requestFailed(void);

    /** @brief Notify that the API must authentificate */
    void needAuthentification(void);

    /** @brief Notify that authentification is done */
    void authentificationSuccess(void);

    /** @brief Notify that authentification had an error */
    void authentificationFailed(void);

    /** @brief Notify that an upload failed */
    void uploadSuccess(void);

    /** @brief Notify that an upload failed */
    void uploadFailed(const QString &path);


private:
    std::unique_ptr<QNetworkAccessManager> _manager {};
    QByteArray _token {};
    QVector<QString> _pending {};
    QVector<QString> _uploadIds {};
    UploadCache _currentUpload {};
    QNetworkReply *_authentificationReply { nullptr };

    /** @brief Cancel all pending requests */
    void cancelAllRequests(void);

    /** @brief Start the upload of a single file */
    void startUpload(const QString &path);


    /** @brief Callback on authentification */
    void onAuthentificationReply(void);

    /** @brief Callback on authentification */
    void onUploadReply(void);

    /** @brief Load token from local storage */
    void loadToken(void);

    /** @brief Save token in local storage */
    void saveToken(void);
};