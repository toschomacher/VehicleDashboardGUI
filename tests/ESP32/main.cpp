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

// ----------------------
// CAN TASK
// ----------------------
void taskCAN(void *pv) {

  unsigned long last = 0;
  unsigned long lastThrottle = 0;

  while (true) {

    unsigned long now = millis();

    // ---------------- SPEED (pot)
    int rawSpeed = analogRead(POT_SPEED);
    float speedMPH = (rawSpeed / 4095.0) * 100.0;

    // ---------------- THROTTLE
    int rawThrottle = analogRead(POT_THROTTLE);
    float throttle = (rawThrottle / 4095.0) * 100.0;

        // ---------------- RPM (pot)
    int rawRPM = analogRead(POT_RPM);
    float rpm = (rawRPM / 4095.0) * 8000.0;
    // smoothing (low-pass filter)
    static float smoothedRPM = 0;
    smoothedRPM += (rpm - smoothedRPM) * 0.2; // adjustment options: 0.1 → smoother but slower ; 0.3 → faster but less smooth
    rpm = smoothedRPM;

    // optional deadzone
    if (rpm < 50) rpm = 0;

    // ---- SEND THROTTLE OVER CAN ----
    if (now - lastThrottle >= 50) {
        lastThrottle = now;

        uint16_t raw = throttle * 100;

        uint8_t data[8] = {
            (uint8_t)(raw >> 8),
            (uint8_t)(raw & 0xFF),
            0,0,0,0,0,0
        };

        sendCAN(0x106, data);
    }

    // ---------------- AFR oscillation
    if (now - last > 300) {
      last = now;

      if (afrUp) {
        afr += 0.1;
        if (afr >= 14.6) afrUp = false;
      } else {
        afr -= 0.1;
        if (afr <= 13.4) afrUp = true;
      }
    }

    // ---------------- SEND CAN

    // SPEED
    uint16_t speedRaw = speedMPH * 100;
    uint8_t speedData[8] = {
      (uint8_t)(speedRaw >> 8),
      (uint8_t)(speedRaw),
      0,0,0,0,0,0
    };
    sendCAN(0x101, speedData);

    // PEDALS
    uint8_t pedal = 0;
    if (brake)  pedal |= 0x01;
    if (clutch) pedal |= 0x02;

    uint8_t pedalData[8] = { pedal,0,0,0,0,0,0,0 };
    sendCAN(0x102, pedalData);

    // COOLANT
    uint8_t coolantData[8] = { (uint8_t)(coolantC + 40),0,0,0,0,0,0,0 };
    sendCAN(0x103, coolantData);

    // AFR
    uint16_t afrRaw = afr * 100;
    uint8_t afrData[8] = {
      (uint8_t)(afrRaw >> 8),
      (uint8_t)(afrRaw),
      0,0,0,0,0,0
    };
    sendCAN(0x104, afrData);

    // VOLTAGE
    uint16_t voltRaw = voltage * 100;
    uint8_t voltData[8] = {
      (uint8_t)(voltRaw >> 8),
      (uint8_t)(voltRaw),
      0,0,0,0,0,0
    };
    sendCAN(0x105, voltData);

    // RPM
    uint16_t rpmRaw = rpm * 4;
    uint8_t rpmData[8] = {
      (uint8_t)(rpmRaw >> 8),
      (uint8_t)(rpmRaw),
      0,0,0,0,0,0
    };
    sendCAN(0x100, rpmData);

    vTaskDelay(pdMS_TO_TICKS(10));
  }
}

// ----------------------
// SETUP
// ----------------------
void setup() {

  Serial.begin(115200);

  Serial.println("Running...");

  pinMode(BTN_BRAKE, INPUT_PULLUP);
  pinMode(BTN_CLUTCH, INPUT_PULLUP);
  pinMode(BTN_COOLANT_UP, INPUT_PULLUP);
  pinMode(BTN_COOLANT_DOWN, INPUT_PULLUP);

  // CAN
  twai_general_config_t g_config = TWAI_GENERAL_CONFIG_DEFAULT(
    GPIO_NUM_5,
    GPIO_NUM_4,
    TWAI_MODE_NORMAL
  );

  twai_timing_config_t t_config = TWAI_TIMING_CONFIG_500KBITS();
  twai_filter_config_t f_config = TWAI_FILTER_CONFIG_ACCEPT_ALL();

  twai_driver_install(&g_config, &t_config, &f_config);
  twai_start();

  // tasks
  xTaskCreatePinnedToCore(taskButtons, "Buttons", 2048, NULL, 1, NULL, 0);
  xTaskCreatePinnedToCore(taskCAN, "CAN", 4096, NULL, 1, NULL, 1);
}

void loop() {}