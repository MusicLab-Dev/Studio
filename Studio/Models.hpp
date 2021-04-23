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
        const auto modelCount = models.size();
        const auto audioModelCount = audioModels.size();

        // First, update already existing models
        const auto minCount = modelCount < audioModelCount ? modelCount : audioModelCount;
        for (auto i = 0u;  i < minCount; ++i)
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
            for (auto i = minCount; i < audioModelCount; ++i)
                models.push(&audioModels.at(i), args...);
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
    inline void AddProtectedEvent(Event &&event)
    {
        if (!EventGuard::Dirty) {
            EventGuard::Dirty = true;
            Scheduler::Get()->addEvent(std::forward<Event>(event), []{ EventGuard::Dirty = false; });
        } else
            qWarning() << "Models::AddProtectedEvent: A protected event is already registered for this generation !";
    }

    /** @brief Register an protected event */
    template<typename Event, typename Notify>
    inline bool AddProtectedEvent(Event &&event, Notify &&notify)
    {
        if (!EventGuard::Dirty) {
            // EventGuard::Dirty = true;
            Scheduler::Get()->addEvent(std::forward<Event>(event), [notify = std::forward<Notify>(notify)](void) mutable {
                notify();
                EventGuard::Dirty = false;
            });
            return true;
        } else {
            qWarning() << "Models::AddProtectedEvent: A protected event is already registered for this generation !";
            return false;
        }
    }
}