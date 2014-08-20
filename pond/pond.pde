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
int numFlocks = 200;
int numBarriers = 5;
int numWagara = 1;
int interval = 0;
String mouseMode = "PLAY";
Boolean debug = false;
color[] pixelBuffer;
PGraphics pg;
PImage wagaraImg;
Minim minim;
AudioPlayer bgm;
AudioPlayer seAdd;
SyphonServer server;
Serial port;

PShape s;

GL2 gl;

OscP5 osc;



float[] pitch = new float[4];
float[] roll = new float[4];
float[] yaw = new float[4];
float[] accel = new float[4];
float buttonA;
boolean useOSC = true;
boolean useSerial = false;
float[] diffAccel = new float[4];
float[] initAccel = new float[4];

PImage img;

Flock flock;

ArrayList <PixelArt> wagara;
ArrayList <Ripple> ripples;

void setup() {
  //base setting
  size(displayWidth, displayHeight, OPENGL);
  colorMode(HSB, 360, 100, 100);
  background(0);
  frameRate(30);
  smooth();
  //noCursor();

  //Serial
  if (useSerial) {
    println(Serial.list());
    port = new Serial(this, Serial.list()[5], 9600);
    port.bufferUntil('\n');
  }

  //minim
  minim = new Minim(this);
  bgm = minim.loadFile("loop.mp3");

  bgm.loop();
  seAdd = minim.loadFile("button01a.mp3");

  //flock
  flock = new Flock();
  for (int i = 0; i < numFlocks; i++) {
    int flockType = Math.round(random(3, 4));
    flock.addBoid(new Boid(random(width), random(height), flockType));
  }

  ripples = new ArrayList<Ripple>();

  //  wagara = new ArrayList<PixelArt>();
  //  for (int i = 0; i < numWagara; i++) {
  //    wagaraImg = loadImage("http://image.mapple.net/ocol/photol/00/00/00/18/54_120061103_1_1.jpg");
  //    wagara.add(new PixelArt(random(width),random(height),wagaraImg));
  //  }
  float posX = width / 4;
  float posY = height / 4;
  flock.addBarrier(new Barrier(posX*1, posY*1, 100));
  flock.addBarrier(new Barrier(posX*3, posY*1, 100));
  flock.addBarrier(new Barrier(posX*1, posY*3, 100));
  flock.addBarrier(new Barrier(posX*3, posY*3, 100));
  
  flock.addBarrier(new Barrier(-height, height/2, height/2));
  flock.addBarrier(new Barrier(width+height, height/2, height/2));
  //OSC
  if (useOSC) {
    osc = new OscP5(this, 9000);
    for (int i = 1; i < 5; i++) { 
      osc.plug(this, "pry"+i, "/wii/"+i+"/accel/pry");
      osc.plug(this, "pitch"+i, "/wii/"+i+"/accel/pry/0");
      osc.plug(this, "roll"+i, "/wii/"+i+"/accel/pry/1");
      osc.plug(this, "yaw"+i, "/wii/"+i+"/accel/pry/2");
      osc.plug(this, "accel"+i, "/wii/"+i+"/accel/pry/3");
      osc.plug(this, "pushA"+i, "/wii/"+i+"/button/A");
    }
  }
  //syphon
  server = new SyphonServer(this, "Processing Syphon");
}

void draw() {

  pushStyle();
  fill(0, 10);
  rect(-20, -20, width+40, height+40);
  popStyle();
  pushStyle();
  blendMode(ADD);
  //flock
  flock.run();
  //  for (PixelArt w : wagara) {
  //    w.update();
  //    w.move(mouseX,mouseY);
  //  }

  for (int i = 0; i < ripples.size(); i++) {
    Ripple r = ripples.get(i);
    r.run();
    if (r.flag = false) {
      ripples.remove(i);
    }
  }
  if (frameCount % 30 == int(random(2))) {
    int rippleX = int(random(200,width - 200));
    int rippleY = int(random(200,height - 200));
    flock.pull(rippleX, rippleY);
    ripples.add(new Ripple(rippleX, rippleY, random(5, 10), int(random(180, 200))));
  }

  for (int i = 0; i < 4; i++) { 
    diffAccel[i] = initAccel[i] - accel[i];
    initAccel[i] = accel[i];
    if (abs(diffAccel[i]) > 0.05) {
      println(" accel"+0+":"+ diffAccel[0]);
    }
  }
  popStyle();

  server.sendImage(g);
}

void mousePressed() {
  if ( mouseMode == "PLAY" ) {
    flock.pull(mouseX, mouseY);

    seAdd.play();
    seAdd.rewind();
  } else if ( mouseMode == "ADD" ) {
    int flockType = Math.round(random(0, 4));
    flock.addBoid(new Boid(mouseX, mouseY, flockType));
    seAdd.play();
    seAdd.rewind();
  } else if ( mouseMode == "BARRIER" ) {
    flock.addBarrier(new Barrier(mouseX, mouseY, random(90)));
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
void serialEvent(Serial p) {
  String sensorString = port.readStringUntil('\n');
  println(sensorString);
}

void drawGrid() {
  int gridSize = 10;
  pushStyle();
  stroke(127, 127);
  strokeWeight(1);
  for (int x = 0; x < width; x+=gridSize) {
    line(x, 0, x, height);
  }
  for (int y = 0; y < height; y+=gridSize) {
    line(0, y, width, y);
  }
  popStyle();
}


PImage renderImage() {
  fill(0, 50);
  rect(-20, -20, width+40, height+40); //fixed
  flock.run();

  loadPixels();
  arrayCopy(pixels, pixelBuffer);
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
  PImage img = pg.get(0, 0, pg.width, pg.height);
  return img;
}

void stop() {
  bgm.close();
  minim.stop();
  super.stop();
}

void pry1(float _pitch, float _roll, float _yaw, float _accel) {
  pitch[0]= -1 * (_pitch - 0.5);
  roll[0] = _roll - 0.5;
  yaw[0] = _yaw - 0.5;
  accel[0] = _accel;
}
void pry2(float _pitch, float _roll, float _yaw, float _accel) {
  pitch[1]= -1 * (_pitch - 0.5);
  roll[1] = _roll - 0.5;
  yaw[1] = _yaw - 0.5;
  accel[1] = _accel;
}
void pry3(float _pitch, float _roll, float _yaw, float _accel) {
  pitch[2]= -1 * (_pitch - 0.5);
  roll[2] = _roll - 0.5;
  yaw[2] = _yaw - 0.5;
  accel[2] = _accel;
}
void pry4(float _pitch, float _roll, float _yaw, float _accel) {
  pitch[3]= -1 * (_pitch - 0.5);
  roll[3] = _roll - 0.5;
  yaw[3] = _yaw - 0.5;
  accel[3] = _accel;
}

