#include <SPI.h>
#include <ESP8266WiFi.h>

//SPI spi(D5, D6, D7, D8);

struct {
  int stepper_pos;
  int encoder_pos;
} rx_data;
struct{
  int stepper_period;
  int stepper_dir;
} tx_data;

void setup() {
  WiFi.disconnect();
  WiFi.mode(WIFI_OFF);
  WiFi.forceSleepBegin();

  Serial.begin(115200);
  while (!Serial) {}
  Serial.println("ready.");

  pinMode(D8, OUTPUT);
  digitalWrite(D8, 1);

  SPI.begin();
  // SPI.end();
}

void loop() {
  int encoder_pos_adj = rx_data.encoder_pos == 0 ? 1 : rx_data.encoder_pos;
  tx_data.stepper_period = abs(53200000 * 16 / encoder_pos_adj);
  tx_data.stepper_dir = encoder_pos_adj > 0 ? 0 : -1;

  SPI.beginTransaction(SPISettings(1000000, LSBFIRST, SPI_MODE0));
  digitalWrite(D8, 0);
  SPI.transferBytes((uint8_t *)&tx_data, (uint8_t *)&rx_data, 8);
  digitalWrite(D8, 1);
  SPI.endTransaction();

  Serial.println(rx_data.encoder_pos);

  delay(200);
}
