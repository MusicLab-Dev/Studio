/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Studio entry point
 */

#include <iostream>

#include <QtPlugin>

#include <Studio/Studio.hpp>

Q_IMPORT_PLUGIN(QtQuick2Plugin);
//Q_IMPORT_PLUGIN(QtQuickLayoutsPlugin);
//Q_IMPORT_PLUGIN(QtQuickControls2Plugin);
//Q_IMPORT_PLUGIN(QtQuickTemplates2Plugin);
//Q_IMPORT_PLUGIN(QtQuick2WindowPlugin);
//Q_IMPORT_PLUGIN(QtQuickControls2MaterialStylePlugin);
//Q_IMPORT_PLUGIN(QmlSettingsPlugin);
//Q_IMPORT_PLUGIN(QtQuickControls2FusionStylePlugin);
//Q_IMPORT_PLUGIN(QtQuickControls2UniversalStylePlugin);
//Q_IMPORT_PLUGIN(QtQuickControls2ImagineStylePlugin);
//Q_IMPORT_PLUGIN(QtGraphicalEffectsPlugin);
//Q_IMPORT_PLUGIN(QtGraphicalEffectsPrivatePlugin);

int main(int argc, char *argv[])
{
    Studio::InitResources();
    try {
        Studio studio(argc, argv);

        return studio.run();
    } catch (const std::exception &e) {
        std::cerr << "\nAn error occured:\n\t" << e.what() << std::endl;
    }
    Studio::DestroyResources();
}
