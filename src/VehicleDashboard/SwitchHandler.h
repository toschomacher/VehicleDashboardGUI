#ifndef SWITCHHANDLER_H
#define SWITCHHANDLER_H

#include <QObject>
#include <QTimer>
#include <gpiod.h>
#include <QDebug>

class SwitchHandler : public QObject {
    Q_OBJECT

public:
    explicit SwitchHandler(QObject *parent = nullptr) : QObject(parent)
    {
        chip = gpiod_chip_open_by_name("gpiochip0");
        if (!chip) {
            qDebug() << "Failed to open gpiochip0";
            return;
        }

        line = gpiod_chip_get_line(chip, 26);
        if (!line) {
            qDebug() << "Failed to get GPIO26 line";
            return;
        }

        if (gpiod_line_request_input(line, "DashboardShutdownSwitch") < 0) {
            qDebug() << "Failed to request GPIO26 as input";
            line = nullptr;
            return;
        }

        auto *timer = new QTimer(this);
        connect(timer, &QTimer::timeout, this, &SwitchHandler::checkSwitch);
        timer->start(50);
    }

    ~SwitchHandler() override
    {
        if (line) {
            gpiod_line_release(line);
        }
        if (chip) {
            gpiod_chip_close(chip);
        }
    }

signals:
    void shutdownRequested();

private slots:
    void checkSwitch()
    {
        if (!line) {
            return;
        }

        const int val = gpiod_line_get_value(line);
        if (val < 0) {
            qDebug() << "Failed to read GPIO26";
            return;
        }

        // Internal pull-up logic:
        // LOW  = switch closed to GND  = keep running
        // HIGH = switch open           = request shutdown after 1 second

        if (val == 1) {
            highDurationMs += 50;
        } else {
            highDurationMs = 0;
            triggered = false;
        }

        if (highDurationMs >= 1000 && !triggered) {
            triggered = true;
            qDebug() << "GPIO26 HIGH for 1 second, requesting shutdown";
            emit shutdonwnRequested();
        }
    }

private:
    gpiod_chip *chip = nullptr;
    gpiod_line *line = nullptr;

    int highDurationMs = 0;
    bool triggered = false;
};

#endif