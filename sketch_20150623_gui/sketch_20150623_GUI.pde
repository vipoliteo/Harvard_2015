import controlP5.*;
import processing.video.*;
import processing.serial.*;

ControlP5 cp5;

Textarea myTextarea;                                      //added for Control P5 Console

PImage bg;                                                //background image
PImage logo;                                              // logo image
PFont SCPBold30;                                          // text (use Create Font under Tools Menu) 
PFont SCPRegular24;                                       // text (these fonts were from my mac so we need to update)
PFont SCPRegular14;                                       // text

Capture cam;                                              // capture webcam

int c = 0;                                                     // added for CP5 console
int end = 10;                                                  //length of string from serial port
int fadeOne=150;                                               // interger for fading section cut
int fadeTwo=150;                                               // represents how many lines trail the current measurement.
int fadeThree=150;                                             // interger for fading section cut
int cameraStatus = 1;

float stepperDirection;                                      // direction of stepper motor
float stepperCount;                                          // step number (right now applies to all three steppers)
float bannerValue1;                                          // value from banner sensor
float bannerValue2;                                          // value from banner sensor
float bannerValue3;                                          // value from banner sensor
float lightValue;                                             //value from light sensor
float stepperMap1;                                            // stepper Value remapped to section window size.
float stepperMap2;                                            // stepper Value remapped to section window size.
float stepperMap3;                                            // stepper Value remapped to section window size.
float lightMap;

float[] oldStep1 = new float[fadeOne];                        // all of these are arrays to store previous float numbers for the sections.
float[] oldStep2 = new float[fadeTwo];
float[] oldStep3 = new float[fadeThree];
float[] oldBanner1 = new float[fadeOne];
float[] oldBanner2 = new float[fadeTwo];
float[] oldBanner3 = new float[fadeThree];

String status;                                        // I need to find out what this is. Something to do with the text.
String serial;                                        // declare string from Arduino Serial port

boolean videoFeed = false;                                // boolean for video feed button
boolean Section_1 = false;                                // boolean for section button
boolean Section_2 = false;                                // boolean for second section button
boolean Section_3 = false;                                // boolean for third section button


Serial GEOport;                                           // Create Object from Serial Class, the serial port is named GEOport.

Println console;                                          // added for cp5 Console

void setup() {
  size(1920,1080);                                        // create size

  String portName = Serial.list()[1];                     // data is coming into processing on COM1, even though arduino is on COM5. Not sure why. If it stops working just cycle though COM numbers starting with zero.
  GEOport = new Serial(this, portName, 9600);             // Port is running at 9600 on both Arduino and Processing (this seems pretty standard so should always be the case.)
  GEOport.clear();                                        //function from serial library that throws out the first reading, in case we started reading in the middle of a string from Arduino
  serial = GEOport.readStringUntil(end);                  //function that reads the string from serial port until a println and then assigns string to our string variable (called 'serial')
  serial = null;                                          // initially, the string will be null (empty)
  
  smooth();                                               // draws all geometry with anti-aliased edges (so they look smooth not jagged)
  status = new String();                                  // there is a new string named status... WHY?
  bg = loadImage ("background.jpg");                      //bg is the background image, saved in sketch file
  logo = loadImage ("logo.png");                          // load logo image, this should eventually be updated to processing.
  cp5 = new ControlP5(this);                              // setup cp5 in the file
  cp5.enableShortcuts();                                  // added from text area consol example from controlP5
  
  cp5.addToggle("GEOcorder Status")                       // This button does not do anything yet, but I think we need one master ON button. Right now its just for layout purposes.
  .setPosition (25, 400)
  .setSize(60,25)
  .setColorActive(color(237,57,149))
  .setColorBackground(100)
  .setColorCaptionLabel(color(255,255,255))
  .setColorForeground(255)
  .setColorValueLabel(0)
  .setValue(true)
  .setMode(ControlP5.SWITCH)
  ;
  
  cp5.addToggle("videoFeed")                              // This button turns the video feed on or off.
  .setPosition (25, 450)
  .setSize(60,25)
  .setColorActive(color(237,57,149))
  .setColorBackground(100)
  .setColorCaptionLabel(color(255,255,255))
  .setColorForeground(255)
  .setColorValueLabel(0)
  .setValue(true)
  .setMode(ControlP5.SWITCH)
  ;  
  
    cp5.addToggle("Section_1")                            // Right now this button controls the stepper motors. When the motors are off the banner sensors still transmit to processing.
  .setPosition (25, 500)
  .setSize(60,25)
  .setColorActive(color(237,57,149))
  .setColorBackground(100)
  .setColorCaptionLabel(color(255,255,255))
  .setColorForeground(255)
  .setColorValueLabel(0)
  .setValue(true)
  .setMode(ControlP5.SWITCH)
  ; 
  
      cp5.addToggle("Section_2")                          // Unused right now, but hopefully we can control steppers for sections individually.
  .setPosition (25, 550)
  .setSize(60,25)
  .setColorActive(color(237,57,149))
  .setColorBackground(100)
  .setColorCaptionLabel(color(255,255,255))
  .setColorForeground(255)
  .setColorValueLabel(0)
  .setValue(true)
  .setMode(ControlP5.SWITCH)
  ; 
  
      cp5.addToggle("Section_3")                          // Uused right now, for future stepper control
  .setPosition (25, 600)
  .setSize(60,25)
  .setColorActive(color(237,57,149))
  .setColorBackground(100)
  .setColorCaptionLabel(color(255,255,255))
  .setColorForeground(255)
  .setColorValueLabel(0)
  .setValue(true)
  .setMode(ControlP5.SWITCH)
  ; 
  
  myTextarea = cp5.addTextarea("txt")                    // Displays banner values that are coming over the serial port. Anything that prints to the serial will show up here.
                .setPosition(25, 650)
                .setSize (320, 85)
                .setFont(createFont("",10))
                .setLineHeight(14)
                .setColor(color(200))
                .setColorBackground(color(255, 100))
                .setColorForeground(color(255, 100));
  ;
  
  console = cp5.addConsole(myTextarea);                              // Not totally sure what this does  but was included with text area example from cp5.


  String[] cameras = Capture.list();                                 // Get list of available cameras.
  
  if (cameras.length == 0) {                                         // if there are no cameras available print that to serial.
      
      cameraStatus = 0;
      
  } else {
    //println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      //println(cameras[i]);
    }
    cam = new Capture (this, cameras[0]);
    cam.start();
  }
  
  for(int i=0; i<fadeOne; i++){                              // for statement to setup section fade
    oldStep1[i] = 0;
    oldBanner1[i] = 0;
  }
  
    for(int i=0; i<fadeTwo; i++){                              // for statement to setup section fade
    oldStep2[i] = 0;
    oldBanner2[i] = 0;
  }
}                                                            // close setup



void draw() {
  background(bg);                                     //load background image
  
    if(Section_1==false)                              // write Section_1 to the serial port, either a one or a zero.
  {
    GEOport.write('1');
  } else
  {
    GEOport.write('0');
  }
  if(Section_2==false)                                // write Section_2 to the serial port, either a one or a zero.
  {
    GEOport.write('1');
  }else
  {
    GEOport.write('0');
  }
    if(Section_3==false)                              // write Section_3 to the serial port, either a one or a zero.
  {
    GEOport.write('1');
  }else
  {
    GEOport.write('0');
  }
  
  noStroke();
  rect(25, 75, 330, 180);
  
  image(logo, 40, 100);

  stroke(237,57,149);                                  // Outer Frame in Magenta
  noFill();                                            // No Fill
  strokeWeight(1);                                      // Stroke weight
  rect(10, 10, 1900, 1060);                            // The border is 10px from the edge of the application
  line(370, 75, 370, 1005);                            // Pink Line Left
  line(1725, 75, 1725, 1005);                          // Pink Line Right
  line(380, 825, 1715, 825);                            //Horizontal Pink Line
  
  fill(237, 57, 149);
  ellipse(370, 80, 10, 10);
  ellipse(370, 1000, 10, 10);
  ellipse(1725, 80, 10, 10);
  ellipse(1725, 1000, 10, 10);
  triangle(380, 835, 380, 815, 390, 825);
  triangle(1715, 835, 1715, 815, 1705, 825);
  
  noFill();                                                // GEOmodel bed shape in upper right corner
  stroke(255,255,255);
  beginShape();
  vertex(1735,132);
  vertex(1790, 75);
  vertex(1845, 75);
  vertex(1900, 132);
  vertex(1900, 390);
  vertex(1845, 450);
  vertex(1790, 450);
  vertex(1735, 390);
  vertex(1735, 132);
  endShape();
  
  fill(255, 255, 255);
  textAlign(LEFT);
  
  SCPBold30 = loadFont("SCP-Bold-30.vlw");
  textFont(SCPBold30);
  text("REAL GEOcorder", 25, 40);
  
  SCPRegular24 = loadFont("SCP-Regular-24.vlw");
  textFont(SCPRegular24);
  text("2015.v.0.1", 25, 64);
  
  SCPRegular14 = loadFont("SCP-Regular-14.vlw");
  textFont(SCPRegular14);
  text("GEOcorder Status:", 60, 300);
  
  SCPRegular14 = loadFont("SCP-Regular-14.vlw");
  textFont(SCPRegular14);
  text(status, 200, 300);
  
  SCPRegular14 = loadFont("SCP-Regular-24.vlw");                                // 01_Control Panel Label
  textFont(SCPRegular24);
  text("01_Control Panel", 20, 1055);
  
  SCPRegular14 = loadFont("SCP-Regular-24.vlw");                                // 02_Surface Analysis Label
  textFont(SCPRegular24);
  text("02_Surface Analysis", 380, 855);
  
  SCPRegular14 = loadFont("SCP-Regular-24.vlw");                                // 03_Surface Analysis Label
  textFont(SCPRegular24);
  text("03_Vertical Analysis", 380, 1055);
  
  SCPRegular14 = loadFont("SCP-Regular-24.vlw");                                // 04_Model Data Label
  textFont(SCPRegular24);
  text("04_Model Data", 1735, 1055);
  
    if(mouseX > 25 && mouseX < 355 && mouseY > 75 && mouseY < 255) {            // mouse over makes a black background behind logo. Just for fun.
    fill(0,0,0);
  }else {
    fill(0,0,0,0);
  }
  
  float lightMap = map (lightValue, 40, 250, -225, 45);                          // remap light gauge values
  
  noStroke();                                                                      // Light Value Gauge
  strokeWeight(1);
  ellipseMode (CENTER);
  fill(30);
  ellipse(1818, 550, 100, 100);
  fill(255);
  arc(1818, 550, 80, 80, radians(-225), radians(lightMap),  PIE);
  fill(0);
  ellipse(1818, 550, 50, 50);
  
  fill(30);                                                                        // Empty Gauge for future use
  ellipse(1818, 685, 100, 100);
  fill(255);
  arc(1818, 685, 80, 80, radians(-225), radians(lightMap),  PIE);
  fill(0);
  ellipse(1818, 685, 50, 50);
  
  fill(30);                                                                        // Empty Gauge for future use
  ellipse(1818, 820, 100, 100);
  fill(255);
  arc(1818, 820, 80, 80, radians(-225), radians(lightMap),  PIE);
  fill(0);
  ellipse(1818, 820, 50, 50);
  
  fill(30);                                                                        // Empty Gauge for future use
  ellipse(1818, 955, 100, 100);
  fill(255);
  arc(1818, 955, 80, 80, radians(-225), radians(lightMap),  PIE);
  fill(0);
  ellipse(1818, 955, 50, 50);
  
  
  fill(255);
  
  SCPRegular14 = loadFont("SCP-Regular-14.vlw");
  textFont(SCPRegular14);
  textAlign(CENTER);
  text("Light Value", 1818, 620);
  
  SCPRegular14 = loadFont("SCP-Regular-14.vlw");
  textFont(SCPRegular14);
  textAlign(CENTER);
  text("Light Value", 1818, 620);

    
  if (cameraStatus == 1) {
  if (cam.available() == true && videoFeed==true) {
    cam.read();
     }
     image (cam, 25, 760, 320, 240);
  } else {
      fill(0);
      rect(25, 760, 320, 240);
      
      textAlign(LEFT);
      fill(255);
      SCPRegular14 = loadFont("SCP-Regular-14.vlw");
      textFont(SCPRegular14);
      text("No Camera Available", 35, 770);
  }


/*     
  if(videoFeed == true); {
      fill(0);
      rect(25, 760, 320, 240);
      
      textAlign(LEFT);
      fill(255);
      SCPRegular14 = loadFont("SCP-Regular-14.vlw");
      textFont(SCPRegular14);
      text("Video Feed Off", 35, 770);
  }
*/

 /////////////////////// START DRAWINGS THAT RELY ON ARDUINO INPUTS /////////////////////////////
 
  while (GEOport.available() > 0) {                       // as long as there is data coming from the serial port, reait and store it.
  serial = GEOport.readStringUntil(end);
  }
  if (serial != null) {                                // if the string is not empty, print the following
  
  float[] a = float(splitTokens(serial, ","));
  stepperDirection = a[0];
  stepperCount = a[1];
  bannerValue1 = a[2];
  bannerValue2 = a[3];
  bannerValue3 = a[4];
  
  //printArray(a);
  println(a[2], a[3], a[4]);                                        // prints bannerValue and lightValue to console. look at CP5 console example for key input control
  

 textAlign(LEFT);
 if(stepperDirection == 1) {                                                    // Stepper Motor Direction
  SCPRegular14 = loadFont("SCP-Regular-14.vlw");
  textFont(SCPRegular14);
  text("Moving Forward", 105, 530);
 } else if(stepperDirection == 2) {
     SCPRegular14 = loadFont("SCP-Regular-14.vlw");
     textFont(SCPRegular14);
     text("Moving Backward", 105, 530);
 } else if(stepperDirection == 3) {
       SCPRegular14 = loadFont("SCP-Regular-14.vlw");
       textFont(SCPRegular14);
       text("Stopped", 105, 530);
 }
 
  SCPRegular14 = loadFont("SCP-Regular-14.vlw");                            // Display step number.
  textFont(SCPRegular14);
  text(stepperCount, 105, 510);
  

 
 ////////// BANNER SECTION ONE ////////////////
 
 if(stepperDirection != 3) {
   
 float stepperMap1 = map (stepperCount, 0, 3000, 380, 1715);                      // remap stepperCount to section window

 float[] tempStep1 = new float[fadeOne];
 float[] tempBanner1 = new float[fadeOne];
 for(int i=0; i<fadeOne-1; i++){
   tempStep1[i+1] = oldStep1[i];
   tempBanner1[i+1] = oldBanner1[i];
 }
 tempStep1[0]=stepperMap1;
 tempBanner1[0]=bannerValue1;
   
   oldStep1=tempStep1;
   oldBanner1=tempBanner1;
   
   fill(0, 0);
   noStroke();
   rect(380, 855, 1335, 150);
   for(int i=0; i<fadeOne-1; i++){
  
  float fadeOld1 = map (i, 0, fadeOne, 255, 0);
  stroke(255, 255, 255, fadeOld1);
  strokeWeight(5);
  line(oldStep1[i], 1005, oldStep1[i], height - (oldBanner1[i+1]/4));            // change base height of section here
  
  if (stepperMap1 >= 1715) {
    stepperMap1 = 380;
  }
  else {
    stepperMap1++;
  }
   }
 }                                                                              // close if Stepper Direction
 
  ////////// BANNER SECTION TWO ////////////////
 
 if(stepperDirection != 3) {
   
 float stepperMap2 = map (stepperCount, 0, 3000, 380, 1715);                      // remap stepperCount to section window
   
 float[] tempStep2 = new float[fadeTwo];
 float[] tempBanner2 = new float[fadeTwo];
 for(int i=0; i<fadeTwo-1; i++){
   tempStep2[i+1] = oldStep2[i];
   tempBanner2[i+1] = oldBanner2[i];
 }
 tempStep2[0]=stepperMap2;
 tempBanner2[0]=bannerValue2;
   
   oldStep2=tempStep2;
   oldBanner2=tempBanner2;
   
   fill(0, 0);
   noStroke();
   rect(380, 855, 1335, 150);
   for(int i=0; i<fadeTwo-1; i++){
  
  float fadeOld2 = map (i, 0, fadeTwo, 255, 0);
  stroke(255, 255, 255, fadeOld2);
  strokeWeight(5);
  line(oldStep2[i], 905, oldStep2[i], (height+100) - (oldBanner2[i+1]/4));            // change base height of section here
  
  if (stepperMap2 >= 1715) {
    stepperMap2 = 380;
  }
  else {
    stepperMap2++;
  }
   }
 }                                                                              // close if Stepper Direction
 
   ////////// BANNER SECTION THREE ////////////////
 
 if(stepperDirection != 3) {
   
 float stepperMap3 = map (stepperCount, 0, 3000, 380, 1715);                      // remap stepperCount to section window
   
 float[] tempStep3 = new float[fadeThree];
 float[] tempBanner3 = new float[fadeThree];
 for(int i=0; i<fadeThree-1; i++){
   tempStep3[i+1] = oldStep3[i];
   tempBanner3[i+1] = oldBanner3[i];
 }
 tempStep3[0]=stepperMap3;
 tempBanner3[0]=bannerValue3;
   
   oldStep3=tempStep3;
   oldBanner3=tempBanner3;
   
   fill(0, 0);
   noStroke();
   rect(380, 855, 1335, 150);
   for(int i=0; i<fadeThree-1; i++){
  
  float fadeOld3 = map (i, 0, fadeThree, 255, 0);
  stroke(255, 255, 255, fadeOld3);
  strokeWeight(5);
  line(oldStep3[i], 805, oldStep3[i], (height+200) - (oldBanner3[i+1]/4));            // change base height of section here
  
  if (stepperMap3 >= 1715) {
    stepperMap3 = 380;
  }
  else {
    stepperMap3++;
  }
   }
 }                                                                              // close if Stepper Direction
 
 
 
 
}                                                                                // close if Serial is Null
}                                                                                // close draw loop


