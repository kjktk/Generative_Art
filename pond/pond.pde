import codeanticode.syphon.*;
import processing.opengl.*;
import controlP5.*;
import fullscreen.*;
import ddf.minim.*;
import ddf.minim.effects.*;

int numRipples = 1;
int numFlocks = 50;
int numBarriers = 5;
int interval = 0;
String mouseMode = "PLAY";
Boolean debug = false;
color[] pixelBuffer;
PGraphics pg;
PImage img;
Minim minim;
AudioPlayer bgm;
AudioPlayer seAdd;
SyphonServer server;

Flock flock;
void setup() {
  //base setting
  size(displayWidth,displayHeight,P3D);
  colorMode(HSB,360,100,100);
  background(0);
  frameRate(30);
  smooth();
  //noCursor();

  //minim
  minim = new Minim(this);
  bgm = minim.loadFile("loop.mp3");
  //bgm.play();
  seAdd = minim.loadFile("button01a.mp3");

  //flock
  flock = new Flock();
  for (int i = 0; i < numFlocks; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(random(width),random(height),flockType));
  }

  //syphon
  server = new SyphonServer(this, "Processing Syphon");
}

void draw() {
  fill(0,50);
  drawGrid();
  rect(-20, -20, width+40, height+40); //fixed
  flock.run();
  server.sendImage(g);
}

void stop() {
  bgm.close();
  minim.stop();
  super.stop();
}

void mousePressed() {
  if( mouseMode == "PLAY" ) {
    flock.pull(mouseX,mouseY);
    for(int i = 0;i < numRipples ; i++) {
      flock.addRipple(new Ripple(mouseX,mouseY,random(5,20),int(random(180,200))));
    }
    seAdd.play();
    seAdd.rewind();
  }
  else if ( mouseMode == "ADD" ) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(mouseX,mouseY,flockType));
    seAdd.play();
    seAdd.rewind();

  }
  else if ( mouseMode == "BARRIER" ) {
    flock.addBarrier(new Barrier(mouseX,mouseY,random(90)));
  }
}

void keyPressed() {
  switch(key) {
    case 1:
      mouseMode = "PLAY";
      break;
    case 2:
      mouseMode = "ADD";
      break;
    case 3:
      mouseMode = "BARRIER";
      break;
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
