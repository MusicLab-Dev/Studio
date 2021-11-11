/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Automation preview
 */

#pragma once

#include <QQuickPaintedItem>

#include "Base.hpp"

class AutomationModel;

class AutomationPreview : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(AutomationModel *target READ target WRITE setTarget NOTIFY targetChanged)
    Q_PROPERTY(BeatRange range READ range WRITE setRange NOTIFY rangeChanged)
    Q_PROPERTY(qreal pixelsPerBeatPrecision READ pixelsPerBeatPrecision WRITE setPixelsPerBeatPrecision NOTIFY pixelsPerBeatPrecisionChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(bool isAccent READ isAccent WRITE setIsAccent NOTIFY isAccentChanged)

public:
    /** @brief Constructor */
    AutomationPreview(QQuickItem *parent = nullptr);

    /** @brief Destructor */
    ~AutomationPreview(void) override = default;


    /** @brief Get / Set the target property */
    [[nodiscard]] AutomationModel *target(void) const noexcept { return _target; }
    void setTarget(AutomationModel *target);


    /** @brief Get / Set the range property */
    [[nodiscard]] const BeatRange &range(void) noexcept { return _range; }
    void setRange(const BeatRange &range);


    /** @brief Get / Set the color property */
    [[nodiscard]] QColor color(void) noexcept { return _color; }
    void setColor(const QColor color);


    /** @brief Get / Set the isAccent property */
    [[nodiscard]] bool isAccent(void) noexcept { return _isAccent; }
    void setIsAccent(const bool isAccent);


    /** @brief Get / Set the pixelsPerBeatPrecision property */
    [[nodiscard]] const qreal &pixelsPerBeatPrecision(void) noexcept { return _pixelsPerBeatPrecision; }
    void setPixelsPerBeatPrecision(const qreal &pixelsPerBeatPrecision);


    /** @brief Draw target within specified range */
    void paint(QPainter *painter) final;

signals:
    /** @brief Notify when target property changes */
    void targetChanged(void);

    /** @brief Notify that pixels per beat has changed */
    void pixelsPerBeatPrecisionChanged(void);

    /** @brief Notify when range property changes */
    void rangeChanged(void);

    /** @brief Notify when color property changes */
    void colorChanged(void);

    /** @brief Notify when isAccent property changes */
    void isAccentChanged(void);

private:
    AutomationModel *_target { nullptr };
    BeatRange _range {};
    qreal _pixelsPerBeatPrecision {};
    QColor _color {};
    bool _isAccent {};
    ParamValue _stepValue {};
    ParamValue _minValue {};
    ParamValue _maxValue {};
    ParamValue _widthValue {};

    /** @brief Request an update */
    void requestUpdate(void) { update(); }
};