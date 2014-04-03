#include <Servo.h>


const int RED_PIN = 9;
const int GREEN_PIN = 10;
const int BLUE_PIN = 11;
const int SERVO_PIN=6;

int temperaturePin=0;
int lightSensorPin=1;

int r, g, b;

//Servo servo1;


void setup()
{
  Serial.begin(9600);
  
  pinMode(RED_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  
  pinMode(SERVO_PIN, OUTPUT);
  
  
  r=0;
  b=1;
  g=0;
  
  //servo1.attach(6);
}

void loop()
{
  
  float voltage, degreesC, degreesF;
  int lightLevel, position;
  
  voltage=getVoltage(temperaturePin);
  
  degreesC = (voltage - 0.5) * 100.0;
  
  // While we're at it, let's convert degrees Celsius to Fahrenheit.
  // This is the classic C to F conversion formula:
  
  degreesF = degreesC * (9.0/5.0) + 32.0;
  
  Serial.print("voltage: ");
  Serial.print(voltage);
  Serial.print("  deg C: ");
  Serial.print(degreesC);
  Serial.print("  deg F: ");
  Serial.println(degreesF);
  
  delay(1000);
  
  lightLevel=analogRead(lightSensorPin);
  Serial.print("light sensor val: ");
  Serial.println(lightLevel);
  
  delay(1000);
  
  analogWrite(SERVO_PIN, 50);
  delay(20);
  analogWrite(SERVO_PIN, 0);
  delay(20);
  analogWrite(SERVO_PIN,-50);
  delay(20);
  analogWrite(SERVO_PIN,0);
  
  /*
  //Servo stuff
  
   // Change position at full speed:

  servo1.write(90);    // Tell servo to go to 90 degrees

  delay(1000);         // Pause to get it time to move

  servo1.write(180);   // Tell servo to go to 180 degrees

  delay(1000);         // Pause to get it time to move

  servo1.write(0);     // Tell servo to go to 0 degrees

  delay(1000);         // Pause to get it time to move
  
  // Change position at a slower speed:

  // To slow down the servo's motion, we'll use a for() loop
  // to give it a bunch of intermediate positions, with 20ms
  // delays between them. You can change the step size to make 
  // the servo slow down or speed up. Note that the servo can't
  // move faster than its full speed, and you won't be able
  // to update it any faster than every 20ms.

  // Tell servo to go to 180 degrees, stepping by two degrees
 
  for(position = 0; position < 180; position += 2)
  {
    servo1.write(position);  // Move to next position
    delay(20);               // Short pause to allow it to move
  }

  // Tell servo to go to 0 degrees, stepping by one degree

  for(position = 180; position >= 0; position -= 1)
  {                                
    servo1.write(position);  // Move to next position
    delay(20);               // Short pause to allow it to move
  }
  */
  
  if(r == 1)
  {
    digitalWrite(RED_PIN, LOW);
    digitalWrite(BLUE_PIN, HIGH);
    digitalWrite(GREEN_PIN, LOW);
    
    r=0;
    b=1;
    g=0;
  }
  else if(b == 1)
  {
    digitalWrite(RED_PIN, LOW);
    digitalWrite(BLUE_PIN, LOW);
    digitalWrite(GREEN_PIN, HIGH);
    
    r=0;
    b=0;
    g=1;
  }
  else
  {
    digitalWrite(RED_PIN, HIGH);
    digitalWrite(BLUE_PIN, LOW);
    digitalWrite(GREEN_PIN, LOW);
    
    r=1;
    b=0;
    g=0;
  }
  
}


float getVoltage(int pin)
{

  
  return (analogRead(pin) * 0.004882814);
  
  // This equation converts the 0 to 1023 value that analogRead()
  // returns, into a 0.0 to 5.0 value that is the true voltage
  // being read at that pin.
}
