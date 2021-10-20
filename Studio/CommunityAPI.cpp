/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Community API abstraction
 */

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QStandardPaths>
#include <QFile>

#include "CommunityAPI.hpp"

CommunityAPI::~CommunityAPI(void)
{
    saveToken();
}

CommunityAPI::CommunityAPI(QObject *parent)
    : QObject(parent), _manager(std::make_unique<QNetworkAccessManager>(this))
{
    loadToken();
}

void CommunityAPI::requestUploadProject(const QString &projectPath, const QString &exportPath)
{
    // Verify that we have a token


    // Start upload procedure
    _pending.push_back(exportPath);
    startUpload(projectPath);
}

void CommunityAPI::authentificate(const QString &username, const QString &password)
{
    if (_authentificationReply) {
        qCritical() << "CommunityAPI::authentificate: Authentification already in process";
        return;
    }

    const QByteArray headerValue = QString(username + ':' + password).toLocal8Bit().toBase64();
    QNetworkRequest request(QUrl(QString(BaseURL) + "/auth/signin"));

    request.setRawHeader("Authorization", "Basic " + headerValue);
    _authentificationReply = _manager->get(request);
    connect(_authentificationReply, &QNetworkReply::finished, this, &CommunityAPI::onAuthentificationReply);
    connect(_authentificationReply, &QNetworkReply::finished, _authentificationReply, &QNetworkReply::deleteLater);
}

void CommunityAPI::onAuthentificationReply(void)
{
    if (_authentificationReply->error() != QNetworkReply::NoError) {
        qDebug() << "CommunityAPI: Request error: " << _authentificationReply->errorString();
        qDebug() << _authentificationReply->readAll();
        _authentificationReply = nullptr;
        emit requestFailed();
        return;
    }
    qDebug() << _authentificationReply->readAll();
    _authentificationReply = nullptr;
}

void CommunityAPI::startUpload(const QString &path)
{
    _currentUpload.path = path;
    _currentUpload.reply = nullptr;

    // _currentUpload.reply = _manager->get(request);

    connect(_currentUpload.reply, &QNetworkReply::finished, this, &CommunityAPI::onUploadReply);
    connect(_currentUpload.reply, &QNetworkReply::finished, _currentUpload.reply, &QNetworkReply::deleteLater);
}

void CommunityAPI::onUploadReply(void)
{
    if (!_currentUpload.reply) {
        qCritical() << "CommunityAPI::onUploadReply: No upload pending";
        return;
    }

    // Retreive media id
    _uploadIds.push_back("1234");

    // Reset current upload
    _currentUpload.path = QString();
    _currentUpload.reply = nullptr;

    // Check if all uploads are done
    if (_pending.isEmpty()) {
        emit uploadSuccess();
        return;
    }

    // Process next pending upload
    const auto path = _pending.back();
    _pending.pop_back();
    startUpload(path);
}

void CommunityAPI::cancelAllRequests(void)
{

}

void CommunityAPI::loadToken(void)
{
    const QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + '/' + QString(DefaultTokenFile);
    QFile file(path);

    if (!file.open(QFile::ReadOnly)) {
        qCritical() << "CommunityAPI::loadToken: Couldn't open token file" << path;
        return;
    }
    _token = file.readAll();
}

void CommunityAPI::saveToken(void)
{
    if (_token.isEmpty())
        return;

    const QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + '/' + QString(DefaultTokenFile);
    QFile file(path);

    if (!file.open(QFile::WriteOnly)) {
        qCritical() << "CommunityAPI::saveToken: Couldn't open token file" << path;
        return;
    }
    if (!file.write(_token)) {
        qCritical() << "CommunityAPI::saveToken: Couldn't write token file" << path;
        return;
    }
}