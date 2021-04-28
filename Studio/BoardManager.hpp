/**
 * @ Author: Paul Creze
 * @ Description: Board
 */

#pragma once

#include <QObject>
#include <QTimer>

#include <Core/Vector.hpp>

#include "Board.hpp"

class BoardManager : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int tickRate READ tickRate WRITE setTickRate NOTIFY tickRateChanged)
    Q_PROPERTY(int discoverRate READ discoverRate WRITE setDiscoverRate NOTIFY discoverRateChanged)

public:
    /** @brief Enumeration of 'Board' roles */
    enum class Role {
        Instance = Qt::UserRole + 1,
        Size
    };

    BoardManager(void);

    /** @brief Names of 'Board' roles */
    [[nodiscard]] virtual QHash<int, QByteArray> roleNames(void) const override;

    /** @brief Get the number of connected boards */
    [[nodiscard]] virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /** @brief Query data from the board list */
    [[nodiscard]] virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;


    /** @brief Get / Set the tick rate property */
    [[nodiscard]] int tickRate(void) const noexcept { return _tickRate; }
    void setTickRate(const int value);

    /** @brief Get / Set the discover rate property */
    [[nodiscard]] int discoverRate(void) const noexcept { return _discoverRate; }
    void setDiscoverRate(const int value);

public slots:

signals:
    /** @brief Notify that the tick rate has changed */
    void tickRateChanged(void);

    /** @brief Notify that the discover rate has changed */
    void discoverRateChanged(void);

private:
    Core::Vector<std::unique_ptr<Board>, int> _boards {}; // TODO: Add allocator to _boards
    // Core::TinyVector<Net::Socket> _clients {};
    // Net::Socket _listenSocket {};
    int _tickRate { 1000 };
    int _discoverRate { 1000 };
    QTimer _tickTimer {};
    QTimer _discoverTimer {};


    /** @brief Callback when the tick rate changed */
    void onTickRateChanged(void);

    /** @brief Callback when the discover rate changed */
    void onDiscoverRateChanged(void);


    /** @brief Perform the tick process */
    void tick(void);

    /** @brief Perform the discover process */
    void discover(void);
};