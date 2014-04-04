#include <Servo.h>

#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h>

const int RED_PIN = 7;
const int GREEN_PIN = 5;
const int BLUE_PIN = 3;
const int SERVO_PIN= 10;

const int temperaturePin=0;
const int lightSensorPin=3;

// Device State
// 0 = off ( red )
// 1 = on but connecting to phone ( green  )
volatile int state=0;

float lastUpdateTime = 0.0f;
float lastPressSwitchTime = 0.0f;

Servo servo1;

void setup()
{
  pinMode(RED_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);

  pinMode(lightSensorPin, INPUT);

  attachInterrupt(0, buttonClick, FALLING);

  pinMode(SERVO_PIN, OUTPUT);

  servo1.attach(SERVO_PIN);
  ble_set_name("TeamGreen");
  ble_begin();

  Serial.begin(57600);
}

void loop()
{
  switch( state )
  {
    case 0: setLEDColor( 255, 0, 0 ); break;
    case 1: setLEDColor( 0, 255, 0 ); break;
    default: setLEDColor( 0,0,0 ); break;
  }

    handleBluetooth();
  
}

void buttonClick()
{
  const int updateDelay = 500;
  if( (millis() - lastPressSwitchTime) > updateDelay ) 
  {
    if( state > 0 )
    {
      state = 0 ;
    }
    else
    {
      state = 1;
    }
    
    lastPressSwitchTime = millis();
  }
}

float converseToDegreesC( float voltage )
{
  return (voltage - 0.5) * 100.0;
}
float converseToDegreesF( float voltage )
{
  return ( converseToDegreesC( voltage ) * (9.0/5.0) + 32.0 );
}


void printCurrentTemperatures()
{

  float voltage=getVoltage(temperaturePin);

  float degreesC = converseToDegreesC( voltage );
  float degreesF = converseToDegreesF( voltage );

  Serial.print("voltage: ");
  Serial.print(voltage);
  Serial.print("  deg C: ");
  Serial.print(degreesC);
  Serial.print("  deg F: ");
  Serial.println(degreesF);
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
}

void setLEDColor(int r, int g, int b)
{
  analogWrite(RED_PIN, r);
  analogWrite(GREEN_PIN, g);
  analogWrite(BLUE_PIN, b);
}

void sendSensorsUpdate()
{
  
          const int updateDelay = 1000;
          if( (millis() - lastUpdateTime) > updateDelay )
          {
              float voltage=getVoltage(temperaturePin);
          
              float degreesC = converseToDegreesC( voltage );
              float degreesF = converseToDegreesF( voltage );
              
              float lightLevel=analogRead(lightSensorPin);
              
              if ( ble_connected() )
              {
                ble_write( state);
                ble_write( degreesC );
                ble_write( lightLevel );
              }
            lastUpdateTime = millis();
          }
          
}

void controlSensors()
{
  
    if(ble_available())
    {
          byte deviceNumber = ble_read();
          byte data = ble_read();
          
          if( deviceNumber == 0x00 ) // control servo
          {
            if( state )
            {
              moveServoToPosition( data );
            }
          }
          else if( deviceNumber == 0x02 )
          {
            if( data == 0x00 )
            {
                state = 0;
            }
            else
            {
                state = 1;
            }
          }
     
  }
}

void handleBluetooth()
{
      if ( ble_connected() )
      {
        sendSensorsUpdate();
        controlSensors();
      }
      
      ble_do_events();
}

