/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview
 */

#pragma once

#include <QQuickPaintedItem>

#include "Base.hpp"

class NodeModel;

class ProjectPreview : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(NodeModel *target READ target WRITE setTarget NOTIFY targetChanged)
    Q_PROPERTY(qreal pixelsPerBeatPrecision READ pixelsPerBeatPrecision WRITE setPixelsPerBeatPrecision NOTIFY pixelsPerBeatPrecisionChanged)

public:
    /** @brief Structure containing painting data */
    struct PaintData
    {
        QColor color;
        int y;
        BeatRange range;
    };

    /** @brief Constructor */
    ProjectPreview(QQuickItem *parent = nullptr);

    /** @brief Destructor */
    ~ProjectPreview(void) override = default;

    /** @brief Get / Set the target property */
    [[nodiscard]] NodeModel *target(void) const noexcept { return _target; }
    void setTarget(NodeModel *target);

    /** @brief Get / Set the pixelsPerBeatPrecision property */
    [[nodiscard]] qreal pixelsPerBeatPrecision(void) const noexcept { return _pixelsPerBeatPrecision; }
    void setPixelsPerBeatPrecision(const qreal value);

    /** @brief Draw target within specified range */
    void paint(QPainter *painter) final;

public slots:
    /** @brief Request an update */
    void requestUpdate(void);

signals:
    /** @brief Notify when target property changes */
    void targetChanged(void);

    /** @brief Notify when pixels per beat changes */
    void pixelsPerBeatPrecisionChanged(void);

private:
    NodeModel *_target { nullptr };
    qreal _pixelsPerBeatPrecision {};
    Core::TinyVector<PaintData> _data {};
    int _currentY { 0 };

    /** @brief Collect all paint data and return the number of lines */
    void collectPaintData(const NodeModel *node) noexcept;
};