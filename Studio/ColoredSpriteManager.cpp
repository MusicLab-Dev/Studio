/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Colored sprite manager
 */

#include <QDebug>

#include "ColoredSpriteManager.hpp"

SpriteCache ImageLoaderThread::Load(const QString &path)
{
    SpriteCache cache;
    QImage image;

    if (!image.load(path)) {
        qCritical() << "ImageLoaderThread::Load: Couldn't load image at path" << path;
        return cache;
    }
    cache.frameCount = image.width() / image.height();
    cache.image = image;
    cache.lowResImage = cache.image.scaled(
        TargetRenderSize * cache.frameCount,
        TargetRenderSize,
        Qt::AspectRatioMode::KeepAspectRatio,
        Qt::TransformationMode::SmoothTransformation
    );
    return cache;
}

ImageLoaderThread::ImageLoaderThread(QObject *parent)
    : QThread(parent), _queue(DefaultQueueSize)
{
}

void ImageLoaderThread::run(void)
{
    QString path;
    std::uint32_t tryCount { 0u };

    while (true) {
        if (_queue.pop(path)) {
            imageLoaded(path, Load(path));
        } else {
            if (++tryCount == 10u)
                break;
            sleep(100);
        }
    }
}

ColoredSpriteManager::ColoredSpriteManager(QObject *parent)
    : QObject(parent), _timer(this), _thread(this)
{
    if (_Instance)
        throw std::logic_error("ColoredSpriteManager::ColoredSpriteManager: Instance already exists");
    _Instance = this;
    _timer.setTimerType(Qt::PreciseTimer);
    _timer.setInterval(TimerTickRate);
    connect(&_timer, &QTimer::timeout, this, &ColoredSpriteManager::animationTick);
    connect(&_thread, &ImageLoaderThread::imageLoaded, this, &ColoredSpriteManager::onImageLoaded);
    connect(&_thread, &ImageLoaderThread::finished, this, &ColoredSpriteManager::onThreadFinished);
}

void ColoredSpriteManager::registerSprite(void) noexcept
{
    if (!_playCount) {
        _timer.start();
    }
    ++_playCount;
}

void ColoredSpriteManager::unregisterSprite(void) noexcept
{
    if (!_playCount) {
        qCritical() << "ColoredSpriteManager::unregisterSprite: More sprite unregistered than registered";
        return;
    }
    --_playCount;
    if (!_playCount) {
        _timer.stop();
    }
}

void ColoredSpriteManager::onImageLoaded(const QString &path, const SpriteCache &cache)
{
    auto it = _loadTable.find(path);

    // Check if entry is still valid
    if (it == _loadTable.end()) {
        qCritical() << "ColoredSpriteManager::onImageLoaded: Image not found in load table" << path;
        return;
    }

    // Dispatch all events
    for (const auto &func : *it) {
        func(path, cache);
    }

    // Delete entry from the load table
    _loadTable.erase(it);

    // Store image
    _table.insert(path, cache);
}

void ColoredSpriteManager::onThreadFinished(void)
{
    if (!_loadTable.isEmpty()) {
        qDebug() << "ColoredSpriteManager::onThreadFinished: Thread finished but load table is not empty";
        _thread.start();
    } else {
        qDebug() << "ColoredSpriteManager::onThreadFinished: Loader thread finished";
    }
}
