import processing.io.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput audioIn;
BeatDetect beat;
SPI adc;

float eRadius;

// define max7219 registers
final int max7219_reg_noop        = 0x00;
final int max7219_reg_digit0      = 0x01;
final int max7219_reg_digit1      = 0x02;
final int max7219_reg_digit2      = 0x03;
final int max7219_reg_digit3      = 0x04;
final int max7219_reg_digit4      = 0x05;
final int max7219_reg_digit5      = 0x06;
final int max7219_reg_digit6      = 0x07;
final int max7219_reg_digit7      = 0x08;
final int max7219_reg_decodeMode  = 0x09;
final int max7219_reg_intensity   = 0x0a;
final int max7219_reg_scanLimit   = 0x0b;
final int max7219_reg_shutdown    = 0x0c;
final int max7219_reg_displayTest = 0x0f;

int linePos = 0x7f;
boolean lineDown = true;

void maxBrightness(int intensity){
   if(intensity >= 0 && intensity < 16){
     maxTransfer(max7219_reg_intensity, intensity);
   }
}

void maxInit(){
  //initiation of the max 7219
  maxTransfer(max7219_reg_scanLimit, 0x07);      
  maxTransfer(max7219_reg_decodeMode, 0x00);  // using an led matrix (not digits)
  maxTransfer(max7219_reg_shutdown, 0x01);    // not in shutdown mode
//  maxTransfer(max7219_reg_displayTest, 0x01); // display test
//  delay(500);
  maxTransfer(max7219_reg_displayTest, 0x00); // turn off display test
  
  for (int e = max7219_reg_digit0; e <= max7219_reg_digit7; e++) {    // empty registers, turn all LEDs off 
    maxTransfer(e, 0);
  }
  maxBrightness(7);
}

void maxTransfer(int address, int value){
  adc.transfer(address);
  adc.transfer(value);
}

void setup(){
  size(200, 200);

  minim = new Minim(this); 
 
  audioIn = minim.getLineIn(Minim.MONO, 1024);
  
  // a beat detection object song SOUND_ENERGY mode with a sensitivity of 10 milliseconds
  beat = new BeatDetect();
  
  ellipseMode(RADIUS);
  eRadius = 20;
  
  // initialize SPI and max
  adc = new SPI(SPI.list()[0]);
  adc.settings(1000000, SPI  .MSBFIRST, SPI.MODE0);
  maxInit();

}

void draw(){
    background(0);
  beat.detect(audioIn.mix);
  float a = map(eRadius, 20, 80, 60, 255);
  fill(0, 255, 0, a);
  if ( beat.isOnset() ){
    lineDrop(0x7f);
    eRadius = 80;   
  }

  ellipse(width/2, height/2, eRadius, eRadius);
  eRadius *= 0.95;


}

void lineDrop(int startPos){
  //if(startPos < 0x00 || startPos > 0x80)
  
  for(int k = max7219_reg_digit0; k <= max7219_reg_digit7; k++){
    maxTransfer(k, linePos);
  }

  if(linePos > 0x00 && lineDown){
    linePos = linePos >> 1;
/*  } else if (linePos == 0x00){
    lineDown = false;
  } else if (linePos < 0x80 && !lineDown) {
    linePos = linePos << 1;
*/  } else {
    linePos = 0x7f;
    lineDown = true;
  } 
}