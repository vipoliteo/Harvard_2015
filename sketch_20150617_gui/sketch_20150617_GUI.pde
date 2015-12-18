import controlP5.*;
import processing.video.*;
import processing.serial.*;

ControlP5 cp5;

Textarea myTextarea;                                    //added for Control P5 Console

PImage bg;
PImage logo;
PFont SCPBold30;
PFont SCPRegular24;
PFont SCPRegular14;

Capture cam;

/*int recAx = 25;
int recAy = 75;
int recAw = 330;
int recAh = 180;
*/

int c = 0;                                                    // added for CP5 console
int end = 10;                                                //length of string from serial port
int fadeOne=50;                                                // interger for fading section cut

float stepperDirection;                                      // direction of stepper motor
float stepperCount;                                          // step number
float bannerValue;                                          // value from banner sensor
float lightValue;                                            //value from light sensor
float stepperMap;                                            // stepper Value remapped to section window size.
float lightMap;

float[] oldStep = new float[fadeOne];
float[] oldBanner = new float[fadeOne];

String status;
String serial;                                        // declare string from Arduino Serial port

boolean toggleValue = false;
boolean videoFeed = false;
boolean verticalAnalysis = false;

Serial GEOport;                                          // Create Object from Serial Class

Println console;                                          // added for cp5 Console

void setup() {
  size(1920,1080);
  
  String portName = Serial.list()[0];
  GEOport = new Serial(this, portName, 9600);
  GEOport.clear();                                        //function from serial library that throws out the first reading, in case we started reading in the middle of a string from Arduino
  serial = GEOport.readStringUntil(end);                  //function that reads the string from serial port until a println and then assigns string to our string variable (called 'serial')
  serial = null;                                       // initially, the string will be null (empty)
  
  smooth();
  status = new String();
  bg = loadImage ("background.jpg");                  //bg is the background image, saved in sketch file
  logo = loadImage ("logo.png");                      // load logo image, this should eventually be updated to processing.
  cp5 = new ControlP5(this);
  cp5.enableShortcuts();                                // added from text area consol example from controlP5
  
  cp5.addToggle("GEOcorder Status")
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
  
  cp5.addToggle("videoFeed")
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
  
    cp5.addToggle("verticalAnalysis")
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
  
  frameRate(50);
  myTextarea = cp5.addTextarea("txt")
                .setPosition(25, 625)
                .setSize (320, 85)
                .setFont(createFont("",10))
                .setLineHeight(14)
                .setColor(color(200))
                .setColorBackground(color(255, 100))
                .setColorForeground(color(255, 100));
  ;
  
  console = cp5.addConsole(myTextarea); 

  
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {                                      // load camera
    //println("There are no cameras available for capture.");
    exit();
  } else {
    //println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      //println(cameras[i]);
    }
    cam = new Capture (this, cameras[0]);
    cam.start();
  }
  
  for(int i=0; i<fadeOne; i++){                              // for statement to setup section fade
    oldStep[i] = 0;
    oldBanner[i] = 0;
  }
}


void draw() {
  background(bg);                                     //load background image
  
  //printArray(a);                                              // this can be deleted later, its just to see the serial port incoming.
  
  while (GEOport.available() > 0) {                       // as long as there is data coming from the serial port, reait and store it.
  serial = GEOport.readStringUntil(end);
  }
  if (serial != null) {                                // if the string is not empty, print the following
  
  float[] a = float(splitTokens(serial, ","));
  stepperDirection = a[0];
  stepperCount = a[1];
  bannerValue = a[2];
  lightValue = a[3];
  
  //printArray(a);
  println(a[2], a[3]);                                        // prints bannerValue and lightValue to console. look at CP5 console example for key input control
  
  if(mouseX > 25 && mouseX < 355 && mouseY > 75 && mouseY < 255) {
    fill(0,0,0);
  }else {
    fill(0,0,0,0);
  }
  noStroke();
  rect(25, 75, 330, 180);
  
  image(logo, 40, 100);

  stroke(237,57,149);                                  // Outer Frame in Magenta
  noFill();                                            // No Fill
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
  
  noFill();
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
 
  SCPRegular14 = loadFont("SCP-Regular-14.vlw");
  textFont(SCPRegular14);
  text(stepperCount, 105, 510);
 
 
 float stepperMap = map (stepperCount, 0, 3000, 380, 1715);                      // remap stepperCount to section window
 
 float[] tempStep = new float[fadeOne];
 float[] tempBanner = new float[fadeOne];
 for(int i=0; i<fadeOne-1; i++){
   tempStep[i+1] = oldStep[i];
   tempBanner[i+1] = oldBanner[i];
 }
 tempStep[0]=stepperMap;
 tempBanner[0]=bannerValue;
   
   oldStep=tempStep;
   oldBanner=tempBanner;
   
   fill(0, 0);
   noStroke();
   rect(380, 855, 1335, 150);
   for(int i=0; i<fadeOne-1; i++){
  
  //float ypos = 1005 - (bannerValue/4);                                          // draw line
  stroke(255, (tempStep[i]*4));
  strokeWeight(5);
  line(oldStep[i], 1005, oldStep[i], height - (oldBanner[i+1]/4));
  
  if (stepperMap >= 1715) {
    stepperMap = 380;
  }
  else {
    stepperMap++;
  }
   }
  
  float lightMap = map (lightValue, 40, 250, -225, 45);
  
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
  
  /*
  noStroke();
  fill(255);
  ellipse(1818, 550, 100, 100);
  ellipse(1818, 685, 100, 100);
  ellipse(1818, 820, 100, 100);
  ellipse(1818, 955, 100, 100);
  
  {
  stroke(237,57,149);
  rotate(radians(lightMap), 1818, 550,0);
  line(1818, 550, 1793, 593);
  }
  */
  
  if (cam.available() == true && videoFeed==true) {
    cam.read();
  }
  image (cam, 25, 760, 320, 240);                   //webcam screen location and size. (find a way to make grayscale)
  
  if(verticalAnalysis==true)
  {
    GEOport.write('1');
  } else
  {
    GEOport.write('0');
  }
}
}


void toggle(boolean theFlag) {
  if(theFlag==true) {
    status = "Active";
  } else {
    status = "Off";
  }
}



