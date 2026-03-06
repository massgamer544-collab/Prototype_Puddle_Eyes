#include <Servo.h>

#define TRIG 5
#define ECHO 18

Servo Scanner;

float readDistance() {

    digitalWrite(TRIG, LOW);
    delayMicroseconds(2);

    digitalWrite(TRIG, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIG, LOW);

    long duration = pulseIn(ECHO, HIGH);

    float distance = duration * 0.034 / 2;

    return distance;
}

void setup() {

    Serial.begin(115200);

    pinMode(TRIG, OUTPUT);
    pinMode(ECHO, INPUT);

    scanner.attach(13);
}

void loop() {

    for (in angle = 40; angle <= 140; angle += 5){
       
        scanner.write(angle);
        delay(250)

        float d = readDistance();

        Serial.print(angle);
        Serial.ptine(",");
        Serial.printIn(d);
    }
    
}