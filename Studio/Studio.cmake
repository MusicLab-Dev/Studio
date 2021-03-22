cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(Studio)

get_filename_component(StudioDir ${CMAKE_CURRENT_LIST_FILE} PATH)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 COMPONENTS Core Quick Qml REQUIRED)
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
    ${StudioDir}/Design/Modules/Board/Board.qrc
)

set(StudioSources
    ${StudioDir}/Base.hpp
    ${StudioDir}/Application.cpp
    ${StudioDir}/Application.hpp
    ${StudioDir}/AutomationModel.cpp
    ${StudioDir}/AutomationModel.hpp
    ${StudioDir}/ControlModel.cpp
    ${StudioDir}/ControlModel.hpp
    ${StudioDir}/ControlsModel.cpp
    ${StudioDir}/ControlsModel.hpp
    ${StudioDir}/Device.cpp
    ${StudioDir}/Device.hpp
    # ${StudioDir}/DevicesModel.cpp
    # ${StudioDir}/DevicesModel.hpp
    ${StudioDir}/InstancesModel.cpp
    ${StudioDir}/InstancesModel.hpp
    ${StudioDir}/Models.hpp
    ${StudioDir}/NodeModel.cpp
    ${StudioDir}/NodeModel.hpp
    ${StudioDir}/PartitionModel.cpp
    ${StudioDir}/PartitionModel.hpp
    ${StudioDir}/PartitionsModel.cpp
    ${StudioDir}/PartitionsModel.hpp
    # ${StudioDir}/PluginTableModel.cpp
    # ${StudioDir}/PluginTableModel.hpp
    ${StudioDir}/Note.hpp
    ${StudioDir}/Point.hpp
    ${StudioDir}/Point.ipp
    ${StudioDir}/Project.cpp
    ${StudioDir}/Project.hpp
    ${StudioDir}/Scheduler.cpp
    ${StudioDir}/Scheduler.hpp
    ${StudioDir}/Studio.cpp
    ${StudioDir}/Studio.hpp
    ${StudioDir}/ThemeManager.cpp
    ${StudioDir}/ThemeManager.hpp
    ${StudioDir}/SettingsListModel.hpp
    ${StudioDir}/SettingsListModel.cpp
    ${StudioDir}/SettingsListModelProxy.hpp
    ${StudioDir}/PluginModel.cpp
    ${StudioDir}/PluginModel.hpp
)

add_library(${PROJECT_NAME} ${StudioSources} ${QtResources})

target_include_directories(${PROJECT_NAME} PUBLIC ${StudioDir}/..)

target_link_libraries(${PROJECT_NAME} PUBLIC Audio Qt::Core Qt::Quick Qt::Qml Threads::Threads)

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
