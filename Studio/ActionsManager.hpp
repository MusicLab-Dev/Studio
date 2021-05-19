/**
 * @ Author: Cédric Lucchese
 * @ Description: Actions Manager
 */

#pragma once

/** @brief Actions Manager class */
class ActionsManager : public QObject
{
    Q_OBJECT
    
public:

    [[nodiscard]] static ActionsManager *Get(void) noexcept { return _Instance; }

    /** @brief Default constructor */
    explicit ActionsManager(QObject *parent = nullptr);

    /** @brief Destruct the instance */
    ~ActionsManager(void) noexcept;

private:
    static inline *_Instance { nullptr }
}