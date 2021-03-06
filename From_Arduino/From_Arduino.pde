/* 
ARDUINO TO PROCESSING

Read Serial messages from Arduino for use in Processing. 
*Even though Serial Library comes with install of Processing, upon first usage, you may be prompted to execute two sudo Terminal 
commands after entering your user password*

Created by Daniel Christopher 10/27/12
Public Domain

*/

import processing.serial.*; //import the Serial library

int r,g,b;    // Used to color background
int end = 10;    // the number 10 is ASCII for linefeed (end of serial.println), later we will look for this to break up individual messages
String serial;   // declare a new string called 'serial' . A string is a sequence of characters (data type know as "char")
Serial port;  // The serial port, this is a new instance of the Serial class (an Object)

void setup() {
  port = new Serial(this, Serial.list()[0], 9600); // initializing the object by assigning a port and baud rate (must match that of Arduino)
  port.clear();  // function from serial library that throws out the first reading, in case we started reading in the middle of a string from Arduino
  serial = port.readStringUntil(end); // function that reads the string from serial port until a println and then assigns string to our string variable (called 'serial')
  serial = null; // initially, the string will be null (empty)
}

void draw() {
  background(r,g,b);
  
  while (port.available() > 0) { //as long as there is data coming from serial port, read it and store it 
    serial = port.readStringUntil(end);
  }
    if (serial != null) {  //if the string is not empty, print the following
    
    /*  Note: the split function used below is not necessary if sending only a single variable. However, it is useful for parsing (separating) messages when
        reading from multiple inputs in Arduino. Below is example code for an Arduino sketch
    */
    
      int[] a = int(splitTokens(serial, ",")); 
      println(a[0]); //print Value1 (in cell 1 of Array - remember that arrays are zero-indexed)
      println(a[1]); //print Value2 value
      println(a[2]); //print Value2 value
      
      r = a[0]/4;
      g = a[1]/4;
      b = a[2]/4;
 

    }
}
