/**
 * @ Author: Cédric Lucchese
 * @ Description: Utils Model class
 */

#pragma once

#include <vector>

#include <QDebug>
#include <QAbstractListModel>

#include "Scheduler.hpp"

namespace Models
{
    /** @brief Helper used to refresh models with audio models */
    template<typename ListModel, typename ModelVector, typename AudioModelVector, typename ...Args>
    inline void RefreshModels(ListModel * const root, ModelVector &models, AudioModelVector &audioModels, Args ...args)
    {
        using ModelType = std::remove_cv_t<std::remove_reference_t<decltype(*models.begin())>>;
        using AudioModelType = std::remove_cv_t<std::remove_reference_t<decltype(*audioModels.begin())>>;

        const auto modelCount = static_cast<int>(models.size());
        const auto audioModelCount = static_cast<int>(audioModels.size());

        // First, update already existing models
        const auto minCount = modelCount < audioModelCount ? modelCount : audioModelCount;
        for (auto i = 0;  i < minCount; ++i)
            models.at(i)->updateInternal(&audioModels.at(i));
        // Then, delete excess models if any
        if (modelCount > audioModelCount) {
            root->beginRemoveRows(QModelIndex(), minCount, modelCount - 1);
            models.erase(models.beginUnsafe() + minCount, models.end());
            root->endRemoveRows();
        // Else, add new models if necessary
        } else if (modelCount < audioModelCount) {
            root->beginInsertRows(QModelIndex(), minCount, audioModelCount - 1);
            models.reserve(audioModelCount);
            for (auto i = minCount; i < audioModelCount; ++i) {
                if constexpr (std::is_constructible_v<ModelType, AudioModelType *, Args...>) {
                    models.push(&audioModels.at(i), args...);
                } else {
                    models.push(ModelType::template Make(&audioModels.at(i), args...));
                }
            }
            root->endInsertRows();
        }
    }

    /** @brief Static class that allow to check the protected event state */
    struct EventGuard
    {
        static inline bool Dirty = false;
    };

    /** @brief Register an protected event */
    template<typename Event>
    inline bool AddProtectedEvent(Event &&event)
    {
        if (!EventGuard::Dirty) {
            EventGuard::Dirty = true;
            Scheduler::Get()->addEvent(
                [event = std::forward<Event>(event)](void) mutable {
                    EventGuard::Dirty = false;
                    event();
                }
            );
            return true;
        } else {
            qWarning() << "Models::AddProtectedEvent: A protected event is already registered for this generation !";
            return false;
        }
    }

    /** @brief Register an protected event */
    template<typename Event, typename Notify>
    inline bool AddProtectedEvent(Event &&event, Notify &&notify)
    {
        if (!EventGuard::Dirty) {
            EventGuard::Dirty = true;
            Scheduler::Get()->addEvent(
                [event = std::forward<Event>(event)](void) mutable {
                    EventGuard::Dirty = false;
                    event();
                },
                std::forward<Notify>(notify)
            );
            return true;
        } else {
            qWarning() << "Models::AddProtectedEvent: A protected event is already registered for this generation !";
            return false;
        }
    }
}
