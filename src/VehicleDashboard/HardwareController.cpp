#include "HardwareController.h"

#include <QDebug>
#include <QDateTime>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/i2c-dev.h>
#include <gpiod.h>

// I2C addresses
#define ADS1115_ADDR 0x48
#define MCP4728_ADDR 0x60

static gpiod_chip *chip = nullptr;
static gpiod_line *line17 = nullptr;
static gpiod_line *line21 = nullptr;

HardwareController::HardwareController(QObject *parent)
    : QObject(parent)
{
}

HardwareController::~HardwareController()
{
    if (timer) timer->stop();

    if (i2c_fd >= 0) close(i2c_fd);

    if (line17) gpiod_line_release(line17);
    if (line21) gpiod_line_release(line21);
    if (chip)   gpiod_chip_close(chip);
}

// ==========================
// START
// ==========================
void HardwareController::start()
{
    i2c_fd = open("/dev/i2c-1", O_RDWR);
    if (i2c_fd < 0) {
        qDebug() << "Failed to open I2C bus";
        return;
    }

    setupGPIO();

    // Start periodic loop
    timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &HardwareController::loop);
    timer->start(50); // 20 Hz
}

// ==========================
// MAIN LOOP
// ==========================
void HardwareController::loop()
{
    // ---- ADC monitoring (slow print) ----
    static qint64 lastPrint = 0;

    float ch0 = readADC(0);
    float ch1 = readADC(1);

    qint64 now = QDateTime::currentMSecsSinceEpoch();
    if (now - lastPrint > 3000) {
        qDebug() << "ADC CH0:" << ch0 << "V | CH1:" << ch1 << "V";
        lastPrint = now;
    }
}

// ==========================
// EXTERNAL UPDATE (FROM CC)
// ==========================
void HardwareController::update(bool ccActive, float throttle)
{
    // Clamp throttle
    if (throttle < 0) throttle = 0;
    if (throttle > 100) throttle = 100;

    // ---- SWITCH CONTROL ----
    setSwitches(ccActive);

    // ---- DAC CONTROL ----
    if (ccActive) {
        float v1 = getVPA(throttle);
        float v2 = getVPA2(throttle);

        setDACVoltage(0, v1);
        setDACVoltage(1, v2);
    }
}

// ==========================
// ADC READ
// ==========================
float HardwareController::readADC(int channel)
{
    if (ioctl(i2c_fd, I2C_SLAVE, ADS1115_ADDR) < 0) {
        qDebug() << "Failed to select ADS1115";
        return 0;
    }

    uint16_t config = 0x8000; // start conversion

    switch (channel) {
        case 0: config |= 0x4000; break;
        case 1: config |= 0x5000; break;
        default: return 0;
    }

    config |= 0x0083; // 128 SPS

    uint8_t buffer[3];
    buffer[0] = 0x01;
    buffer[1] = (config >> 8) & 0xFF;
    buffer[2] = config & 0xFF;

    write(i2c_fd, buffer, 3);
    usleep(10000);

    buffer[0] = 0x00;
    write(i2c_fd, buffer, 1);
    read(i2c_fd, buffer, 2);

    int16_t raw = (buffer[0] << 8) | buffer[1];

    return raw * 4.096 / 32768.0;
}

// ==========================
// DAC WRITE (FIXED)
// ==========================
void HardwareController::setDACVoltage(int channel, float voltage)
{
    if (ioctl(i2c_fd, I2C_SLAVE, MCP4728_ADDR) < 0) {
        qDebug() << "Failed to select MCP4728";
        return;
    }

    if (voltage < 0) voltage = 0;
    if (voltage > 5.0) voltage = 5.0;

    uint16_t code = (voltage / 5.0f) * 4095.0f;

    uint8_t buf[3];

    // Command: write to channel
    buf[0] = 0x40 | (channel << 1);

    // Correct MCP4728 format
    buf[1] = (code >> 8) & 0x0F;
    buf[2] = code & 0xFF;

    if (write(i2c_fd, buf, 3) != 3) {
        qDebug() << "DAC write failed";
    }
}