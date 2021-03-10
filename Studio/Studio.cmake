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
    ${StudioDir}/Design/Common/Common.qrc
)

set(StudioSources
    ${StudioDir}/Point.hpp
    ${StudioDir}/Point.ipp
    ${StudioDir}/Studio.hpp
    ${StudioDir}/Studio.cpp
    ${StudioDir}/InstancesModel.hpp
    ${StudioDir}/InstancesModel.cpp
    ${StudioDir}/AutomationModel.hpp
    ${StudioDir}/AutomationModel.cpp
    ${StudioDir}/ControlModel.hpp
    ${StudioDir}/ControlModel.cpp
    ${StudioDir}/ControlsModel.hpp
    ${StudioDir}/ControlsModel.cpp
    ${StudioDir}/PartitionModel.hpp
    ${StudioDir}/PartitionModel.cpp
    ${StudioDir}/PartitionsModel.hpp
    ${StudioDir}/PartitionsModel.cpp
    ${StudioDir}/NodeModel.hpp
    ${StudioDir}/NodeModel.cpp
#${StudioDir}/Application.hpp
#${StudioDir}/Application.cpp
    ${StudioDir}/Project.hpp
    ${StudioDir}/Project.cpp
${StudioDir}/Scheduler.hpp
${StudioDir}/Scheduler.cpp
#${StudioDir}/PluginTableModel.hpp
#${StudioDir}/PluginTableModel.cpp
#${StudioDir}/DeviceModel.hpp
#${StudioDir}/DeviceModel.cpp
#${StudioDir}/Device.hpp
#${StudioDir}/Device.cpp

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
