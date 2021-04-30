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

#include "Socket.hpp"

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

    Board(const Protocol::BoardID identifier, const Socket rootSocket)
    {
        _boardID = identifier;
        _rootSocket = rootSocket;

        _controls = Controls {
            {
                ControlType::Button,
                QPoint(1, 2),
                1
            },
            Control {
                ControlType::Button,
                QPoint(1, 2),
                2
            },
            Control {
                ControlType::Button,
                QPoint(1, 2),
                3
            }
        };
    }

    ~Board() = default;

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

    [[nodiscard]] Protocol::BoardID getIdentifier(void) const noexcept { return _boardID; }

    void setStatus(const bool status) noexcept { _status = status; }
    [[nodiscard]] bool getStatus(void) const noexcept { return _status; }

    [[nodiscard]] Socket getRootSocket(void) const noexcept { return _rootSocket; }

    [[nodiscard]] Board *getSlave(const Protocol::BoardID slaveId) const noexcept
    {
        for (const auto &slave : _slaves) {
            if (slave.get()->getIdentifier() == slaveId) {
                return slave.get();
            }
        }
        return nullptr;
    }

    void detachSlave(const Protocol::BoardID slaveId)
    {
        for (auto &slave : _slaves) {
            if (slave.get()->getIdentifier() == slaveId) {
                slave.reset();
                _slaves.erase(&slave);
                return;
            }
        }
    }

    void markSlavesOff(void)
    {
        if (_slaves.empty()) {
            return;
        }
        for (auto &slave : _slaves) {
            slave->markSlavesOff();
            slave->setStatus(false);
        }
    }

public slots:

signals:
    /** @brief Notify that the size has changed */
    void sizeChanged(void);

private:
    Board *_master = nullptr;
    Core::Vector<std::shared_ptr<Board>, int> _slaves {};
    Socket _rootSocket { -1 };

    Controls _controls {};
    QSize _size {};
    Protocol::BoardID _boardID { 0 };
    bool _status { true };
};

// static_assert_fit_cacheline(Board);
