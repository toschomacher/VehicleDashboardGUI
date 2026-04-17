#include "CanBusManager.h"
#include <QCanBus>
#include <QCanBusFrame>
#include <QDateTime>
#include <QDebug>

CanBusManager::CanBusManager(QObject *parent)
    : QObject(parent)
{
}

void CanBusManager::start()
{
    // Retry connection every second
    retryTimer = new QTimer(this);
    connect(retryTimer, &QTimer::timeout, this, &CanBusManager::tryConnect);
    retryTimer->start(1000);

    // Watchdog for CAN alive detection
    watchdogTimer = new QTimer(this);
    connect(watchdogTimer, &QTimer::timeout, this, &CanBusManager::checkAlive);
    watchdogTimer->start(500);
}

void CanBusManager::tryConnect()
{
    if (m_connected)
        return;

    device = QCanBus::instance()->createDevice("socketcan", "can0");

    if (!device) {
        qDebug() << "Failed to create CAN device";
        return;
    }

    connect(device, &QCanBusDevice::framesReceived,
            this, &CanBusManager::processFrames);

    if (device->connectDevice()) {
        m_connected = true;
        emit connectionChanged();
        qDebug() << "CAN connected!";
    } else {
        qDebug() << "CAN connection failed";
        delete device;
        device = nullptr;
    }
}

void CanBusManager::processFrames()
{
    if (!device)
        return;

    while (device->framesAvailable()) {
        QCanBusFrame frame = device->readFrame();

        // Update last frame timestamp
        lastFrameTime = QDateTime::currentMSecsSinceEpoch();

        // Mark alive if not already
        if (!m_alive) {
            m_alive = true;
            emit aliveChanged();
            qDebug() << "CAN alive";
        }

        processFrame(frame);
    }
}

void CanBusManager::checkAlive()
{
    if (!m_connected)
        return;

    qint64 now = QDateTime::currentMSecsSinceEpoch();

    if (now - lastFrameTime > 1000) { // 1 second timeout
        if (m_alive) {
            m_alive = false;
            emit aliveChanged();
            qDebug() << "CAN LOST!";
        }
    }
}

void CanBusManager::processFrame(const QCanBusFrame &frame)
{
    auto data = frame.payload();
    uint32_t id = frame.frameId();

    switch (id) {

    case 0x101: { // SPEED
        uint16_t raw = (data[0] << 8) | data[1];
        m_speed = raw / 100.0f;
        emit speedChanged();
        break;
    }

    case 0x100: { // RPM
        uint16_t raw = (data[0] << 8) | data[1];
        m_rpm = raw / 4.0f;
        emit rpmChanged();
        break;
    }

    case 0x102: { // PEDALS
        bool newBrake = data[0] & 0x01;
        bool newClutch = data[0] & 0x02;

        if (newBrake != m_brake) {
            m_brake = newBrake;
            emit brakeChanged();
        }

        if (newClutch != m_clutch) {
            m_clutch = newClutch;
            emit clutchChanged();
        }
        break;
    }

    case 0x103: { // COOLANT
        m_coolant = data[0] - 40;
        emit coolantChanged();
        break;
    }

    case 0x104: { // AFR
        uint16_t raw = (data[0] << 8) | data[1];
        m_afr = raw / 100.0f;
        emit afrChanged();
        break;
    }

    case 0x105: { // VOLTAGE
        uint16_t raw = (data[0] << 8) | data[1];
        m_voltage = raw / 100.0f;
        emit voltageChanged();
        break;
    }

    case 0x106: { // THROTTLE
        uint16_t raw = (data[0] << 8) | data[1];
        m_throttle = raw / 100.0f;
        emit throttleChanged();
        break;
    }
    }

    // Optional debug
    // qDebug() << "Frame ID:" << QString::number(id, 16);
}

bool CanBusManager::isConnected() const
{
    return m_connected;
}

bool CanBusManager::isAlive() const
{
    return m_alive;
}