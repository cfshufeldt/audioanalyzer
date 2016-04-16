import processing.io.*;
SPI adc;

int maxInUse = 1;    //change this variable to set how many MAX7219's you'll use

int e = 0;           // just a varialble

// define max7219 registers
byte max7219_reg_noop        = 0x00;
byte max7219_reg_digit0      = 0x01;
byte max7219_reg_digit1      = 0x02;
byte max7219_reg_digit2      = 0x03;
byte max7219_reg_digit3      = 0x04;
byte max7219_reg_digit4      = 0x05;
byte max7219_reg_digit5      = 0x06;
byte max7219_reg_digit6      = 0x07;
byte max7219_reg_digit7      = 0x08;
byte max7219_reg_decodeMode  = 0x09;
byte max7219_reg_intensity   = 0x0a;
byte max7219_reg_scanLimit   = 0x0b;
byte max7219_reg_shutdown    = 0x0c;
byte max7219_reg_displayTest = 0x0f;

void maxSingle(byte reg, byte col){
  adc.transfer(reg);
  adc.transfer(col);
}

void maxAll(byte reg, byte col){
  int c = 0;
  for (c = 1; c<= maxInUse; c++){
    adc.transfer(reg);
    adc.transfer(col);
  }
}

void setup(){
  // printArray(SPI.list());
  adc = new SPI(SPI.list()[0]);
  adc.settings(500000, SPI.MSBFIRST, SPI.MODE0);
  
  //initiation of the max 7219
  maxAll(max7219_reg_scanLimit, byte(0x07));      
  maxAll(max7219_reg_decodeMode, byte(0x00));  // using an led matrix (not digits)
  maxAll(max7219_reg_shutdown, byte(0x01));    // not in shutdown mode
  maxAll(max7219_reg_displayTest, byte(0x00)); // no display test
  
  for (e=1; e<=8; e++) {    // empty registers, turn all LEDs off 
    maxAll(byte(e),byte(0));
  }
  maxAll(max7219_reg_intensity, byte(0x0f & 0x0f));    // the first 0x0f is the value you can set
                                                  // range: 0x00 to 0x0f
}

void draw(){
 //if you use just one MAX7219 it should look like this
  maxSingle(byte(1),byte(0));                       //  + - - - - - - -
/*   maxSingle(byte(2),byte(2));                       //  - + - - - - - -
   maxSingle(byte(3),byte(4));                       //  - - + - - - - -
   maxSingle(byte(4),byte(8));                       //  - - - + - - - -
   maxSingle(byte(5),byte(16));                      //  - - - - + - - -
   maxSingle(byte(6),byte(32));                      //  - - - - - + - -
   maxSingle(byte(7),byte(64));                      //  - - - - - - + -
   maxSingle(byte(8),byte(128));                     //  - - - - - - - +
*/
}