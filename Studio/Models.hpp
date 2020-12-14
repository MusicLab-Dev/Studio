/**
 * @ Author: Cédric Lucchese
 * @ Description: Utils Model class
 */

#pragma once

namespace Models
{
    template<typename ModelVector, typename AudioModelVector, typename ...Args>
    void RefreshModels(ModelVector &models, AudioModelVector &audioModels, Args ...args)
    {
        auto modelIt = models.begin();
        const auto modelEnd = models.end();

        for (auto &audioModel : audioModels) {
            if (modelIt != modelEnd) {
                (*modelIt)->updateInternal(&audioModel);
                ++modelIt;
            } else
                models.push(&audioModel, args...);
        }
        if (modelIt != modelEnd)
            models.erase(modelIt, modelEnd);
    }
}