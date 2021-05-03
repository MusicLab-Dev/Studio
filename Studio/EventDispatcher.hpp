/**
 * @ Author: Cédric Lucchese
 * @ Description: Abstract event listener
 */

#pragma once

    #include <QDebug>

#include <QAbstractListModel>
#include <QKeyEvent>
#include <QGuiApplication>

#include "KeyboardEventListener.hpp"

/** @brief AudioAPI class */
class EventDispatcher : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QStringList targetEventList READ targetEventList CONSTANT)

public:

    explicit EventDispatcher(QObject *parent = nullptr) : QObject(parent), _keyboardListener(this, parent) {}

    [[nodiscard]] QStringList targetEventList(void) const noexcept { return QStringList(); }

signals:
    // Boolean controls
    void note0(bool pressed);
    void note1(bool pressed);
    void note2(bool pressed);
    void note3(bool pressed);
    void note4(bool pressed);
    void note5(bool pressed);
    void note6(bool pressed);
    void note7(bool pressed);
    void note8(bool pressed);
    void note9(bool pressed);
    void note10(bool pressed);
    void note11(bool pressed);
    void octaveUp(bool pressed);
    void octaveDown(bool pressed);

    void playContext(bool pressed);
    void pauseContext(bool pressed);
    void stopContext(bool pressed);
    void playPlaylist(bool pressed);
    void pausePlaylist(bool pressed);
    void stopPlaylist(bool pressed);

    // Floating controls
    void volumeContext(float ratio);
    void volumePlaylist(float ratio);

private:
    KeyboardEventListener _keyboardListener;
};
