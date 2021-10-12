/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Partition preview
 */

#pragma once

#include <QQuickPaintedItem>

#include "Base.hpp"
#include "NodeModel.hpp"

class ProjectPreview : public QQuickPaintedItem
{
    Q_OBJECT

    Q_PROPERTY(QVector<NodeModel *> targets READ targets WRITE setTargets NOTIFY targetsChanged)
    Q_PROPERTY(qreal pixelsPerBeatPrecision READ pixelsPerBeatPrecision WRITE setPixelsPerBeatPrecision NOTIFY pixelsPerBeatPrecisionChanged)
    Q_PROPERTY(Beat beatLength READ beatLength WRITE setBeatLength NOTIFY beatLengthChanged)

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
    [[nodiscard]] QVector<NodeModel *> targets(void) const noexcept { return _targets; }
    void setTargets(const QVector<NodeModel *> &value);

    /** @brief Get / Set the pixelsPerBeatPrecision property */
    [[nodiscard]] qreal pixelsPerBeatPrecision(void) const noexcept { return _pixelsPerBeatPrecision; }
    void setPixelsPerBeatPrecision(const qreal value);

    /** @brief Get / Set the pixelsPerBeatPrecision property */
    [[nodiscard]] Beat beatLength(void) const noexcept { return _beatLength; }
    void setBeatLength(const Beat value);

    /** @brief Draw target within specified range */
    void paint(QPainter *painter) final;


public slots:
    /** @brief Request an update */
    void requestUpdate(void);


signals:
    /** @brief Notify when target property changes */
    void targetsChanged(void);

    /** @brief Notify when pixels per beat changes */
    void pixelsPerBeatPrecisionChanged(void);

    /** @brief Notify when beat length changes */
    void beatLengthChanged(void);


private:
    QVector<NodeModel *> _targets {};
    qreal _pixelsPerBeatPrecision {};
    Core::TinyVector<PaintData> _data {};
    int _currentY { 0 };
    Beat _beatLength { 0 };


    /** @brief Collect all paint data from a single node, recursivly*/
    void collectPaintData(const NodeModel *node) noexcept;

    /** @brief Collect all paint from the list of targets */
    void collectPaintDataList(void) noexcept;

    /** @brief Collect all instances of a single */
    void collectInstances(const NodeModel *node) noexcept;
};

#include "ProjectPreview.ipp"
