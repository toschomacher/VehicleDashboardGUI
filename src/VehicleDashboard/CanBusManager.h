#pragma once

#include <QObject>
#include <QCanBusDevice>
#include <QTimer>

class CanBusManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(float speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(float rpm READ rpm NOTIFY rpmChanged)
    Q_PROPERTY(bool brake READ brake NOTIFY brakeChanged)
    Q_PROPERTY(bool clutch READ clutch NOTIFY clutchChanged)
    Q_PROPERTY(int coolant READ coolant NOTIFY coolantChanged)
    Q_PROPERTY(float afr READ afr NOTIFY afrChanged)
    Q_PROPERTY(float voltage READ voltage NOTIFY voltageChanged)
    Q_PROPERTY(float throttle READ throttle NOTIFY throttleChanged)

    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionChanged)
    Q_PROPERTY(bool alive READ isAlive NOTIFY aliveChanged)

public:
    explicit CanBusManager(QObject *parent = nullptr);

    void start();

    float speed() const { return m_speed; }
    float rpm() const { return m_rpm; }
    bool brake() const { return m_brake; }
    bool clutch() const { return m_clutch; }
    int coolant() const { return m_coolant; }
    float afr() const { return m_afr; }
    float voltage() const { return m_voltage; }
    float throttle() const { return m_throttle; }

    bool isConnected() const;
    bool isAlive() const;

signals:
    void speedChanged();
    void rpmChanged();
    void brakeChanged();
    void clutchChanged();
    void coolantChanged();
    void afrChanged();
    void voltageChanged();
    void throttleChanged();

    void connectionChanged();
    void aliveChanged();

private slots:
    void tryConnect();
    void processFrames();
    void checkAlive();

private:
    QCanBusDevice *device = nullptr;

    QTimer *retryTimer = nullptr;
    QTimer *watchdogTimer = nullptr;

    float m_speed = 0;
    float m_rpm = 0;
    bool m_brake = false;
    bool m_clutch = false;
    int m_coolant = 0;
    float m_afr = 0;
    float m_voltage = 0;
    float m_throttle = 0;

    bool m_connected = false;
    bool m_alive = false;

    qint64 lastFrameTime = 0;

    void processFrame(const QCanBusFrame &frame);
};