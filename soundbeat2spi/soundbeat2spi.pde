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

void maxOne(byte maxNr, byte reg, byte col){
  int c = 0;
  
  for ( c = maxInUse; c > maxNr; c--) {
    adc.transfer(0);    // means no operation
    adc.transfer(0);    // means no operation
  }

  adc.transfer(reg);  // specify register
  adc.transfer(col);//((data & 0x01) * 256) + data >> 1); // put data 

  for ( c =maxNr-1; c >= 1; c--) {
    adc.transfer(0);    // means no operation
    adc.transfer(0);    // means no operation
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
   maxSingle(1,1);                       //  + - - - - - - -
   maxSingle(2,2);                       //  - + - - - - - -
   maxSingle(3,4);                       //  - - + - - - - -
   maxSingle(4,8);                       //  - - - + - - - -
   maxSingle(5,16);                      //  - - - - + - - -
   maxSingle(6,32);                      //  - - - - - + - -
   maxSingle(7,64);                      //  - - - - - - + -
   maxSingle(8,128);                     //  - - - - - - - +

}