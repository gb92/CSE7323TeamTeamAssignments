#include <Servo.h>

#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h> 

const int RED_PIN = 7;
const int GREEN_PIN = 5;
const int BLUE_PIN = 3;
const int SERVO_PIN=6;


int temperaturePin=0;
int lightSensorPin=3;

volatile int state=0;

Servo servo1;


void setup()
{

  
  pinMode(RED_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  
  pinMode(lightSensorPin, INPUT);
  attachInterrupt(0, lightChangedToDark, CHANGE); 
  
  pinMode(SERVO_PIN, OUTPUT);
  
  servo1.attach(SERVO_PIN);
  ble_set_name("TeamTeam");
  ble_begin();
  
  Serial.begin(57600);
}

void loop()
{
  
  printCurrentTemperatures();
  delay(1000);
  
  printCurrentLightLevel();
  delay(1000);
  
  setLEDColor(state, 0, 0);
  Serial.print("state: ");
  Serial.println(state);
  
  handleBluetooth();
}

float getCurrentDegreesC()
{
  int voltage=getVoltage(temperaturePin);
  
  int degreesC = (voltage - 0.5) * 100.0;
  
  return degreesC;
}

float getCurrentDegreesF()
{
  int degreesC = getCurrentDegreesC();
  int degreesF = degreesC * (9.0/5.0) + 32.0;
  
  return degreesF;
}

void printCurrentTemperatures()
{
  
  int voltage=getVoltage(temperaturePin);
  
  int degreesC = getCurrentDegreesC();
  
  // While we're at it, let's convert degrees Celsius to Fahrenheit.
  // This is the classic C to F conversion formula:
  
  int degreesF = getCurrentDegreesF();
  
  Serial.print("voltage: ");
  Serial.print(voltage);
  Serial.print("  deg C: ");
  Serial.print(degreesC);
  Serial.print("  deg F: ");
  Serial.println(degreesF);
  
  
  handleBluetooth();
}

float getVoltage(int pin)
{

  
  return (analogRead(pin) * 0.004882814);
  
  // This equation converts the 0 to 1023 value that analogRead()
  // returns, into a 0.0 to 5.0 value that is the true voltage
  // being read at that pin.
}

float getCurrentLightLevel()
{
  float lightLevel=analogRead(lightSensorPin);
  return lightLevel;
  
}

void printCurrentLightLevel()
{
  float lightLevel=analogRead(lightSensorPin);
  Serial.print("light sensor val: ");
  Serial.println(lightLevel);
}


void moveServoToPosition(int pos)
{
  servo1.write(pos);
  
  delay(1000);
}

void setLEDColor(int r, int g, int b)
{
 analogWrite(RED_PIN, r);
 analogWrite(GREEN_PIN, g);
 analogWrite(BLUE_PIN, b); 
}

void lightChangedToDark()
{
  int lightVal=getCurrentLightLevel();
  if(lightVal>500)
  {
    state=255;
  }
  else if(lightVal>200&&lightVal<500)
  {
    state=150;
  }
  else
  {
    state=0;
  }
}

void handleBluetooth()
{
  if(ble_available())
  {
    int instruction=ble_read();
    
    int firstByte=instruction>>8;
    int secondByte=instruction&255;
    Serial.print("firstByte: ");
    Serial.println(firstByte);
    Serial.print("secondByte: ");
    Serial.println(secondByte);
    
    //Serial.write(ble_read());
  }
    
  ble_do_events();
}
