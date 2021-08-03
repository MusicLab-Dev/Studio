/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview instance
 */

#include <numeric>

#include <QPainter>

#include "ProjectPreview.hpp"
#include "NodeModel.hpp"

ProjectPreview::ProjectPreview(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
}

void ProjectPreview::setTarget(NodeModel *target)
{
    if (target == _target)
        return;
    _target = target;
    emit targetChanged();
    requestUpdate();
}

void ProjectPreview::setPixelsPerBeatPrecision(const qreal value)
{
    if (_pixelsPerBeatPrecision == value)
        return;
    _pixelsPerBeatPrecision = value;
    emit pixelsPerBeatPrecisionChanged();
}

void ProjectPreview::paint(QPainter *painter)
{
    if (_data.empty())
        return;

    const qreal realLineHeight = height() / static_cast<qreal>(std::max(_currentY + 1, 4));
    const int lineHeight = std::max(static_cast<int>(realLineHeight), 1);
    QRect rect;

    painter->setPen(QColor(127, 127, 127, 200));
    for (const auto &paintData : _data) {
        rect.setX(static_cast<int>((static_cast<qreal>(paintData.range.from) * pixelsPerBeatPrecision())));
        rect.setY(static_cast<int>(static_cast<qreal>(paintData.y) * realLineHeight));
        rect.setWidth(static_cast<int>(static_cast<qreal>(paintData.range.to - paintData.range.from) * pixelsPerBeatPrecision()));
        rect.setHeight(lineHeight);
        painter->fillRect(rect, paintData.color);
        if (lineHeight < 3) {
            painter->drawLine(QLine(rect.left(), rect.y(), rect.x(), rect.bottom()));
            painter->drawLine(QLine(rect.right(), rect.y(), rect.right(), rect.bottom()));
        } else {
            painter->drawRect(rect);
        }
    }
}

void ProjectPreview::collectPaintData(const NodeModel *node) noexcept
{
    const auto color = node->color();
    const auto instances = *node->partitions()->instances()->audioInstances();
    if (!instances.empty()) {
        for (const auto &instance : instances) {
            _data.push(PaintData {
                color,
                _currentY,
                instance.range
            });
        }
        ++_currentY;
    }
    for (const auto &child : node->children()) {
        collectPaintData(child.get());
    }
}

void ProjectPreview::requestUpdate(void)
{
    _data.clear();
    _currentY = 0;
    if (!_target || !_target->latestInstance())
        return;
    setPixelsPerBeatPrecision(width() / static_cast<qreal>(_target->latestInstance()));
    collectPaintData(_target);
    update();
}
