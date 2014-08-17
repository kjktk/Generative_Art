import processing.serial.*;
import codeanticode.syphon.*;
import processing.opengl.*;
import javax.media.opengl.*;
import javax.media.opengl.GL2;
import controlP5.*;
import fullscreen.*;
import ddf.minim.*;
import ddf.minim.effects.*;
import oscP5.*;
import netP5.*;

int numRipples = 10;
int numFlocks = 50;
int numBarriers = 5;
int numWagara = 5;
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
Serial port;

PShape s;

GL2 gl;

OscP5 osc;

float pitch;
float roll;
float yaw;
float accel;
float buttonA;
boolean useOSC = true;
boolean useSerial = false;
float initYaw = yaw;
float initPitch = pitch;
float initRoll = roll;
float diffYaw;
float diffPitch;
float diffRoll;

Flock flock;

ArrayList <PixelArt> wagara;

void setup() { 
  //base setting
  size(displayWidth,displayHeight,OPENGL);
  colorMode(HSB,360,100,100);
  background(0);
  frameRate(24);
  smooth();
  noCursor();
  
  //Serial
  if (useSerial) {
    println(Serial.list());
    port = new Serial(this, Serial.list()[5], 9600);
    port.bufferUntil('\n');
  }

  //minim
  minim = new Minim(this);
  bgm = minim.loadFile("loop.mp3");
  //bgm.play();
  seAdd = minim.loadFile("button01a.mp3");

  //flock
  flock = new Flock();
  for (int i = 0; i < numFlocks; i++) {
    int flockType = Math.round(random(3,4));
    flock.addBoid(new Boid(random(width),random(height),flockType));
  }
  
  wagara = new ArrayList<PixelArt>();
  for (int i = 0; i < numWagara; i++) {
    PImage[] img = new PImage[4];
    
  }
  
  //OSC
  if (useOSC) {
    osc = new OscP5(this,9000);
  
    osc.plug(this,"pry","/wii/1/accel/pry");
    osc.plug(this,"pitch","/wii/1/accel/pry/0");
    osc.plug(this,"roll","/wii/1/accel/pry/1");
    osc.plug(this,"yaw","/wii/1/accel/pry/2");
    osc.plug(this,"accel","/wii/1/accel/pry/3");
    osc.plug(this,"pushA","/wii/1/button/A");
  }
  //syphon
  server = new SyphonServer(this, "Processing Syphon");
}

void draw() {
  fill(0,60);
  rect(-20, -20, width+40, height+40);
  pushStyle();
  blendMode(ADD);
  //flock
  flock.run();
  if (accel < 0.5) {
    initYaw = yaw;
    initPitch = pitch;
    initRoll = roll;
  } else {
    diffYaw = yaw - initYaw;
    diffPitch = pitch - initPitch;
    diffRoll = roll - initRoll;
    flock.pull(random(0,width), random(0,height));
    for(int i = 0;i < numRipples ; i++) {
      flock.addRipple(new Ripple(int(width/2 + width*diffYaw),int(height/2 - height*diffPitch),30*accel,int(random(180,200))));
    }
    seAdd.play();
    seAdd.rewind();
  }

  popStyle();
  
  server.sendImage(g);
  
  println(" accel: "+accel);

}

void mousePressed() {
  if( mouseMode == "PLAY" ) {
    flock.pull(mouseX,mouseY);
    for(int i = 0;i < numRipples ; i++) {
      flock.addRipple(new Ripple(mouseX,mouseY,random(5,10),int(random(180,200))));
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

void serialEvent(Serial p) {
  String sensorString = port.readStringUntil('\n');
  println(sensorString);
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

void stop() {
  bgm.close();
  minim.stop();
  super.stop();
}

void pry(float _pitch, float _roll, float _yaw, float _accel) {
  pitch = -1 * (_pitch - 0.5);
  roll = _roll - 0.5;
  yaw = _yaw - 0.5;
  accel = _accel;
}

void remoteRipple(float _pitch,float _roll, float _yaw, float _accel) {

}
