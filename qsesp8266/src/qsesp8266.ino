#include <SPI.h>
#include <ESP8266WiFi.h>

//SPI spi(D5, D6, D7, D8);

int in;
int out;

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
  out = 53200000 / 10;

  SPI.beginTransaction(SPISettings(1000000, LSBFIRST, SPI_MODE0));
  digitalWrite(D8, 0);
  SPI.transferBytes((uint8_t *)&out, (uint8_t *)&in, 4);
  digitalWrite(D8, 1);
  SPI.endTransaction();

  Serial.println(in);

  delay(500);
}
