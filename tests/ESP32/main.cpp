#include <Arduino.h>
#include <driver/twai.h>

// ----------------------
// PINS
// ----------------------
#define BTN_BRAKE   18
#define BTN_CLUTCH  19
#define BTN_COOLANT_UP   21
#define BTN_COOLANT_DOWN 22

#define POT_SPEED   35
#define POT_THROTTLE 34
#define POT_RPM 32

// ----------------------
// STATE
// ----------------------
volatile bool brake = false;
volatile bool clutch = false;
volatile int coolantC = 18;

float afr = 13.4;
bool afrUp = true;

float voltage = 14.4;

// button edge detection
bool prevUp = HIGH;
bool prevDown = HIGH;

void loop() {}