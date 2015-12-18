import controlP5.*;

import processing.serial.*;

Serial myPort;                                                          //Create object from Serial class
String val;                                                             // Data received from the serial port
String serial;                                                          // delcare a new string called 'serial'
int [] a;
int end = 10;                                                           // the number 10 is ASCII for linefeed (end of serial.println), later we will look for this to break up individual messages        

void setup() 
{
  size(1920,1080);
String portName = Serial.list()[0];
myPort = new Serial (this, "COM5", 9600);
}

void draw()
{
  background (150);
  
  if (myPort.available() > 0) {
    serial = myPort.readStringUntil(end);
  }
  if (serial != null) { 
    int[] a = int(splitTokens(serial, ","));
    println(a[0]); 
    println(a[1]);
    println("_");
  
  noFill();
  stroke(0);
  beginShape();
  curveVertex(0, a[0]);                                    // the first control point
  curveVertex(0, a[0]);                                    // is also the start point of curve
  curveVertex(240, a[0]);
  curveVertex(480, a[0]);
  curveVertex(720, a[0]);
  curveVertex(960, a[0]);
  curveVertex(1200, a[0]);
  curveVertex(1440, a[0]);
  curveVertex(1680, a[0]);
  curveVertex(1920, a[0]);                               // the last point of curve
  curveVertex(1920, a[0]);                               // is also the last control point
  endShape();
  }
}


