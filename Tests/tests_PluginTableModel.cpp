/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio tests
 */

#include <gtest/gtest.h>

#include <Studio/PluginTableModel.hpp>

TEST(PluginTableModel, InitDestroy)
{
    ASSERT_NO_THROW(PluginTableModel());
}