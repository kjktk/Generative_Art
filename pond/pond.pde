import processing.opengl.*;
import controlP5.*;
import fullscreen.*;

int numRipples = 1;
int numFlocks = 50;
int numBarriers = 5;
int interval = 0;
String mouseMode = "PLAY";
Boolean debug = false;
color[] pixelBuffer;
PGraphics pg;
PImage img;
PImage mask;

Flock flock;
void setup() {
  //new FullScreen(this).enter();
  size(1280,720);
  colorMode(HSB,360,100,100);
  frameRate(30);
  smooth();
  //noCursor();
  
  mask = loadImage("mask.png");
  flock = new Flock();
  
  for (int i = 0; i < numFlocks; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(random(width),random(height),flockType));
  }
  

  background(0);
}

void draw() {
  fill(0,50);
  drawGrid();
  rect(-20, -20, width+40, height+40); //fixed
  flock.run();
  //image(mask,0,0);
}

void mousePressed() {
  if( mouseMode == "PLAY" ) {
    flock.pull(mouseX,mouseY);
    for(int i = 0;i < numRipples ; i++) {
      flock.addRipple(new Ripple(mouseX,mouseY,random(5,20),int(random(180,200))));
    }
  }
  else if ( mouseMode == "ADD" ) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(mouseX,mouseY,flockType));
  }
  else if ( mouseMode == "BARRIER" ) {
    flock.addBarrier(new Barrier(mouseX,mouseY,random(90)));
  }
}

void keyPressed() {
  if (key == '1') {
      mouseMode = "PLAY";
  } else if (key == '2') {
      mouseMode = "ADD";
  } else if (key == '3') {
      mouseMode = "BARRIER";
  } else if (key == '4') {
      mouseMode = "LOTUS";
  } else if (key == '5') {
      mouseMode = "AJUST";
  } else if (key == '6') {
      mouseMode = "MASK";
  }
  if (key == ENTER) {
    if (debug == true) {
      debug = false;
    } else {
      debug = true;
    }
  }
}
void debugMode() {
 
}

void drawGrid() {
  int gridSize = 10;
  stroke(127, 127);
  strokeWeight(1);
  for (int x = 0; x < width; x+=gridSize) {
    line(x, 0, x, height);
  }
  for (int y = 0; y < height; y+=gridSize) {
    line(0, y, width, y);
  }
}
PImage renderImage() {
  fill(0,50);
  rect(-20, -20, width+40, height+40); //fixed
  flock.run();
  
  loadPixels();
  arrayCopy(pixels,pixelBuffer);
  for (int i = 0; i < width * height; i++) {
    pixels[i] = 0;
  }
  updatePixels();
  pg.beginDraw();
  pg.smooth();
  pg.loadPixels();
  for (int i = 0; i < width * height; i++) {
    pg.pixels[i] = pixelBuffer[i];
  }
  pg.updatePixels();
  pg.endDraw();
  PImage img = pg.get(0,0,pg.width,pg.height);
  return img;
}
