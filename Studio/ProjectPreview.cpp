/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview instance
 */

#include <numeric>

#include <QPainter>

#include "ProjectPreview.hpp"

ProjectPreview::ProjectPreview(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
}

void ProjectPreview::setTargets(const QVector<NodeModel *> &value)
{
    if (value == _targets)
        return;
    _targets = value;
    emit targetsChanged();
    requestUpdate();
}

void ProjectPreview::setPixelsPerBeatPrecision(const qreal value)
{
    if (_pixelsPerBeatPrecision == value)
        return;
    _pixelsPerBeatPrecision = value;
    emit pixelsPerBeatPrecisionChanged();
}

void ProjectPreview::setBeatLength(const Beat value)
{
    if (_beatLength == value)
        return;
    _beatLength = value;
    emit beatLengthChanged();
    requestUpdate();
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
    collectInstances(node);
    for (const auto &child : node->children()) {
        collectPaintData(child.get());
    }
}

void ProjectPreview::collectPaintDataList(void) noexcept
{
    for (const auto *node : _targets) {
        collectInstances(node);
    }
}

void ProjectPreview::requestUpdate(void)
{
    _data.clear();
    _currentY = 0;
    if (_targets.isEmpty() || !beatLength())
        return;
    setPixelsPerBeatPrecision(width() / static_cast<qreal>(beatLength()));
    if (_targets.size() == 1)
        collectPaintData(_targets[0]);
    else
        collectPaintDataList();
    update();
}
