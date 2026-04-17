#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QProcess>
#include "CanBusManager.h"
#include "SwitchHandler.h"
#include "HardwareController.h"
#include <QDebug>
#include <QCoreApplication>
#include <QProcess>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    CanBusManager canManager;
    SwitchHandler swHandler;
    HardwareController hw;

#ifdef Q_OS_LINUX
    canManager.start();
#endif

    // -------------------------------
    // Shutdown signal (GPIO switch)
    // -------------------------------
    QObject::connect(&swHandler, &SwitchHandler::shutdownRequested,
                     &app, []() {
                         qDebug() << "Executing shutdown...";
                         system("sudo shutdown -h now");
                         QCoreApplication::quit();
                     });

    // -------------------------------
    // Expose backend to QML
    // -------------------------------
    engine.rootContext()->setContextProperty("CAN", &canManager);

    // -------------------------------
    // ?? Hardware integration (CRITICAL)
    // -------------------------------
#ifdef Q_OS_LINUX
    QObject::connect(&cc, &CruiseController::outputThrottleChanged, [&]() {
        hw.update(cc.isActive(), cc.outputThrottle());
    });

    QObject::connect(&cc, &CruiseController::activeChanged, [&]() {
        hw.update(cc.isActive(), cc.outputThrottle());
    });
#endif
    // -------------------------------
    // Load QML
    // -------------------------------
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

#if QT_VERSION >= QT_VERSION_CHECK(6, 5, 0)
    engine.loadFromModule("VehicleDashboardGUI", "Main");
#else
    engine.load(QUrl(QStringLiteral("qrc:/VehicleDashboardGUI/Main.qml")));
#endif

    // -------------------------------
    // Start hardware
    // -------------------------------
#ifdef Q_OS_LINUX
    hw.start();
    hw.update(false, 0);
#endif

    return app.exec();
}