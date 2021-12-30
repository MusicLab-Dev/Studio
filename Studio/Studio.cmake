cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(Studio VERSION 0.3)

set(COMPANY "Lexo")
set(COPYRIGHT "Copyright (c) 2021 Lexo. All rights reserved.")
set(IDENTIFIER "com.lexo.LexoStudio")

get_filename_component(StudioDir ${CMAKE_CURRENT_LIST_FILE} PATH)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 COMPONENTS Core Quick QuickControls2 Qml LinguistTools REQUIRED)
find_package(Qt5QmlImportScanner REQUIRED)
find_package(RtMidi CONFIG REQUIRED)

find_package(Threads)

set(APP_ICON_NAME "Lexo")
set(APP_ICON_RESOURCE_WINDOWS "${StudioRoot}/${APP_ICON_NAME}.rc")
set(APP_ICON_RESOURCE_MACOS "${StudioRoot}/${APP_ICON_NAME}.icns")

set(AppTranslationFiles
    English.ts
    French.ts
)

qt5_create_translation(QM_FILES ${StudioDir} ${AppTranslationFiles})

configure_file(${StudioDir}/Resources/Translations.qrc ${CMAKE_BINARY_DIR} COPYONLY)

qt5_add_resources(QtResources
    ${StudioDir}/Resources/Resources.qrc
    ${StudioDir}/Design/Main/Main.qrc
    ${StudioDir}/Design/Default/Default.qrc
    ${StudioDir}/Design/Modules/Modules.qrc
    ${StudioDir}/Design/Sequencer/Sequencer.qrc
    ${StudioDir}/Design/Common/Common.qrc
    ${StudioDir}/Design/Tree/Tree.qrc
    ${StudioDir}/Design/Planner/Planner.qrc
    ${StudioDir}/Design/Plugins/Plugins.qrc
    ${StudioDir}/Design/Workspaces/Workspaces.qrc
    ${StudioDir}/Design/Settings/Settings.qrc
    ${StudioDir}/Design/Export/Export.qrc
    ${StudioDir}/Design/KeyboardShortcuts/KeyboardShortcuts.qrc
    ${CMAKE_BINARY_DIR}/Translations.qrc
)

set(StudioSources
    ${StudioPrecompiledHeaders}
    ${StudioDir}/Base.hpp
    ${StudioDir}/AEventListener.cpp
    ${StudioDir}/AEventListener.hpp
    ${StudioDir}/Application.cpp
    ${StudioDir}/Application.hpp
    ${StudioDir}/AudioAPI.hpp
    ${StudioDir}/AudioAPI.cpp
    ${StudioDir}/AutomationModel.cpp
    ${StudioDir}/AutomationModel.hpp
    ${StudioDir}/Base.hpp
    ${StudioDir}/ControlEvent.hpp
    ${StudioDir}/AutomationsModel.cpp
    ${StudioDir}/AutomationsModel.hpp
    ${StudioDir}/Device.cpp
    ${StudioDir}/Device.hpp
    ${StudioDir}/DevicesModel.cpp
    ${StudioDir}/DevicesModel.hpp
    ${StudioDir}/EventDispatcher.cpp
    ${StudioDir}/EventDispatcher.hpp
    ${StudioDir}/PartitionInstance.hpp
    ${StudioDir}/PartitionInstancesModel.cpp
    ${StudioDir}/PartitionInstancesModel.hpp
    ${StudioDir}/PartitionInstancesModelProxy.hpp
    ${StudioDir}/PartitionInstancesModelProxy.cpp
    ${StudioDir}/KeyboardEventListener.cpp
    ${StudioDir}/KeyboardEventListener.hpp
    ${StudioDir}/Models.hpp
    ${StudioDir}/NodeModel.cpp
    ${StudioDir}/NodeModel.hpp
    ${StudioDir}/NodeListModel.cpp
    ${StudioDir}/NodeListModel.hpp
    ${StudioDir}/VolumeCache.hpp
    ${StudioDir}/Note.hpp
    ${StudioDir}/PartitionModel.cpp
    ${StudioDir}/PartitionModel.hpp
    ${StudioDir}/PartitionsModel.cpp
    ${StudioDir}/PartitionsModel.hpp
    ${StudioDir}/PartitionPreview.cpp
    ${StudioDir}/PartitionPreview.hpp
    ${StudioDir}/ProjectPreview.cpp
    ${StudioDir}/ProjectPreview.hpp
    ${StudioDir}/ProjectPreview.ipp
    ${StudioDir}/PluginModel.cpp
    ${StudioDir}/PluginModel.hpp
    ${StudioDir}/PluginModelProxy.cpp
    ${StudioDir}/PluginModelProxy.hpp
    ${StudioDir}/PluginTableModel.cpp
    ${StudioDir}/PluginTableModel.hpp
    ${StudioDir}/PluginTableModelProxy.hpp
    ${StudioDir}/PluginTableModelProxy.cpp
    ${StudioDir}/Point.hpp
    ${StudioDir}/Project.cpp
    ${StudioDir}/Project.hpp
    ${StudioDir}/ProjectSave.cpp
    ${StudioDir}/ProjectSave.hpp
    ${StudioDir}/ProjectSerializer.cpp
    ${StudioDir}/ProjectSerializer.hpp
    ${StudioDir}/Scheduler.hpp
    ${StudioDir}/Scheduler.cpp
    ${StudioDir}/SettingsListModel.cpp
    ${StudioDir}/SettingsListModel.hpp
    ${StudioDir}/SettingsListModelProxy.cpp
    ${StudioDir}/SettingsListModelProxy.hpp
    ${StudioDir}/Studio.cpp
    ${StudioDir}/Studio.hpp
    ${StudioDir}/ThemeManager.cpp
    ${StudioDir}/ThemeManager.hpp
    ${StudioDir}/ActionsManager.cpp
    ${StudioDir}/ActionsManager.hpp
    ${StudioDir}/ClipboardManager.hpp
    ${StudioDir}/ClipboardManager.cpp
    ${StudioDir}/CursorManager.hpp
    ${StudioDir}/CursorManager.cpp
    ${StudioDir}/PartitionManager.hpp
    ${StudioDir}/PartitionManager.ipp
    ${StudioDir}/PartitionManager.cpp
    ${StudioDir}/ColoredSprite.hpp
    ${StudioDir}/ColoredSprite.cpp
    ${StudioDir}/ColoredSpriteManager.hpp
    ${StudioDir}/ColoredSpriteManager.cpp
    ${StudioDir}/CommunityAPI.hpp
    ${StudioDir}/CommunityAPI.cpp
    ${StudioDir}/AutomationPreview.hpp
    ${StudioDir}/AutomationPreview.cpp
    ${StudioDir}/ControlDescriptor.hpp
)

add_library(${PROJECT_NAME} ${StudioSources} ${QM_FILES} ${QtResources})

target_include_directories(${PROJECT_NAME} PUBLIC ${StudioDir}/..)

target_link_libraries(${PROJECT_NAME}
PUBLIC
    Audio
    Qt5::Core Qt5::Quick Qt5::Qml Qt5::QuickControls2
    Threads::Threads
    RtMidi::rtmidi
)

if(CODE_COVERAGE)
    target_compile_options(${PROJECT_NAME} PUBLIC --coverage)
    target_link_options(${PROJECT_NAME} PUBLIC --coverage)
endif()

set(StudioAppSources
    ${StudioDir}/Main.cpp
)

set(Application ${PROJECT_NAME}App)

if(APPLE)
    # Identify MacOS bundle
    set(MACOSX_BUNDLE_BUNDLE_NAME LexoStudio)
    set(MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION})
    set(MACOSX_BUNDLE_LONG_VERSION_STRING ${PROJECT_VERSION})
    set(MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
    set(MACOSX_BUNDLE_COPYRIGHT ${COPYRIGHT})
    set(MACOSX_BUNDLE_GUI_IDENTIFIER ${IDENTIFIER})
    set(MACOSX_BUNDLE_ICON_FILE ${APP_ICON_NAME}.icns)
    set(APP_ICON_MACOSX ${APP_ICON_RESOURCE_MACOS})
    set_source_files_properties(${APP_ICON_RESOURCE_MACOS} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    add_executable(${Application} MACOSX_BUNDLE ${StudioAppSources} ${APP_ICON_RESOURCE_MACOS})
elseif(MSVC)
    add_executable(${Application} ${StudioAppSources} ${APP_ICON_RESOURCE_WINDOWS})
else()
    add_executable(${Application} ${StudioAppSources})
endif()

target_link_libraries(${Application} PUBLIC Studio)

qt5_import_qml_plugins(${Application})

