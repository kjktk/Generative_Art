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

final int MAX_PARTICLE = 15;
Particle[] p = new Particle[MAX_PARTICLE];
final int LIGHT_FORCE_RATIO = 5;
final int LIGHT_DISTANCE= 75 * 75;
final int BORDER = 75;
float baseRed, baseGreen, baseBlue;
float baseRedAdd, baseGreenAdd, baseBlueAdd;
final float RED_ADD = 1.2;   
final float GREEN_ADD = 1.7;  
final float BLUE_ADD = 2.3;   

void setup() { 
  //base setting
  size(displayWidth,displayHeight,OPENGL);
  colorMode(HSB,360,100,100);
  background(0);
  frameRate(60);
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
    flock.addBoid(new Boid(width/2,height/2,flockType));
  }
  
  //Particle
  for (int i = 0; i < MAX_PARTICLE; i++) {
    p[i] = new Particle();
  }
  baseRed = 0;
  baseRedAdd = RED_ADD;
 
  baseGreen = 0;
  baseGreenAdd = GREEN_ADD;
 
  baseBlue = 0;
  baseBlueAdd = BLUE_ADD;
  
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
  rect(-20, -20, width+40, height+40); //fixed
  pushStyle();
  blendMode(ADD);
  //drawGrid();
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
    for (int pid = 0; pid < MAX_PARTICLE; pid++) {
      p[pid].explode();
    }
  }
  //Particle
  baseRed += baseRedAdd;
  baseGreen += baseGreenAdd;
  baseBlue += baseBlueAdd;
  
  colorOutCheck();
  for (int pid = 0; pid < MAX_PARTICLE; pid++) {
    p[pid].move(width /2, height /2);
  }
  int tRed = (int)baseRed;
  int tGreen = (int)baseGreen;
  int tBlue = (int)baseBlue;
  tRed *= tRed;
  tGreen *= tGreen;
  tBlue *= tBlue;
  loadPixels();
  for (int pid = 0; pid < MAX_PARTICLE; pid++) {
    int left = max(0, p[pid].x - BORDER);
    int right = min(width, p[pid].x + BORDER);
    int top = max(0, p[pid].y - BORDER);
    int bottom = min(height, p[pid].y + BORDER);
 
    for (int y = top; y < bottom; y++) {
      for (int x = left; x < right; x++) {
        int pixelIndex = x + y * width;
 
        int r = pixels[pixelIndex] >> 16 & 0xFF;
        int g = pixels[pixelIndex] >> 8 & 0xFF;
        int b = pixels[pixelIndex] & 0xFF;
 
        int dx = x - p[pid].x;
        int dy = y - p[pid].y;
        int distance = (dx * dx) + (dy * dy);
 
        if (distance < LIGHT_DISTANCE) {
          int fixFistance = distance * LIGHT_FORCE_RATIO;
          if (fixFistance == 0) {
            fixFistance = 1;
          }   
          r = r + tRed / fixFistance;
          g = g + tGreen / fixFistance;
          b = b + tBlue / fixFistance;
        }
        pixels[x + y * width] = color(r, g, b);
      }
    }
  }
  updatePixels();
  popStyle();
  server.sendImage(g);
  
  println(" accel: "+accel);

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

void colorOutCheck() {
  if (baseRed < 10) {
    baseRed = 10;
    baseRedAdd *= -1;
  }
  else if (baseRed > 255) {
    baseRed = 255;
    baseRedAdd *= -1;
  }
 
  if (baseGreen < 10) {
    baseGreen = 10;
    baseGreenAdd *= -1;
  }
  else if (baseGreen > 255) {
    baseGreen = 255;
    baseGreenAdd *= -1;
  }
 
  if (baseBlue < 10) {
    baseBlue = 10;
    baseBlueAdd *= -1;
  }
  else if (baseBlue > 255) {
    baseBlue = 255;
    baseBlueAdd *= -1;
  }
}

void pry(float _pitch, float _roll, float _yaw, float _accel) {
  pitch = -1 * (_pitch - 0.5);
  roll = _roll - 0.5;
  yaw = _yaw - 0.5;
  accel = _accel;
}

void remoteRipple(float _pitch,float _roll, float _yaw, float _accel) {

}

//void pushA(float _buttonA) {
//  int flockType = Math.round(random(0,4));
//  flock.addBoid(new Boid(random(0,width),random(0,height),flockType));
//    seAdd.play();
//    seAdd.rewind();
//}
