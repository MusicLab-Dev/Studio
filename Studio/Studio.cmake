cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
project(Studio)

get_filename_component(StudioDir ${CMAKE_CURRENT_LIST_FILE} PATH)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 COMPONENTS Core Quick QuickControls2 Qml LinguistTools REQUIRED)
if (NOT Apple)
    find_package(Qt5QmlImportScanner REQUIRED)
endif()

find_package(Threads)

set(APP_ICON_RESOURCE_WINDOWS "${StudioRoot}/Lexo.rc")

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
    ${StudioDir}/Design/Boards/Boards.qrc
    ${StudioDir}/Design/Plugins/Plugins.qrc
    ${StudioDir}/Design/Workspaces/Workspaces.qrc
    ${StudioDir}/Design/Settings/Settings.qrc
    ${StudioDir}/Design/Export/Export.qrc
    ${StudioDir}/Design/KeyboardShortcuts/KeyboardShortcuts.qrc
    ${StudioDir}/Design/Help/Help.qrc
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
    ${StudioDir}/AutomationModel.cpp
    ${StudioDir}/AutomationModel.hpp
    ${StudioDir}/Base.hpp
    ${StudioDir}/Board.cpp
    ${StudioDir}/Board.hpp
    ${StudioDir}/BoardEventListener.cpp
    ${StudioDir}/BoardEventListener.hpp
    ${StudioDir}/BoardManager.cpp
    ${StudioDir}/BoardManager.hpp
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
    ${StudioDir}/NetworkLog.hpp
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
    ${StudioDir}/ActionsManager.cpp
    ${StudioDir}/ActionsManager.hpp
    ${StudioDir}/ClipboardManager.hpp
    ${StudioDir}/ClipboardManager.cpp
    ${StudioDir}/CursorManager.hpp
    ${StudioDir}/CursorManager.cpp
)

add_library(${PROJECT_NAME} ${StudioSources} ${QM_FILES} ${QtResources})

target_include_directories(${PROJECT_NAME} PUBLIC ${StudioDir}/..)

target_link_libraries(${PROJECT_NAME}
PUBLIC
    Audio
    Protocol
    Qt5::Core Qt5::Quick Qt5::Qml Qt5::QuickControls2
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

add_executable(${Application} ${StudioAppSources} ${APP_ICON_RESOURCE_WINDOWS})

target_link_libraries(${Application} PUBLIC Studio)

if (NOT APPLE)
    qt5_import_qml_plugins(${Application})
endif()