/**
 * @ Author: Paul Creze
 * @ Description: Board
 */

#pragma once

#include <QAbstractListModel>
#include <QPoint>
#include <QSize>

#include <Core/Vector.hpp>
#include <Protocol/Protocol.hpp>

#include "Net/Socket.hpp"

class Board;

struct BoardWrapper
{
    Q_GADGET

    Q_PROPERTY(Board *instance MEMBER instance)

public:
    Board *instance { nullptr };
};
Q_DECLARE_METATYPE(BoardWrapper)

class alignas_cacheline Board : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QSize size READ size WRITE setSize NOTIFY sizeChanged)

public:
    enum class ControlType {
        None,
        Button,
        Potentiometer,
    };
    Q_ENUM(ControlType);

    struct Control
    {
        ControlType type { ControlType::None };
        QPoint pos {};
        int data {};
    };

    using Controls = Core::Vector<Control, int>;

    /** @brief Enumeration of 'Control' roles */
    enum class Role {
        Type = Qt::UserRole + 1,
        Pos,
        Data
    };

    Board(QObject *parent)
    {
        _controls = Controls {
            Control {
                ControlType::Button,
                QPoint(0, 0),
                0
            },
            Control {
                ControlType::Button,
                QPoint(1, 1),
                1
            },
            Control {
                ControlType::Potentiometer,
                QPoint(2, 2),
                0
            },
            Control {
                ControlType::Potentiometer,
                QPoint(3, 3),
                1
            }
        };
    }

    /** @brief Names of 'Control' roles */
    [[nodiscard]] virtual QHash<int, QByteArray> roleNames(void) const override;

    /** @brief Get the number of 'Control' in the board */
    [[nodiscard]] virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /** @brief Query data from a 'Control' */
    [[nodiscard]] virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;


    /** @brief Get / Set the size property */
    [[nodiscard]] const QSize &size(void) const noexcept { return _size; }
    bool setSize(const QSize &size);

    /** @brief Get the control list */
    [[nodiscard]] Controls &controls(void) noexcept { return _controls; }
    [[nodiscard]] const Controls &controls(void) const  noexcept { return _controls; }

public slots:

signals:
    /** @brief Notify that the size has changed */
    void sizeChanged(void);

private:
    Core::Vector<Protocol::BoardID, int> _parentStack {};
    Controls _controls {};
    QSize _size {};
    Net::SocketView _rooter {};
    Protocol::BoardID _boardID {};
};

//static_assert_fit_cacheline(Board);
