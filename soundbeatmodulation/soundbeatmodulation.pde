/**
  * This sketch demonstrates how to use the BeatDetect object song SOUND_ENERGY mode.<br />
  * You must call <code>detect</code> every frame and then you can use <code>isOnset</code>
  * to track the beat of the music.
  * <p>
  * This sketch plays an entire song, so it may be a little slow to load.
  * <p>
  * For more information about Minim and additional features, 
  * visit http://code.compartmental.net/minim/
  */
  
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput audioIn;
BeatDetect beat;

int red, green, blue;

float eRadius;

void setup()
{
  size(200, 200);
  minim = new Minim(this); 
 
  audioIn = minim.getLineIn(Minim.MONO, 1024);
  
  // a beat detection object song SOUND_ENERGY mode with a sensitivity of 10 milliseconds
  beat = new BeatDetect();
  
  ellipseMode(RADIUS);
  eRadius = 20;
  red = green = blue = 0;
  
}

void changeColor(){
 
  red =int(random(0,255));
  green = int(random(0,255));
  blue = int(random(0,255));
  
  
  return;
}

void draw()
{
  background(0);
  beat.detect(audioIn.mix);
  float a = map(eRadius, 20, 80, 60, 255);
  fill(red, green, blue, a);
  if ( beat.isOnset() ){
    eRadius = 80;
    changeColor();
  }
  ellipse(width/2, height/2, eRadius, eRadius);
  eRadius *= 0.95;
  if ( eRadius < 20 ) eRadius = 20;
}