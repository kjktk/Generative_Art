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
int numFlocks = 300;
int numBarriers = 5;
int numWagara = 1;
int interval = 0;
int timer = 10;
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

PShape logo;

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
ArrayList <Net> nets;

boolean gameStart = false;
boolean result = false;
boolean question = false;
boolean title = true;

boolean[] button1 = new boolean[4];
boolean[] button2 = new boolean[4];

boolean[] answerFlag = new boolean[4];
boolean[] enjoyFlag = new boolean[4];
boolean answer = false;

int _frameCount = 0;

PFont myFont = createFont("HiraMinPro-W6",50);

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
  for (int i = 0; i < 20; i++) {
    int flockType = Math.round(random(3, 4));
    flock.addBoid(new Boid(random(width), random(height), flockType));
  }
  nets = new ArrayList<Net>();
  ripples = new ArrayList<Ripple>();

  //  wagara = new ArrayList<PixelArt>();
  //  for (int i = 0; i < numWagara; i++) {
  //    wagaraImg = loadImage("http://image.mapple.net/ocol/photol/00/00/00/18/54_120061103_1_1.jpg");
  //    wagara.add(new PixelArt(random(width),random(height),wagaraImg));
  //  }
  float posX = width / 4;
  float posY = height / 4;
  nets.add(new Net(posX*1, posY*1, 100, 0));
  nets.add(new Net(posX*3, posY*1, 100, 90));
  nets.add(new Net(posX*1, posY*3, 100, 180));
  nets.add(new Net(posX*3, posY*3, 100, 270));

  //OSC
  if (useOSC) {
    osc = new OscP5(this, 9000);
    for (int i = 1; i < 5; i++) { 
      osc.plug(this, "pry"+i, "/wii/"+i+"/accel/pry");
      osc.plug(this, "accel"+i, "/wii/"+i+"/accel/xyz");
      osc.plug(this, "buttonA"+i, "/wii/"+i+"/button/A");
      osc.plug(this, "button1"+i, "/wii/"+i+"/button/A");
      osc.plug(this, "button2"+i, "/wii/"+i+"/button/A");
    }
  }

  logo = loadShape("logo.svg");
  //syphon
  server = new SyphonServer(this, "Processing Syphon");
}

void draw() {
  if (gameStart) {
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
    for (int i = 0; i < nets.size (); i++) {
      Net n = nets.get(i);
      n.run();
      //n.move(width/2 + width*roll[i],height/2 + height*pitch[i]);
      diffAccel[i] = initAccel[i] - accel[i];
      initAccel[i] = accel[i];
      //println(" accel"+0+":"+ diffAccel[0]);
      if (abs(diffAccel[i]) > 0.1) {
        n.catchCarp(flock.boids);
      }
    }
    for (int i = 0; i < ripples.size (); i++) {
      Ripple r = ripples.get(i);
      r.run();
      if (r.flag = false) {
        ripples.remove(i);
      }
    }
    if (frameCount % 30 == int(random(2))) {
      if (flock.boids.size() < numFlocks) {
        for (int i = 0; i < int (random (10)); i++) {
          int flockType = Math.round(random(3, 4));
          flock.addBoid(new Boid(random(width), random(height), flockType));
        }
      }
      int rippleX = int(random(200, width - 200));
      int rippleY = int(random(200, height - 200));
      flock.pull(rippleX, rippleY);
      ripples.add(new Ripple(rippleX, rippleY, random(5, 10), int(random(180, 200))));
    }
    if (_frameCount > timer*30) {
      gameStart = false;
      result = true;
      _frameCount = 0;
    }
    popStyle();
    _frameCount++;
  } else if (result) {
    pushStyle();
    textAlign(CENTER);
    textFont(myFont);
    for (int i = 0; i < nets.size (); i++) {
      Net n = nets.get(i);
      fill(90*i, 50, 100);
      text(n.score, width/2, height/5 * (i +1));
    }
    fill(0, 100);
    rect(-20, -20, width+40, height+40);
    popStyle();
    if (_frameCount > timer*10) {
      result = false;
      question = true;
      _frameCount = 0;
    }
    _frameCount++;
  } else if (question) {
    pushStyle();
    textAlign(CENTER);
    textFont(myFont);
    text("楽しかった！ : 1", width/2, height/3*1);
    text("つまらなかった！ : 2", width/2, height/3*2);
    fill(0, 10);
    rect(-20, -20, width+40, height+40);
    popStyle();
    for (int i = 0; i < 4; i++) {
      if (button1[i] == true || button2[i] == true) {
        answerFlag[i] = true;
        if (button1[i] == true) {
          enjoyFlag[i] = true ;
          println("enjoy :"+i);
        } else { 
          enjoyFlag[i] = false;
        }
      }
      if (answerFlag[0] == true && answerFlag[1] == true && answerFlag[2] == true && answerFlag[3] == true) {
        answer = true;
      }
    }
    if (_frameCount > timer*60 || answer == true) {
      question = false;
      title = true;
      _frameCount = 0;
    }
    _frameCount++;
  } else if (title){
    pushStyle();
    fill(random(360),100,100);
    textAlign(CENTER);
    shape(logo, width/2 - logo.width, height/5*2 -logo.height, logo.width* 2, logo.height*2);
    textFont(myFont);
    text("Aボタンを押してね !", width/2, height/5 * 3);
    fill(0, 10);
    rect(-20, -20, width+40, height+40);
    popStyle();
  }
  server.sendImage(g);
}

void mousePressed() {
  if ( mouseMode == "PLAY" ) {
    flock.pull(mouseX, mouseY);
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

PImage titleImage() {
  fill(0, 50);
  rect(-20, -20, width+40, height+40); //fixed

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
void accel1(float _x, float _y, float _z) {
  //  println("x:"+ _x);
  //  println("y:"+ _y);
  //  println("z:"+ _z);
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

void buttonA1(float _value) {
  if (_value > 0) {
    gameStart = true;
  }
}
void buttonA2(float _value) {
  if (_value > 0) {
    gameStart = true;
  }
}
void buttonA3(float _value) {
  if (_value > 0) {
    gameStart = true;
  }
}
void buttonA4(float _value) {
  if (_value > 0) {
    gameStart = true;
  }
}
void button11(float _value) {
  if (_value > 0) {
    button1[0] = true;
  } else {
    button1[0] = false;
  }
}
void button21(float _value) {
  if (_value > 0) {
    button2[0] = true;
  } else {
    button2[0] = false;
  }
}
void button12(float _value) {
  if (_value > 0) {
    button1[1] = true;
  }
}
void button22(float _value) {
  if (_value > 0) {
    button1[1] = false;
  }
}
void button13(float _value) {
  if (_value > 0) {
    button1[2] = true;
  }
}
void button23(float _value) {
  if (_value > 0) {
    button1[2] = false;
  }
}
void button14(float _value) {
  if (_value > 0) {
    button1[3] = true;
  }
}
void button24(float _value) {
  if (_value > 0) {
    button1[3] = false;
  }
}

