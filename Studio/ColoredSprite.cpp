/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Colored sprite with animations
 */

#include <QPainter>

#include "ColoredSpriteManager.hpp"
#include "ColoredSprite.hpp"

ColoredSprite::~ColoredSprite(void)
{
    if (_playing)
        ColoredSpriteManager::Get()->unregisterSprite();
}

void ColoredSprite::setSource(const QString &value)
{
    if (value == _source)
        return;
    _source = value;
    emit sourceChanged();
    ColoredSpriteManager::Get()->query(_source, [value, this](const QString &path, const SpriteCache &cache) {
        if (value == path) {
            _image = cache.image;
            _pos = 0;
            _count = cache.frameCount;
            requestUpdate();
        }
    });
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
    if (++_pos >= _count)
        _pos = 0u;
    requestUpdate();
}

void ColoredSprite::paint(QPainter *painter)
{
    const auto imageSize = _image.height();
    const QRect dest(0, 0, width(), height());
    const QRect source(_pos * imageSize, 0, imageSize, imageSize);

    painter->setRenderHint(QPainter::RenderHint::Antialiasing);
    painter->setRenderHint(QPainter::SmoothPixmapTransform);
    painter->drawImage(dest, _image, source);
}
