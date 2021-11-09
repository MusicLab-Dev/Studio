/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Colored sprite manager
 */

#include <QDebug>

#include "ColoredSpriteManager.hpp"
#include "ColoredSprite.hpp"

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
//    qDebug() << "ImageLoaderThread::run: Thread started";
    QString path;
    std::uint32_t tryCount { 0u };

    while (!_forceExit) {
        if (_queue.pop(path)) {
//            qDebug() << "ImageLoaderThread::run: Extracted work" << path;
            imageLoaded(path, Load(path));
            tryCount = 0u;
        } else {
            if (++tryCount == 10u)
                break;
            msleep(100);
        }
    }
//    qDebug() << "ImageLoaderThread::run: Thread exited";
}


ColoredSpriteManager::~ColoredSpriteManager(void)
{
    _thread.forceExit();
    _thread.wait();
    _Instance = nullptr;
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

void ColoredSpriteManager::query(const QString &path, ColoredSprite *instance)
{
    auto tableIt = _table.find(path);

    if (tableIt != _table.end()) {
        instance->onImageLoaded(path, *tableIt);
        return;
    }

    auto it = _loadTable.find(path);

    if (it != _loadTable.end()) {
        it->push(instance);
    } else {
        it =_loadTable.insert(path, LoadCache { instance });
        if (!_thread.queue().push(path)) {
            // Push failed in async queue, we must load synchronously
            qWarning() << "ColoredSpriteManager::query: Thread async queue is full, loading synchronously" << path;
            _loadTable.erase(it);
            const auto cache = ImageLoaderThread::Load(path);
            instance->onImageLoaded(path, cache);
            _table.insert(path, cache);
        } else {
            if (!_thread.isRunning())
               _thread.start();
        }
    }
}

void ColoredSpriteManager::cancelQuery(const QString &path, ColoredSprite *instance)
{
    auto it = _loadTable.find(path);

    if (it == _loadTable.end()) {
        qCritical() << "ColoredSpriteManager::cancelQuery: Couldn't retreive query" << path;
        return;
    }
    const auto instanceIt = it->find(instance);
    if (instanceIt != it->end())
        it->erase(instanceIt);
    else
        qCritical() << "ColoredSpriteManager::cancelQuery: Couldn't find instance in query" << path;
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
    for (const auto instance : *it) {
        instance->onImageLoaded(path, cache);
    }

    // Delete entry from the load table
    _loadTable.erase(it);

    // Store image
    _table.insert(path, cache);
}

void ColoredSpriteManager::onThreadFinished(void)
{
    if (!_loadTable.isEmpty()) {
        _thread.start();
    }
}
