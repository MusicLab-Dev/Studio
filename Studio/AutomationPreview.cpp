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
    if (_target) {
        disconnect(_target, &AutomationModel::pointsChanged, this, &AutomationPreview::requestUpdate);
        const auto plugin = _target->parentAutomations()->parentNode()->plugin();
        disconnect(plugin, &PluginModel::controlValueChanged, this, &AutomationPreview::onControlValueChanged);
    }
    _target = target;
    if (_target) {
        const auto plugin = _target->parentAutomations()->parentNode()->plugin();
        const auto &meta = plugin->audioPlugin()->getMetaData();
        const auto rangeValues = meta.controls[_target->paramID()].rangeValues;
        _paramID = _target->paramID();
        _stepValue = rangeValues.step;
        _minValue = rangeValues.min;
        _maxValue = rangeValues.max;
        _widthValue = _maxValue - _minValue;
        connect(_target, &AutomationModel::pointsChanged, this, &AutomationPreview::requestUpdate);
        connect(plugin, &PluginModel::controlValueChanged, this, &AutomationPreview::onControlValueChanged);
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
    static constexpr auto ParamValueToPixel = [](const ParamValue value, const ParamValue minValue, const ParamValue widthValue, const ParamValue height) {
        return static_cast<int>((1 - ((value - minValue) / widthValue)) * height);
    };

    // No target => no preview
    if (!_target)
        return;

    // Setup colors
    QColor primaryColor(_color);
    QColor secondaryColor(_color);
    if (!_isAccent) {
        primaryColor.setAlpha(255 >> 3);
        secondaryColor = primaryColor;
    } else
        secondaryColor.setAlpha(255 >> 1);

    // No points => show current value if accent
    if (_target->audioAutomation()->empty()) {
        if (_isAccent) {
            auto paramY = ParamValueToPixel(_target->parentAutomations()->parentNode()->plugin()->getControl(_paramID), _minValue, _widthValue, height());
            painter->setPen(secondaryColor);
            painter->drawLine(0, paramY, static_cast<int>(width()), paramY);
        }
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

    // Setup path constants
    QPainterPath path;
    const auto pixelsPerBeat = pixelsPerBeatPrecision();
    const auto minValue = _minValue;
    const auto widthValue = _widthValue;
    const auto realHeight = height();
    const auto xOffset = static_cast<int>(pixelsPerBeat * range.from);

    // First point: process leftmost and increment it
    int x = 0;
    int y = 0;
    if (leftMost == nullptr) {
        x = BeatValueToPixel(begin->beat, pixelsPerBeat) - xOffset;
        y = ParamValueToPixel(begin->value, minValue, widthValue, realHeight);
        leftMost = begin;
        painter->setPen(secondaryColor);
        painter->drawLine(0, y, x, y);
    } else {
        _firstIndex = static_cast<int>(std::distance(begin, leftMost));
        x = BeatValueToPixel(leftMost->beat, pixelsPerBeat) - xOffset;
        y = ParamValueToPixel(leftMost->value, minValue, widthValue, realHeight);
        ++leftMost;
    }
    path.moveTo(x, y);

    // If right most is not found set it to end
    if (rightMost == nullptr)
        rightMost = end;

    // Middle points
    const auto accent = _isAccent;
    for (; leftMost != rightMost; ++leftMost) {
        x = BeatValueToPixel(leftMost->beat, pixelsPerBeat) - xOffset;
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
        x = BeatValueToPixel(rightMost->beat, pixelsPerBeat) - xOffset;
        y = ParamValueToPixel(rightMost->value, minValue, widthValue, realHeight);
        path.lineTo(x, y);
    } else {
        auto right = static_cast<int>(width());
        painter->setPen(secondaryColor);
        painter->drawLine(x, y, right, y);
    }

    // Draw the built path
    if (accent) // Only brush when accent
        painter->setBrush(primaryColor);
    painter->setPen(primaryColor);
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

void AutomationPreview::onControlValueChanged(const ParamID paramID)
{
    if (paramID == _paramID && _target->audioAutomation()->empty())
        requestUpdate();
}