/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Colored sprite with animations
 */

#include <QPainter>

#include "ColoredSprite.hpp"

ColoredSprite::~ColoredSprite(void)
{
    if (const auto manager = ColoredSpriteManager::Get(); manager) {
        if (_loading)
            ColoredSpriteManager::Get()->cancelQuery(_source, this);
        if (_playing)
            ColoredSpriteManager::Get()->unregisterSprite();
    }
}

void ColoredSprite::setSource(const QString &value)
{
    if (value == _source)
        return;
    if (_loading)
        ColoredSpriteManager::Get()->cancelQuery(_source, this);
    _pos = 0u;
    _cache = SpriteCache();
    _source = value;
    emit sourceChanged();
    if (!_source.isEmpty()) {
        _loading = true;
        ColoredSpriteManager::Get()->query(_source, this);
    }
}

void ColoredSprite::setColor(const QColor &value)
{
    if (_color == value)
        return;
    _color = value;
    emit colorChanged();
    requestUpdate();
}

void ColoredSprite::setPlaying(const bool value)
{
    if (_playing == value)
        return;
    _playing = value;
    const auto manager = ColoredSpriteManager::Get();
    if (_playing) {
        manager->registerSprite();
        connect(manager, &ColoredSpriteManager::animationTick, this, &ColoredSprite::onAnimationTick);
    } else {
        manager->unregisterSprite();
        disconnect(manager, &ColoredSpriteManager::animationTick, this, &ColoredSprite::onAnimationTick);
        if (_pos != 0u) {
            _pos = 0u;
            requestUpdate();
        }
    }
    emit playingChanged();
}

void ColoredSprite::onAnimationTick(void)
{
    if (++_pos >= _cache.frameCount)
        _pos = 0u;
    requestUpdate();
}

void ColoredSprite::paint(QPainter *painter)
{
    const auto w = static_cast<int>(width());
    const auto h = static_cast<int>(height());

    if (_loading || _cache.image.isNull()) {
        painter->fillRect(0, 0, w, h, _color);
        return;
    }

    // Select the most favorable image
    QImage *target { nullptr };
    if (h - _cache.image.width() < h - _cache.lowResImage.height())
        target = &_cache.image;
    else
        target = &_cache.lowResImage;

    const auto imageSize = target->height();
    const QRect dest(0, 0, w, h);
    const QRect source(_pos * imageSize, 0, imageSize, imageSize);

//    painter->setRenderHint(QPainter::RenderHint::Antialiasing);
//    painter->setRenderHint(QPainter::SmoothPixmapTransform);

    painter->drawImage(dest, *target, source);
    painter->setCompositionMode(QPainter::CompositionMode_SourceIn);
    painter->fillRect(0, 0, w, h, _color);
}

void ColoredSprite::onImageLoaded(const QString &path, const SpriteCache &cache)
{
    if (_loading && _source == path) {
        _cache = cache;
        _pos = 0;
        requestUpdate();
        _loading = false;
    } else {
        qCritical() << "ColoredSprite::onImageLoaded: Not image was queried";
    }
}
