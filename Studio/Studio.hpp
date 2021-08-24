/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio class
 */

#pragma once

#include <QGuiApplication>
#include <QQmlApplicationEngine>

/** @brief The studio is the instance running the application process */
class Studio : protected QGuiApplication
{
    Q_OBJECT
public:
    /** @brief Init / destroy QRC(s) */
    static void InitResources(void);
    static void DestroyResources(void);

    /** @brief Build the studio application */
    Studio(void);
    Studio(int &argc, char *argv[]);

    /** @brief Destroy the studio application */
    virtual ~Studio(void) override;

    /** @brief Run the studio application */
    [[nodiscard]] int run(void);

    /** @brief On notify */
    virtual bool notify(QObject *receiver, QEvent *e) override;

    /** @brief Get the QML engine */
    [[nodiscard]] QQmlApplicationEngine *qmlEngine(void) noexcept { return &_engine; }

private:
    QQmlApplicationEngine _engine;
};
