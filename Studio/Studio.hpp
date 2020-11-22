/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio class
 */

#pragma once

#include <QGuiApplication>
#include <QQmlApplicationEngine>

class Studio;

/** @brief The studio is the instance running the application process */
class Studio : protected QGuiApplication
{
    Q_OBJECT
public:
    /** @brief Build the studio application */
    Studio(int argc, char *argv[]);

    /** @brief Run the studio application */
    [[nodiscard]] int run(void);

private:
    QQmlApplicationEngine _engine;
};
