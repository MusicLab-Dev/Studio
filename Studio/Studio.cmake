cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(Studio)

get_filename_component(StudioDir ${CMAKE_CURRENT_LIST_FILE} PATH)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 COMPONENTS Core Quick QuickControls2 Qml REQUIRED)
find_package(Threads)

qt_add_resources(QtResources
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

set(StudioPrecompiledHeaders
    ${StudioDir}/Base.hpp
    ${StudioDir}/AudioAPI.hpp
    ${StudioDir}/Application.hpp
    ${StudioDir}/AutomationModel.hpp
    ${StudioDir}/ControlModel.hpp
    ${StudioDir}/ControlsModel.hpp
    ${StudioDir}/Device.hpp
    ${StudioDir}/DevicesModel.hpp
    ${StudioDir}/InstancesModel.hpp
    ${StudioDir}/Models.hpp
    ${StudioDir}/NodeModel.hpp
    ${StudioDir}/PartitionModel.hpp
    ${StudioDir}/PartitionsModel.hpp
    ${StudioDir}/PluginTableModel.hpp
    ${StudioDir}/PluginTableModelProxy.hpp
    ${StudioDir}/Note.hpp
    ${StudioDir}/Control.hpp
    ${StudioDir}/Point.hpp
    ${StudioDir}/Project.hpp
    ${StudioDir}/ProjectSave.hpp
    ${StudioDir}/Scheduler.hpp
    ${StudioDir}/Studio.hpp
    ${StudioDir}/ThemeManager.hpp
    ${StudioDir}/SettingsListModel.hpp
    ${StudioDir}/SettingsListModelProxy.hpp
    ${StudioDir}/PluginModel.hpp
    ${StudioDir}/NetworkLog.hpp
    ${StudioDir}/BoardManager.hpp
    ${StudioDir}/Board.hpp
    ${StudioDir}/AEventListener.hpp
    ${StudioDir}/KeyboardEventListener.hpp
    ${StudioDir}/EventDispatcher.hpp
)

set(StudioSources
    ${StudioPrecompiledHeaders}
    ${StudioDir}/Application.cpp
    ${StudioDir}/AutomationModel.cpp
    ${StudioDir}/ControlModel.cpp
    ${StudioDir}/ControlsModel.cpp
    ${StudioDir}/Device.cpp
    ${StudioDir}/DevicesModel.cpp
    ${StudioDir}/InstancesModel.cpp
    ${StudioDir}/NodeModel.cpp
    ${StudioDir}/PartitionModel.cpp
    ${StudioDir}/PartitionsModel.cpp
    ${StudioDir}/PluginTableModel.cpp
    ${StudioDir}/Project.cpp
    ${StudioDir}/ProjectSave.cpp
    ${StudioDir}/Scheduler.cpp
    ${StudioDir}/Studio.cpp
    ${StudioDir}/ThemeManager.cpp
    ${StudioDir}/SettingsListModel.cpp
    ${StudioDir}/SettingsListModelProxy.cpp
    ${StudioDir}/PluginModel.cpp
    ${StudioDir}/BoardManager.cpp
    ${StudioDir}/Board.cpp
    ${StudioDir}/AEventListener.cpp
    ${StudioDir}/KeyboardEventListener.cpp
    ${StudioDir}/EventDispatcher.cpp
)

add_library(${PROJECT_NAME} ${StudioSources} ${QtResources})

target_precompile_headers(${PROJECT_NAME} PUBLIC ${StudioPrecompiledHeaders})

target_include_directories(${PROJECT_NAME} PUBLIC ${StudioDir}/..)

target_link_libraries(${PROJECT_NAME}
PUBLIC
    Audio
    Protocol
    Qt::Core Qt::Quick Qt::Qml Qt::QuickControls2
    Threads::Threads
)

if(CODE_COVERAGE)
    target_compile_options(${PROJECT_NAME} PUBLIC --coverage)
    target_link_options(${PROJECT_NAME} PUBLIC --coverage)
endif()

set(StudioAppSources
    ${StudioDir}/Main.cpp
)

set(Application ${PROJECT_NAME}App)

add_executable(${Application} ${StudioAppSources})

target_link_libraries(${Application} Studio)
