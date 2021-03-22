project(StudioTests)

find_package(GTest REQUIRED)

get_filename_component(StudioTestsDir ${CMAKE_CURRENT_LIST_FILE} PATH)

set(StudioTestsSources
    #${StudioTestsDir}/tests_Studio.cpp
    ${StudioTestsDir}/tests_NodeModel.cpp
    ${StudioTestsDir}/tests_InstancesModel.cpp
    ${StudioTestsDir}/tests_AutomationModel.cpp
    ${StudioTestsDir}/tests_PartitionModel.cpp
    ${StudioTestsDir}/tests_PartitionsModel.cpp
    ${StudioTestsDir}/tests_ControlModel.cpp
    ${StudioTestsDir}/tests_ControlsModel.cpp
    ${StudioTestsDir}/tests_Point.cpp
    ${StudioTestsDir}/tests_Project.cpp
    #${StudioTestsDir}/tests_Application.cpp
    ${StudioTestsDir}/tests_Scheduler.cpp
    #${StudioTestsDir}/tests_PluginTableModel.cpp
    #${StudioTestsDir}/tests_Device.cpp
    #${StudioTestsDir}/tests_DevicesModel.cpp
    ${StudioTestsDir}/tests_PluginModel.cpp
)

add_executable(${PROJECT_NAME} ${StudioTestsSources})

add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})

target_link_libraries(${PROJECT_NAME}
PUBLIC
    Studio
    GTest::GTest GTest::Main
)