cmake_minimum_required(VERSION 3.16)

project(VehicleDashboardGUI VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick SerialBus)
find_library(GPIOD_LIB gpiod)

qt_standard_project_setup(REQUIRES 6.4)

qt_add_executable(appVehicleDashboardGUI
    main.cpp
    SwitchHandler.h
    CanBusManager.h
    CanBusManager.cpp
)

qt_add_qml_module(appVehicleDashboardGUI
    URI VehicleDashboardGUI
    VERSION 1.0
    RESOURCE_PREFIX "/"
    QML_FILES
        Main.qml
        Gauge.qml
    RESOURCES
        resources.qrc
        images/background.png
        images/ccon.png
        images/ccoff.png
        images/tempblue.png
        images/temporange.png
        images/tempred.png
        images/afr.png
        sounds/ready.wav
)

set_target_properties(appVehicleDashboardGUI PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appVehicleDashboardGUI
    PRIVATE Qt6::Quick Qt6::SerialBus ${GPIOD_LIB}
)

include(GNUInstallDirs)
install(TARGETS appVehicleDashboardGUI
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)