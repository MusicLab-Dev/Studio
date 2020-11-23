/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio class
 */

#pragma once

#include <QGuiApplication>
#include <QQmlApplicationEngine>

class Studio;

/**
 * @brief The studio is the instance running the application process
 */
class Studio : protected QGuiApplication
{
    Q_OBJECT
public:
    Studio(int argc, char *argv[]);

    [[nodiscard]] int run(void);

private:
    QQmlApplicationEngine _engine;
};
