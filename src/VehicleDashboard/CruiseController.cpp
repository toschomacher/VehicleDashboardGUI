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