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

// ----------------------
// CAN SEND
// ----------------------
void sendCAN(uint32_t id, uint8_t *data) {
  twai_message_t msg;
  msg.identifier = id;
  msg.extd = 0;
  msg.rtr = 0;
  msg.data_length_code = 8;
  memcpy(msg.data, data, 8);
  twai_transmit(&msg, pdMS_TO_TICKS(10));
}

// ----------------------
// BUTTON TASK
// ----------------------
void taskButtons(void *pv) {
  while (true) {

    brake  = (digitalRead(BTN_BRAKE) == LOW);
    clutch = (digitalRead(BTN_CLUTCH) == LOW);

    bool up = digitalRead(BTN_COOLANT_UP);
    if (prevUp == HIGH && up == LOW) {
      coolantC += 10;
    }
    prevUp = up;

    bool down = digitalRead(BTN_COOLANT_DOWN);
    if (prevDown == HIGH && down == LOW) {
      coolantC -= 10;
      if (coolantC < 0) coolantC = 0;
    }
    prevDown = down;

    vTaskDelay(pdMS_TO_TICKS(20));
  }
}

void loop() {}