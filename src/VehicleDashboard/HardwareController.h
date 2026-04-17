#pragma once

#include <QObject>
#include <QTimer>

class HardwareController : public QObject
{
    Q_OBJECT

public:
    explicit HardwareController(QObject *parent = nullptr);
    ~HardwareController() override;

    void start();

    // ?? Main interface from CruiseController
    void update(bool ccActive, float throttle);

private slots:
    void loop();   // periodic ADC + background tasks

private:
    QTimer *timer = nullptr;
    int i2c_fd = -1;

    // GPIO
    void setupGPIO();
    void setSwitches(bool enabled);

    // ADC / DAC
    float readADC(int channel);
    void setDACVoltage(int channel, float voltage);

    // ?? Throttle maps (VPA signals)
    float getVPA(float throttle);
    float getVPA2(float throttle);
};