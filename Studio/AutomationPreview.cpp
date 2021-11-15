/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview instance
 */

#include <numeric>

#include <QDebug>
#include <QPainter>
#include <QPainterPath>

#include "AutomationPreview.hpp"
#include "NodeModel.hpp"

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
    if (_target) {
        connect(_target, &AutomationModel::pointsChanged, this, &AutomationPreview::requestUpdate);
        const auto &meta = _target->parentAutomations()->parentNode()->plugin()->audioPlugin()->getMetaData();
        const auto rangeValues = meta.controls[_target->paramID()].rangeValues;
        _stepValue = rangeValues.step;
        _minValue = rangeValues.min;
        _maxValue = rangeValues.max;
        _widthValue = _maxValue - _minValue;
    }
    emit targetChanged();
    requestUpdate();
}

void AutomationPreview::setRange(const BeatRange &range)
{
    if (_range.from == range.from && _range.to == range.to)
        return;
    _range = range;
    emit rangeChanged();
    requestUpdate();
}

void AutomationPreview::setColor(const QColor color)
{
    if (_color == color)
        return;
    _color = color;
    emit colorChanged();
    requestUpdate();
}

void AutomationPreview::setIsAccent(const bool isAccent)
{
    if (_isAccent == isAccent)
        return;
    _isAccent = isAccent;
    emit isAccentChanged();
    requestUpdate();
}

void AutomationPreview::setPixelsPerBeatPrecision(const qreal &pixelsPerBeatPrecision)
{
    if (_pixelsPerBeatPrecision == pixelsPerBeatPrecision)
        return;
    _pixelsPerBeatPrecision = pixelsPerBeatPrecision;
    emit pixelsPerBeatPrecisionChanged();
    requestUpdate();
}

void AutomationPreview::paint(QPainter *painter)
{
    static constexpr auto BeatValueToPixel = [](const auto beat, const auto pixelsPerBeat) {
        return static_cast<int>(beat * pixelsPerBeat);
    };
    static constexpr auto ParamValueToPixel = [](const auto value, const auto minValue, const auto widthValue, const auto height) {
        return static_cast<int>((1 - ((value - minValue) / widthValue)) * height);
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
    const auto minValue = _minValue;
    const auto widthValue = _widthValue;
    const auto realHeight = height();

    // First point: process leftmost and increment it
    int x = 0;
    int y = 0;
    if (leftMost == nullptr) {
        x = BeatValueToPixel(begin->beat, pixelsPerBeatBeat);
        y = ParamValueToPixel(begin->value, minValue, widthValue, realHeight);
        leftMost = begin - 1;
    } else {
        _firstIndex = static_cast<int>(std::distance(begin, leftMost));
        x = BeatValueToPixel(leftMost->beat, pixelsPerBeatBeat);
        y = ParamValueToPixel(leftMost->value, minValue, widthValue, realHeight);
    }
    path.moveTo(x, y);

    // If right most is not found set it to end
    if (rightMost == nullptr)
        rightMost = end;

    // Middle points
    const auto accent = _isAccent;
    for (++leftMost; leftMost != rightMost; ++leftMost) {
        x = BeatValueToPixel(leftMost->beat, pixelsPerBeatBeat);
        y = ParamValueToPixel(leftMost->value, minValue, widthValue, realHeight);
        path.lineTo(x, y);
        if (accent) {
            QRectF rect(static_cast<float>(x) - 5.0f, static_cast<float>(y) - 5.0f, 10.0f, 10.0f);
            path.addRoundedRect(rect, 5, 5);
            _points.push_back(QRect {
                x - 10, y - 10, 20, 20
            });
        }
    }

    // Last point
    if (rightMost != end) {
        x = BeatValueToPixel(rightMost->beat, pixelsPerBeatBeat);
        y = ParamValueToPixel(rightMost->value, minValue, widthValue, realHeight);
        path.lineTo(x, y);
    }

    // Draw the built path
    auto finalColor = _color;
    if (!accent)
        finalColor.setAlpha(255 >> 3);
    else
        painter->setBrush(finalColor);
    painter->setPen(finalColor);
    painter->drawPath(path);
}

int AutomationPreview::findPoint(const QPoint &point) noexcept
{
    int index = 0;
    for (const auto &rect : _points) {
        if (!rect.contains(point))
            ++index;
        else
            return _firstIndex + index;
    }
    return -1;
}

QPoint AutomationPreview::getVisualPoint(const int index) noexcept
{
    return _points[index - _firstIndex].center();
}

void AutomationPreview::requestUpdate(void)
{
    _points.clear();
    update();
}