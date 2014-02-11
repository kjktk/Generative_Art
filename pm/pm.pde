import processing.opengl.*;
import controlP5.*;
import fullscreen.*;
import mappingtools.*;
import ddf.minim.*;

int numRipples = 1;
int numFlocks = 50;
int numBarriers = 5;

String mode = "PLAY";
Boolean debug = false;

color[] pixelBuffer;
PGraphics pg;
PGraphics mask;
PImage img;

BezierWarp bw;
Flock flock;
Minim minim;
AudioPlayer player; 

void setup() {
  //new FullScreen(this).enter();
  size(1280,720,OPENGL);
  frameRate(30);
  smooth();
  
  //noCursor();
  
  pg = createGraphics(width,height,OPENGL);
  mask = createGraphics(width,height,OPENGL);
  
  bw = new BezierWarp(this, 10);
  flock = new Flock();
  minim = new Minim(this);
  player = minim.loadFile("Go Cart - Loop Mix.mp3");
  player.play(); 
  for (int i = 0; i < numFlocks; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(random(width),random(height),flockType));
  }
  
  pg.beginDraw();
  pg.colorMode(HSB,360,100,100);
  pg.background(0);
  pg.endDraw();
  
  mask.beginDraw();
  mask.smooth();
  mask.background(0);
  mask.noStroke();
  for (int w = mask.width; w > 0; w -= 10) {
    mask.fill(255 - w * 255 / mask.width);
    mask.ellipse(mask.width / 2, mask.height / 2, w, w);
  }
  mask.endDraw();

}

void draw() {
  background(0);
  
  
  
  pg.beginDraw();
  pg.smooth();
  pg.fill(0,50);
  pg.rect(-20, -20, width+40, height+40); //fixed
  flock.run(pg);
  pg.endDraw();
  
  pg.mask(mask);
  
  if ( mode == "PLAY" || mode == "AJUST") {
    bw.render(pg);
  } else {
    image(pg,0,0);
  }
}

void mousePressed() {
  if( mode == "PLAY" ) {
    flock.pull(mouseX,mouseY);
    for(int i = 0;i < numRipples ; i++) {
      flock.addRipple(new Ripple(mouseX,mouseY,random(5,20),int(random(180,200))));
    }
  }
  else if ( mode == "ADD" ) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(mouseX,mouseY,flockType));
  }
  else if ( mode == "BARRIER" ) {
    flock.addBarrier(new Barrier(mouseX,mouseY,70));
  }
}

void stop() {
    player.close();  //サウンドデータを終了
  minim.stop();
  super.stop();
}

void keyPressed() {
  if (key == '1') {
      mode = "PLAY";
  } else if (key == '2') {
      mode = "ADD";
  } else if (key == '3') {
      mode = "BARRIER";
  } else if (key == '4') {
      mode = "LOTUS";
  } else if (key == '5') {
      mode = "AJUST";
  } else if (key == '6') {
      mode = "MASK";
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
