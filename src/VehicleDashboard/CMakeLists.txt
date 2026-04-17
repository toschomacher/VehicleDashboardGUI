cmake_minimum_required(VERSION 3.16)

project(VehicleDashboardGUI VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.4)

qt_add_executable(appVehicleDashboardGUI
    main.cpp
)

qt_add_qml_module(appVehicleDashboardGUI
    URI VehicleDashboardGUI
    VERSION 1.0
    RESOURCE_PREFIX "/"
    QML_FILES
        Main.qml
        Gauge.qml
    RESOURCES
        images/background.png
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