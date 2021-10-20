/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Community API abstraction
 */

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QHttpMultiPart>
#include <QDesktopServices>

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

bool CommunityAPI::requestUploadProject(const QString &projectPath, const QString &exportPath)
{
    // Verify that we have a token
    if (_token.isEmpty()) {
        emit needAuthentification();
        return false;
    }

    // Start upload procedure
    UploadCache cache {
        MediaType::Sound,
        exportPath
    };
    _pending.push_back(cache);
    startUpload(MediaType::Project, projectPath);
    return true;
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
        emit authentificationFailed();
        return;
    }

    auto doc = QJsonDocument::fromJson(_authentificationReply->readAll());
    auto replyJson = doc.object();
    _token = replyJson["data"].toObject()["token"].toString().toLocal8Bit();
    qDebug() << _token;

    _authentificationReply = nullptr;
    emit authentificationSuccess();
}

void CommunityAPI::startUpload(const MediaType type, const QString &path)
{
    _currentUpload = UploadCache {};

    /* Read and load file data */
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "Failed to open file: " << file.errorString();
        emit uploadFailed();
        return;
    }
    QByteArray fileContent { file.readAll() };
    file.close();

    /* Create multipart */
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    /* Setup file part */
    QHttpPart filePart;
    QString fileExt(type == MediaType::Sound ? ".wav" : ".lexo");
    QString mimeType(type == MediaType::Sound ? "audio/wave" : "text/plain");
    filePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(mimeType));
    filePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\"file" + fileExt + "\""));
    filePart.setHeader(QNetworkRequest::ContentLengthHeader, fileContent.length());
    filePart.setBody(fileContent);

    multiPart->append(filePart);

    /* Setup request with authorization header */
    QNetworkRequest request(QUrl(QString(BaseURL) + "/files/" + (type == MediaType::Sound ? "song" : "export")));
    request.setRawHeader("Authorization", "Bearer " + _token);

    /* Start upload */
    _currentUpload.type = type;
    _currentUpload.path = path;
    _currentUpload.reply = _manager.get()->post(request, multiPart);
    multiPart->setParent(_currentUpload.reply);

    connect(_currentUpload.reply, &QNetworkReply::finished, this, &CommunityAPI::onUploadReply);
    connect(_currentUpload.reply, &QNetworkReply::finished, _currentUpload.reply, &QNetworkReply::deleteLater);
}

void CommunityAPI::onUploadReply(void)
{
    if (!_currentUpload.reply) {
        qCritical() << "CommunityAPI::onUploadReply: No upload pending";
        return;
    } else if (_currentUpload.reply->error() != QNetworkReply::NoError) {
        qDebug() << "CommunityAPI: Request error: " << _currentUpload.reply->errorString();
        qDebug() << _currentUpload.reply->readAll();
        _currentUpload.reply = nullptr;
        emit uploadFailed();
        return;
    }

    auto doc = QJsonDocument::fromJson(_currentUpload.reply->readAll());
    auto replyJson = doc.object();
    QString fileId = replyJson["data"].toObject()["fileId"].toString();
    qDebug() << "File uploaded" << fileId;

    // Retreive media id
    _uploads.push_back(UploadedFile { _currentUpload.type, _currentUpload.path, fileId });

    // Reset current upload
    _currentUpload = UploadCache();

    // Check if all uploads are done
    if (_pending.isEmpty()) {
        emit uploadSuccess();
        launchBrowser();
        return;
    }

    // Process next pending upload
    const auto next = _pending.back();
    _pending.pop_back();
    startUpload(next.type, next.path);
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

    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + '/';
    const QString path = dir + QString(DefaultTokenFile);
    QDir().mkpath(dir);
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

void CommunityAPI::launchBrowser(void)
{
    if (_uploads.isEmpty()) {
        qCritical() << "CommunityAPI::launchBrowser: Invalid empy upload list";
        return;
    }
    QString parameters;

    for (const auto &upload : _uploads) {
        if (parameters.isEmpty())
            parameters.push_back('?');
        else
            parameters.push_back('&');
        if (upload.type == MediaType::Sound)
            parameters += "exportId=" + upload.fileId;
        else
            parameters += "mediaId=" + upload.fileId;
    }
    _uploads.clear();

    QString url = "https://community.lexostudio.com/#/home/" + parameters;
    qDebug() << "CommunityAPI::launchBrowser: Launching" << url;
    QDesktopServices::openUrl(QUrl(url));
}