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

    Board(const Protocol::BoardID identifier, const Net::Socket::Internal boardFD)
    {
        _boardID = identifier;
        _rooter = boardFD;

        _controls = Controls {
            Control {
                .type = ControlType::Button,
                .pos = QPoint(1, 2),
                .data = 1
            },
            Control {
                .type = ControlType::Button,
                .pos = QPoint(1, 2),
                .data = 2
            },
            Control {
                .type = ControlType::Button,
                .pos = QPoint(1, 2),
                .data = 3
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

    [[nodiscard]] const Net::SocketView getRooter(void) const noexcept { return _rooter; }

public slots:

signals:
    /** @brief Notify that the size has changed */
    void sizeChanged(void);

private:
    Core::Vector<Protocol::BoardID, int> _parentStack {};
    Controls _controls {};
    QSize _size {};
    Net::SocketView _rooter { -1 };
    Protocol::BoardID _boardID { 0 };
};

static_assert_fit_cacheline(Board);
