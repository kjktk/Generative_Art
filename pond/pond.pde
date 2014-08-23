import processing.video.*;
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
int numFlocks = 150;
int numBarriers = 5;
int numWagara = 1;
int interval = 0;
int timer = 30;
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

boolean useOSC = true;
boolean useSerial = false;
float[] diffAccel = new float[4];
float[] initAccel = new float[4];

int selected = -1;  // 選択されている頂点
int pos[][] = {
  {
    0, 0
  }
  , {
    width, 0
  }
  , {
    width, height
  }
  , {
    0, height
  }
}; // 頂点座標

PImage img;

Flock flock;

ArrayList <PixelArt> wagara;
ArrayList <Ripple> ripples;
ArrayList <Net> nets;

boolean gameStart = false;
boolean result = false;
boolean question = false;
boolean title = true;

boolean[] button1 = {true,true,true,true};
boolean[] buttonA = new boolean[4];
boolean[] answerFlag = new boolean[4];
boolean[] enjoyFlag = new boolean[4];
boolean answer = false;

int _frameCount = 0;

String date;

PFont myFont = createFont("HiraMinPro-W6", 50);

PrintWriter writer;

int hightScore = 0;

void setup() {
  //base setting
  size(displayWidth, displayHeight, OPENGL);
  colorMode(HSB, 360, 100, 100);
  background(0);
  frameRate(30);
  smooth();
  //noCursor();

  writer = createWriter(nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2)+".csv");
  date = nf(year(), 4) +"年"+ nf(month(), 2) +"月"+ nf(day(), 2) +"日"+ nf(hour(), 2) +"時"+ nf(minute(), 2) + "分" + nf(second(), 2) + "秒";
  writer.println("日付,評価,スコア,プレイヤー番号");

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

  nets = new ArrayList<Net>();
  ripples = new ArrayList<Ripple>();
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
      osc.plug(this, "button1"+i, "/wii/"+i+"/button/1");
      osc.plug(this, "button2"+i, "/wii/"+i+"/button/2");
      osc.plug(this, "up"+i, "/wii/"+i+"/button/Up");
      osc.plug(this, "right"+i, "/wii/"+i+"/button/Right");
      osc.plug(this, "left"+i, "/wii/"+i+"/button/Left");
      osc.plug(this, "down"+i, "/wii/"+i+"/button/Down");
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
    for (int i = 0; i < nets.size (); i++) {
      Net n = nets.get(i);
      n.run();
      //n.move(width/2 + width*roll[i],height/2 + height*pitch[i]);
      diffAccel[i] = initAccel[i] - accel[i];
      initAccel[i] = accel[i];
      if (abs(diffAccel[i]) > 0.15) {
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
    if (frameCount % 10 == int(random(3))) {
      if (flock.boids.size() < numFlocks) {
        for (int i = 0; i < int (random (30)); i++) {
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
      question = false;
      title = false;
      _frameCount = 0;
    }
    popStyle();
    _frameCount++;
  } else if (result) {
    //スコア表示画面
    float posX = width / 4;
    float posY = height / 4;
    nets.get(0).move(posX*1, posY*1);
    nets.get(1).move(posX*3, posY*1);
    nets.get(2).move(posX*1, posY*3);
    nets.get(3).move(posX*3, posY*3);
    for (int i = 0; i < flock.boids.size(); i++) {
        flock.boids.remove(i);
    }
    pushStyle();
    fill(0, 10);
    rect(-20, -20, width+40, height+40);
    popStyle();
    pushStyle();
    blendMode(ADD);
    textAlign(CENTER);
    textFont(myFont, 100);
    text("スコア", width/2, height/10*5);
    for (int i = 0; i < nets.size (); i++) {
      Net n = nets.get(i);
      n.is_score = true;
      if (n.score > hightScore) {
        hightScore = n.score;
      }
      n.run();
    }
    for (int i = 0; i < nets.size (); i++) {
      Net n = nets.get(i);
      if(n.score == hightScore) {
        n.isHightScore = true;
      }
    }
    popStyle();
    //10秒たったら画面遷移
    if (_frameCount > timer*10) {
      for (int i = 0; i < nets.size (); i++) {
        Net n = nets.get(i);
        n.isHightScore = false;
      }
      gameStart = false;
      result = false;
      question = true;
      title = false;
      _frameCount = 0;
    }
    _frameCount++;
  } else if (question) {
    //アンケート画面
    pushStyle();
    fill(0, 10);
    rect(-20, -20, width+40, height+40);
    popStyle();
    pushStyle();
    blendMode(ADD);
    textAlign(CENTER);
    textFont(myFont, 90);
    text("アンケート", width/2, height/11*3);
    textFont(myFont, 50);
    text("楽しかった: 1", width/2, height/11*5);
    text("つまらなかった: 2", width/2, height/11*6);
    text("決定: A", width/2, height/11*8);
    for (int i = 0; i < nets.size (); i++) {
      Net n = nets.get(i);
      n.is_score = false;
      n.is_question = true;
      n.run();
      if (n.answer == false) {
        if (button1[i]) {
          n.question = 1;
        } else {
          n.question = 2;
        }
        if (buttonA[i]) {
          n.answer();
          writer.println(date+","+n.question+","+n.score+","+i);
          answerFlag[i]= true;
          writer.flush();
        }
      }
    }
    if (answerFlag[0] == true && answerFlag[1] == true && answerFlag[2] == true && answerFlag[3] == true) {
      answer = true;
    }
    popStyle();
    if (_frameCount > timer*20 || answer == true) {
      gameStart = false;
      result = false;
      question = false;
      title = true;
      for (int i = 0; i < nets.size (); i++) {
        Net n = nets.get(i);
        n.is_question = false;
        n.answer = false;
      }
      _frameCount = 0;
    }
    _frameCount++;
  } else if (title) {
    pushStyle();
    blendMode(ADD);
    fill(0, 10);
    rect(-20, -20, width+40, height+40);
    popStyle();
    pushStyle();
    fill(random(360), 50, 100);
    textAlign(CENTER);
    shape(logo, width/2 - logo.width, height/5*2 -logo.height, logo.width* 2, logo.height*2);
    textFont(myFont);
    text("Aボタンを押してね !", width/2, height/5 * 3);
    for (int i = 0; i < ripples.size (); i++) {
      Ripple r = ripples.get(i);
      r.run();
      if (r.flag = false) {
        ripples.remove(i);
      }
    }
    if (frameCount % 10 == int(random(3))) {
      int rippleX = int(random(200, width - 200));
      int rippleY = int(random(200, height - 200));
      flock.pull(rippleX, rippleY);
      ripples.add(new Ripple(rippleX, rippleY, random(5, 10), int(random(360))));
    }
    fill(0, 10);
    rect(-20, -20, width+40, height+40);
    popStyle();
    
    if (keyPressed) {
      gameStart = true;
    }
    for (int i = 0; i < 4; i++) {
      if (buttonA[i]) {
      gameStart = true;
      result = false;
      question = false;
      title = false;
      }
    }
    _frameCount = 0;
    
  }
  server.sendImage(g);
}

void mousePressed() {
}

void keyPressed() {
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
  writer.flush(); 
  writer.close();
  exit();
}
void accel1(float _x, float _y, float _z) {
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
    buttonA[0] = true;
  } else {
    buttonA[0] = false;
  }
}
void buttonA2(float _value) {
  if (_value > 0) {
    buttonA[1] = true;
  } else {
    buttonA[1] = false;
  }
}
void buttonA3(float _value) {
  if (_value > 0) {
    buttonA[2] = true;
  } else {
    buttonA[2] = false;
  }
}
void buttonA4(float _value) {
  if (_value > 0) {
    buttonA[3] = true;
  } else {
    buttonA[3] = false;
  }
}
void button11(float _value) {
  if (_value > 0) {
    button1[0] = true;
  }
}
void button21(float _value) {
  if (_value > 0) {
    button1[0] = false;
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
void up1(float _value) {
  if(gameStart) {
    Net n = nets.get(0);
    n.move(n.location.x,n.location.y - 10);
  }
}
void up2(float _value) {
  if(gameStart) {
    Net n = nets.get(1);
    n.move(n.location.x,n.location.y - 10);
  }
}
void up3(float _value) {
  if(gameStart) {
    Net n = nets.get(2);
    n.move(n.location.x,n.location.y - 10);
  }
}
void up4(float _value) {
  if(gameStart) {
    Net n = nets.get(3);
    n.move(n.location.x,n.location.y - 10);
  }
}
void left1(float _value) {
  if(gameStart) {
    Net n = nets.get(0);
    n.move(n.location.x - 10,n.location.y);
  }
}
void left2(float _value) {
  if(gameStart) {
    Net n = nets.get(1);
    n.move(n.location.x - 10,n.location.y);
  }
}
void left3(float _value) {
  if(gameStart) {
    Net n = nets.get(2);
    n.move(n.location.x - 10,n.location.y);
  }
}
void left4(float _value) {
  if(gameStart) {
    Net n = nets.get(3);
    n.move(n.location.x - 10,n.location.y);
  }
}
void right1(float _value) {
  if(gameStart) {
    Net n = nets.get(0);
    n.move(n.location.x + 10,n.location.y);
  }
}
void right2(float _value) {
  if(gameStart) {
    Net n = nets.get(1);
    n.move(n.location.x + 10,n.location.y);
  }
}
void right3(float _value) {
  if(gameStart) {
    Net n = nets.get(2);
    n.move(n.location.x + 10,n.location.y);
  }
}
void right4(float _value) {
  if(gameStart) {
    Net n = nets.get(3);
    n.move(n.location.x + 10,n.location.y);
  }
}
void down1(float _value) {
  if(gameStart) {
    Net n = nets.get(0);
    n.move(n.location.x,n.location.y + 10);
  }
}
void down2(float _value) {
  if(gameStart) {
    Net n = nets.get(1);
    n.move(n.location.x,n.location.y + 10);
  }
}
void down3(float _value) {
  if(gameStart) {
    Net n = nets.get(2);
    n.move(n.location.x,n.location.y + 10);
  }
}
void down4(float _value) {
  if(gameStart) {
    Net n = nets.get(3);
    n.move(n.location.x,n.location.y + 10);
  }
}






