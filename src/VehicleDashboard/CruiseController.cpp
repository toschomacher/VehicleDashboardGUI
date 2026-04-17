#include "CruiseController.h"
#include <QtMath>

CruiseController::CruiseController(QObject *parent)
    : QObject(parent)
{
    connect(&m_timer, &QTimer::timeout,
            this, &CruiseController::controlLoop);

    m_timer.start(50); // 20 Hz loop
}

void CruiseController::setActive(bool active)
{
    bool wasActive = m_active;
    m_active = active;

    if (m_active && !wasActive) {

        if (!m_resumeRequested) {
            m_setSpeed = m_currentSpeed;
            m_lastSetSpeed = m_setSpeed;

            emit setSpeedChanged();
            emit lastSetSpeedChanged();
        }

        m_resumeRequested = false;

        m_outputThrottle = m_currentThrottle;
        m_integral = 0;
    }

    if (!m_active && wasActive) {
        m_resumeRequested = false;
    }

    emit activeChanged();
}

void CruiseController::setSetSpeed(float speed)
{
    if (!m_active)
        return;

    m_setSpeed = speed;
    m_lastSetSpeed = speed;

    emit setSpeedChanged();
    emit lastSetSpeedChanged();
}

void CruiseController::updateInputs(float speed, float rpm, float throttle, bool brake, bool clutch)
{
    m_currentSpeed = speed;
    m_currentRPM = rpm;   // <-- ADD THIS
    m_currentThrottle = throttle;
    m_brake = brake;
    m_clutch = clutch;

    static bool wasReady = false;

    bool isReady = (m_currentRPM < 50);

    if (isReady && !wasReady) {
        emit readyTriggered();
    }

    wasReady = isReady;
}

void CruiseController::controlLoop()
{
    if (!m_active)
        return;

    // Safety cancel
    if (m_brake || m_clutch) {
        setActive(false);
        return;
    }

    float error = m_setSpeed - m_currentSpeed;

    // --- PID (PI) ---
    float Kp = 0.8f;
    float Ki = 0.1f;

    m_integral += error * 0.05f;

    float output = Kp * error + Ki * m_integral;

    m_outputThrottle += output;

    m_outputThrottle = qBound(0.0f, m_outputThrottle, 100.0f);

    emit outputThrottleChanged();
}

void CruiseController::resume()
{
    if (m_lastSetSpeed <= 0)
        return;

    m_setSpeed = m_lastSetSpeed;
    m_resumeRequested = true;

    emit setSpeedChanged();
    setActive(true);
}