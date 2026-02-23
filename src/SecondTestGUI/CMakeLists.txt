cmake_minimum_required(VERSION 3.16)

project(VehicleDashboardGUI VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appVehicleDashboardGUI
    main.cpp
    SpeedNeedleWidget.h
    # SpeedNeedleWidget.cpp   <-- add when you create it
)

qt_add_qml_module(appVehicleDashboardGUI
    URI VehicleDashboardGUI
    QML_FILES
        Main.qml
    RESOURCES
        background.png
        resources.qrc
)

set_target_properties(appVehicleDashboardGUI PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appVehicleDashboardGUI
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appVehicleDashboardGUI
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)