/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview instance
 */

#include <numeric>

#include <QPainter>
#include <QPainterPath>

#include "AutomationPreview.hpp"
#include "AutomationModel.hpp"

AutomationPreview::AutomationPreview(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
}

void AutomationPreview::setTarget(AutomationModel *target)
{
    if (target == _target)
        return;
    if (_target)
        disconnect(_target, &AutomationModel::pointsChanged, this, &AutomationPreview::requestUpdate);
    _target = target;
    if (_target)
        connect(_target, &AutomationModel::pointsChanged, this, &AutomationPreview::requestUpdate);
    emit targetChanged();
    requestUpdate();
}

void AutomationPreview::setRange(const BeatRange &range)
{
    if (_range.from == range.from && _range.to == range.to)
        return;
    _range = range;
    emit rangeChanged();
}

void AutomationPreview::setPixelsPerBeatPrecision(const qreal &pixelsPerBeatPrecision)
{
    if (_pixelsPerBeatPrecision == pixelsPerBeatPrecision)
        return;
    _pixelsPerBeatPrecision = pixelsPerBeatPrecision;
    emit pixelsPerBeatPrecisionChanged();
}

void AutomationPreview::paint(QPainter *painter)
{
    static constexpr auto BeatValueToPixel = [](const auto beat, const auto pixelsPerBeat) {
        return static_cast<int>(beat * pixelsPerBeat);
    };
    static constexpr auto ParamValueToPixel = [](const auto value, const auto minValue, const auto widthValue, const auto height) {
        return static_cast<int>(((value - minValue) / widthValue) * height);
    };

    if (!_target || _target->audioAutomation()->empty()) {
        return;
    }

    const auto range = _range;
    const auto &points = *_target->audioAutomation();
    const auto begin = points.begin();
    const auto end = points.end();
    Audio::Automation::ConstIterator leftMost = nullptr;
    Audio::Automation::ConstIterator rightMost = nullptr;

    // Cut points that are in range as well as left most and right most (outside range)
    for (auto it = begin; it != end; ++it) {
        if (it->beat < range.from) {
            leftMost = it;
        } else if (it->beat > range.to) {
            rightMost = it;
            break;
        }
    }

    QPainterPath path;
    const auto pixelsPerBeatBeat = pixelsPerBeatPrecision();
    const auto minValue = 0.0;
    const auto widthValue = 1.0;
    const auto realHeight = height();

    // First point: process leftmost and increment it
    int x = 0;
    int y = 0;
    if (leftMost == nullptr) {
        x = BeatValueToPixel(begin->beat, pixelsPerBeatBeat);
        y = ParamValueToPixel(begin->value, minValue, widthValue, realHeight);
        leftMost = begin - 1;
    } else {
        x = BeatValueToPixel(leftMost->beat, pixelsPerBeatBeat);
        y = ParamValueToPixel(leftMost->value, minValue, widthValue, realHeight);
    }
    path.moveTo(x, y);

    // If right most is not found set it to end
    if (rightMost == nullptr)
        rightMost = end;

    // Middle points
    for (++leftMost; leftMost != rightMost; ++leftMost) {
        x = BeatValueToPixel(leftMost->beat, pixelsPerBeatBeat);
        y = ParamValueToPixel(leftMost->value, minValue, widthValue, realHeight);
        path.lineTo(x, y);
        path.addRoundedRect(x - 5, y - 5, 10, 10, 5, 5);
    }

    // Last point
    if (rightMost != end) {
        x = BeatValueToPixel(rightMost->beat, pixelsPerBeatBeat);
        y = ParamValueToPixel(rightMost->value, minValue, widthValue, realHeight);
        path.lineTo(x, y);
    }

    // Draw the built path
    const QColor color(255, 255, 255, 200);
    painter->setPen(color);
    painter->drawPath(path);
}
