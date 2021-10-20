/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Community API abstraction
 */

#include <QNetworkRequest>
#include <QNetworkReply>
#include <QStandardPaths>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QHttpMultiPart>

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

    auto doc = QJsonDocument::fromJson(_authentificationReply->readAll());
    auto replyJson = doc.object();
    QString token = replyJson["data"].toObject()["token"].toString();
    qDebug() << token;

    _authentificationReply = nullptr;
    startUpload(token);
}

void CommunityAPI::startUpload(const QString &token)
{
    // _currentUpload.path = path;
    _currentUpload.reply = nullptr;

    enum FileType {
        Song = 0,
        Export
    };

    QString filePath("/home/paul/Downloads/TestFiles/warmup.wav");
    FileType fileType = filePath.endsWith(".wav") ? FileType::Song : FileType::Export;

    /* Read and load file data */
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "Failed to open file: " << file.errorString();
        return;
    }
    QByteArray fileContent(file.readAll());
    file.close();

    /* Create multipart */
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    /* Setup file part */
    QHttpPart filePart;
    QString fileExt(fileType == FileType::Song ? ".wav" : ".lexo");
    QString mimeType(fileType == FileType::Song ? "audio/wave" : "text/plain");
    filePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(mimeType));
    filePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\"file" + fileExt + "\""));
    filePart.setHeader(QNetworkRequest::ContentLengthHeader, fileContent.length());
    filePart.setBody(fileContent);

    multiPart->append(filePart);

    /* Setup request with authorization header */
    QNetworkRequest request(QUrl(QString(BaseURL) + "/files/" + (fileType == FileType::Song ? "song" : "export")));
    request.setRawHeader("Authorization", "Bearer " + token.toLocal8Bit());

    /* Start upload */
    _currentUpload.reply = _manager.get()->post(request, multiPart);
    multiPart->setParent(_currentUpload.reply);

    connect(_currentUpload.reply, &QNetworkReply::finished, this, &CommunityAPI::onUploadReply);
    connect(_currentUpload.reply, &QNetworkReply::finished, _currentUpload.reply, &QNetworkReply::deleteLater);
}

void CommunityAPI::onUploadReply(void)
{
    qDebug() << "onUploadReply";

    auto doc = QJsonDocument::fromJson(_currentUpload.reply->readAll());
    auto replyJson = doc.object();
    QString fileId = replyJson["data"].toObject()["fileId"].toString();
    qDebug() << fileId;

    return;

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