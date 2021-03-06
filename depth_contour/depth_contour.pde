import gab.opencv.*;
import KinectPV2.*;

KinectPV2 kinect;
OpenCV opencv;

float polygonFactor = .1;

int threshold = 10;

float maxD = 4.0f;
float minD = 0.5f;

boolean    contourBodyIndex = false;

void setup() { 
  size(700, 450, P3D);
  opencv = new OpenCV(this, 512, 424);
  kinect = new KinectPV2(this);
  kinect.enablePointCloud(true);
  kinect.enableBodyTrackImg(false);

  kinect.enableDepthImg(true);
  kinect.init();
}

void draw() {
  background(0);

  noFill();
  strokeWeight(.5);

  image(kinect.getDepthImage(), 150, 10);

  opencv.loadImage(kinect.getPointCloudDepthImage());
  opencv.gray();
  opencv.threshold(threshold);
  PImage dst = opencv.getOutput();

  ArrayList<Contour> contours = opencv.findContours(false, false);

  if (contours.size() > 0) {
    for (Contour contour : contours) {

      contour.setPolygonApproximationFactor(polygonFactor);
      if (contour.numPoints() > 50) {

        stroke(0, 200, 200);
        beginShape();

        for (PVector point : contour.getPolygonApproximation ().getPoints()) {
          vertex(point.x + 150, point.y + 10);
        }
        endShape();
      }
    }
  }

  noStroke();
  fill(0);
  rect(0, 0, 130, 100);
  fill(255, 0, 0);
  text("fps: "+frameRate, 20, 20);
  text("threshold: "+threshold, 20, 40);
  text("minD: "+minD, 20, 60);
  text("maxD: "+maxD, 20, 80);

  kinect.setLowThresholdPC(minD);
  kinect.setHighThresholdPC(maxD);
}


void keyPressed() {
  //change contour finder from contour body to depth-PC
  if ( key == 'b') {
    contourBodyIndex = !contourBodyIndex;
    if (contourBodyIndex)
      threshold = 200;
    else
      threshold = 40;
  }

  if (key == 'a') {
    threshold+=1;
  }
  if (key == 's') {
    threshold-=1;
  }

  if (key == '1') {
    minD += 0.01;
  }

  if (key == '2') {
    minD -= 0.01;
  }

  if (key == '3') {
    maxD += 0.01;
  }

  if (key == '4') {
    maxD -= 0.01;
  }

  if (key == '5')
    polygonFactor += 0.1;

  if (key == '6')
    polygonFactor -= 0.1;
}

