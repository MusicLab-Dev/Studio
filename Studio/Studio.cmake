cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(Studio)

get_filename_component(StudioDir ${CMAKE_CURRENT_LIST_FILE} PATH)

include(${StudioRoot}/QtStaticCMake.cmake)
set(QT_STATIC_SOURCE_DIR ${QT_STATIC_SOURCE_DIR} CACHE STRING "Source directory of QtStaticCMake.cmake" FORCE)
set(QT_STATIC_QT_ROOT ${QT_STATIC_QT_ROOT} CACHE STRING "Qt sdk root folder" FORCE)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 COMPONENTS Core Widgets Quick QuickControls2 Qml QmlWorkerScript QuickShapes REQUIRED)
find_package(Threads)

qt5_add_resources(QtResources
    ${StudioDir}/Resources/Resources.qrc
    ${StudioDir}/Design/Main/Main.qrc
    ${StudioDir}/Design/Default/Default.qrc
    ${StudioDir}/Design/ModulesView/ModulesView.qrc
    ${StudioDir}/Design/SequencerView/SequencerView.qrc
    ${StudioDir}/Design/Common/Common.qrc
    ${StudioDir}/Design/PlaylistView/PlaylistView.qrc
    ${StudioDir}/Design/EmptyView/EmptyView.qrc
    ${StudioDir}/Design/BoardView/BoardView.qrc

    # Modules
    ${StudioDir}/Design/Modules/Plugins/Plugins.qrc
    ${StudioDir}/Design/Modules/Workspaces/Workspaces.qrc
    ${StudioDir}/Design/Modules/Settings/Settings.qrc
)

set(StudioSources
    ${StudioPrecompiledHeaders}
    ${StudioDir}/Base.hpp
    ${StudioDir}/AEventListener.cpp
    ${StudioDir}/AEventListener.hpp
    ${StudioDir}/Application.cpp
    ${StudioDir}/Application.hpp
    ${StudioDir}/AudioAPI.hpp
    ${StudioDir}/AutomationModel.cpp
    ${StudioDir}/AutomationModel.hpp
    ${StudioDir}/Base.hpp
    ${StudioDir}/Board.cpp
    ${StudioDir}/Board.hpp
    ${StudioDir}/BoardEventListener.cpp
    ${StudioDir}/BoardEventListener.hpp
    ${StudioDir}/BoardManager.cpp
    ${StudioDir}/BoardManager.hpp
    ${StudioDir}/Control.hpp
    ${StudioDir}/ControlModel.cpp
    ${StudioDir}/ControlModel.hpp
    ${StudioDir}/ControlsModel.cpp
    ${StudioDir}/ControlsModel.hpp
    ${StudioDir}/Device.cpp
    ${StudioDir}/Device.hpp
    ${StudioDir}/DevicesModel.cpp
    ${StudioDir}/DevicesModel.hpp
    ${StudioDir}/EventDispatcher.cpp
    ${StudioDir}/EventDispatcher.hpp
    ${StudioDir}/InstancesModel.cpp
    ${StudioDir}/InstancesModel.hpp
    ${StudioDir}/KeyboardEventListener.cpp
    ${StudioDir}/KeyboardEventListener.hpp
    ${StudioDir}/Main.cpp
    ${StudioDir}/Models.hpp
    ${StudioDir}/NetworkLog.hpp
    ${StudioDir}/NodeModel.cpp
    ${StudioDir}/NodeModel.hpp
    ${StudioDir}/Note.hpp
    ${StudioDir}/PartitionModel.cpp
    ${StudioDir}/PartitionModel.hpp
    ${StudioDir}/PartitionsModel.cpp
    ${StudioDir}/PartitionsModel.hpp
    ${StudioDir}/PluginModel.cpp
    ${StudioDir}/PluginModel.hpp
    ${StudioDir}/PluginTableModel.cpp
    ${StudioDir}/PluginTableModel.hpp
    ${StudioDir}/PluginTableModelProxy.hpp
    ${StudioDir}/Point.hpp
    ${StudioDir}/Project.cpp
    ${StudioDir}/Project.hpp
    ${StudioDir}/ProjectSave.cpp
    ${StudioDir}/ProjectSave.hpp
    ${StudioDir}/Scheduler.hpp
    ${StudioDir}/Scheduler.cpp
    ${StudioDir}/SettingsListModel.cpp
    ${StudioDir}/SettingsListModel.hpp
    ${StudioDir}/SettingsListModelProxy.cpp
    ${StudioDir}/SettingsListModelProxy.hpp
    ${StudioDir}/Socket.hpp
    ${StudioDir}/Studio.cpp
    ${StudioDir}/Studio.hpp
    ${StudioDir}/ThemeManager.cpp
    ${StudioDir}/ThemeManager.hpp
)

add_library(${PROJECT_NAME} ${StudioSources} ${QtResources})

target_include_directories(${PROJECT_NAME} PUBLIC ${StudioDir}/..)

target_link_libraries(${PROJECT_NAME}
PUBLIC
    Audio
    Protocol
    Qt5::Core Qt5::Widgets Qt5::Quick Qt5::Qml Qt5::QuickControls2 Qt5::QmlWorkerScript Qt5::QuickShapes
    Threads::Threads
)

if(CODE_COVERAGE)
    target_compile_options(${PROJECT_NAME} PUBLIC --coverage)
    target_link_options(${PROJECT_NAME} PUBLIC --coverage)
endif()

set(Application ${PROJECT_NAME}App)

set(StudioAppSources
    ${StudioDir}/Main.cpp
    ${PROJECT_BINARY_DIR}/${Application}_plugin_import.cpp
    ${PROJECT_BINARY_DIR}/${Application}_qml_plugin_import.cpp
)



add_executable(${Application} WIN32 ${StudioAppSources} ${StudioRoot}/Window.rc)

qt_generate_plugin_import(${Application}
#    VERBOSE
)

qt_generate_qml_plugin_import(${Application}
    QML_SRC ${StudioDir}/Design/
#    VERBOSE
)

target_link_libraries(${Application}
PUBLIC
    Studio
)
