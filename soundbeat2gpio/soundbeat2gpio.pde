import processing.io.*; // use the GPIO library
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput audioIn;
BeatDetect beat;

int red, green, blue;
float eRadius;

void setup(){
  size(200, 200);

  minim = new Minim(this); 
 
  audioIn = minim.getLineIn(Minim.MONO, 1024);
  
  // a beat detection object song SOUND_ENERGY mode with a sensitivity of 10 milliseconds
  beat = new BeatDetect();
  
  ellipseMode(RADIUS);
  eRadius = 20;
  red = green = blue = 0;

  GPIO.pinMode(17, GPIO.OUTPUT);
  GPIO.pinMode(27, GPIO.OUTPUT);
  GPIO.pinMode(22, GPIO.OUTPUT);
  GPIO.pinMode(5, GPIO.OUTPUT);
}

void changeColor(){
 
  red =int(random(0,255));
  green = int(random(0,255));
  blue = int(random(0,255));
    
  return;
}

void draw(){
  background(0);
  beat.detect(audioIn.mix);
  float a = map(eRadius, 20, 80, 60, 255);
  fill(red, green, blue, a);
  if ( beat.isOnset() ){
    GPIO.digitalWrite(17, GPIO.HIGH);
    eRadius = 80;
    changeColor();
  }

  ellipse(width/2, height/2, eRadius, eRadius);
  eRadius *= 0.95;
 
  if (eRadius <60 && eRadius>50){
    GPIO.digitalWrite(27, GPIO.HIGH);
    GPIO.digitalWrite(17, GPIO.LOW);    
  } else if (eRadius < 50 && eRadius > 40){
    GPIO.digitalWrite(22, GPIO.HIGH);
    GPIO.digitalWrite(27, GPIO.LOW);
  } else if (eRadius < 40 && eRadius > 30){
    GPIO.digitalWrite(5, GPIO.HIGH);
    GPIO.digitalWrite(22, GPIO.LOW);
  } else if ( eRadius < 20 ) {
    GPIO.digitalWrite(5, GPIO.LOW);
    eRadius = 20;
  }  
}