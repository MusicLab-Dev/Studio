/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Colored sprite with animations
 */

#pragma once

#include <QImage>
#include <QColor>
#include <QQuickPaintedItem>

#include "ColoredSpriteManager.hpp"

class ColoredSprite : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(bool playing READ playing WRITE setPlaying NOTIFY playingChanged)

public:
    /** @brief Destructor */
    ~ColoredSprite(void) override;

    /** @brief Constructor */
    ColoredSprite(QQuickItem *parent = nullptr) : QQuickPaintedItem(parent) {}


    /** @brief Get the source property */
    [[nodiscard]] const QString &source(void) const noexcept { return _source; }

    /** @brief Set the source property */
    void setSource(const QString &value);


    /** @brief Get the color property */
    [[nodiscard]] const QColor &color(void) const noexcept { return _color; }

    /** @brief Set the color property */
    void setColor(const QColor &value);


    /** @brief Get the playing property */
    [[nodiscard]] bool playing(void) const noexcept { return _playing; }

    /** @brief Set the playing property */
    void setPlaying(const bool value);


    /** @brief Callback called when the manager loaded the image */
    void onImageLoaded(const QString &path, const SpriteCache &cache);

signals:
    /** @brief Notify that the source property has changed */
    void sourceChanged(void);

    /** @brief Notify that the color property has changed */
    void colorChanged(void);

    /** @brief Notify that the playing property has changed */
    void playingChanged(void);

private:
    QString _source {};
    SpriteCache _cache {};
    QColor _color {};
    quint32 _pos { 0u };
    bool _playing { false };
    bool _loading { false };

    /** @brief Request an update */
    void requestUpdate(void) { update(); }

    /** @brief Callback called when the animation manger tick */
    void onAnimationTick(void);


    /** @brief Draw animated image */
    void paint(QPainter *painter) final;
};
