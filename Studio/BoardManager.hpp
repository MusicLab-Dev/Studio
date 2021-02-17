/**
 * @ Author: Paul Creze
 * @ Description: Studio entry point
 */

#pragma once

#include <QObject>
#include <QTimer>

#include <Core/Vector.hpp>

#include "Net/Socket.hpp"

class BoardManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int tickRate READ tickRate WRITE setTickRate NOTIFY tickRateChanged)
    Q_PROPERTY(int discoverRate READ discoverRate WRITE setDiscoverRate NOTIFY discoverRateChanged)

public:
    BoardManager(void);

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
    QTimer _tickTimer {};
    QTimer _discoverTimer {};
    Core::TinyVector<Net::Socket> _clients {};
    Net::Socket _listenSocket {};
    int _tickRate { 1000 };
    int _discoverRate { 1000 };

    /** @brief Callback when the tick rate changed */
    void onTickRateChanged(void);

    /** @brief Callback when the discover rate changed */
    void onDiscoverRateChanged(void);


    /** @brief Perform the tick process */
    void tick(void);

    /** @brief Perform the discover process */
    void discover(void);
};