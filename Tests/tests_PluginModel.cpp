/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio tests
 */

#include <gtest/gtest.h>
#include <memory>

#include <Studio/PluginModel.hpp>
#include <Audio/IPlugin.hpp>
#include <Audio/Plugins/Mixer.hpp>

TEST(PluginModel, InitDestroy)
{
    std::shared_ptr<Audio::IPlugin> plugin = std::make_shared<Audio::Mixer>(nullptr);

    ASSERT_NO_THROW(PluginModel tmp(plugin.get()));
}

TEST(PluginModel, Mixer)
{
    std::shared_ptr<Audio::IPlugin> plugin = std::make_shared<Audio::Mixer>(nullptr);

    PluginModel mixer(plugin.get());

    ASSERT_EQ(mixer.title(), "Mixer");
    ASSERT_EQ(mixer.description(), "Mixer allow to mix multiple audio source");
}