#pragma once

#include <QObject>
#include <QTimer>

class CruiseController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)
    Q_PROPERTY(float setSpeed READ setSpeed WRITE setSetSpeed NOTIFY setSpeedChanged)
    Q_PROPERTY(float outputThrottle READ outputThrottle NOTIFY outputThrottleChanged)
    Q_PROPERTY(float lastSetSpeed READ lastSetSpeed NOTIFY lastSetSpeedChanged)

public:
    explicit CruiseController(QObject *parent = nullptr);

    bool isActive() const { return m_active; }
    void setActive(bool active);

    float setSpeed() const { return m_setSpeed; }
    void setSetSpeed(float speed);

    float outputThrottle() const { return m_outputThrottle; }
    float lastSetSpeed() const { return m_lastSetSpeed; }

    void updateInputs(float speed, float rpm, float throttle, bool brake, bool clutch);

public slots:
    void resume();   // ? FIXED

signals:
    void activeChanged();
    void setSpeedChanged();
    void outputThrottleChanged();
    void lastSetSpeedChanged();
    void readyTriggered();

private slots:
    void controlLoop();

private:
    QTimer m_timer;

    float m_currentRPM = 0;
    float m_currentSpeed = 0;
    float m_currentThrottle = 0;
    float m_lastSetSpeed = 0;
    bool m_brake = false;
    bool m_clutch = false;

    bool m_active = false;
    float m_setSpeed = 0;
    float m_outputThrottle = 0;

    float m_integral = 0;

    bool m_resumeRequested = false;   // ? inside class
};