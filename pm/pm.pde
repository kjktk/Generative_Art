import processing.opengl.*;
import controlP5.*;
import fullscreen.*;
import mappingtools.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

int numRipples = 1;
int numFlocks = 50;
int numBarriers = 5;

String mode = "PLAY";
Boolean debug = false;
Boolean maskFlag = false;
Boolean gridFlag = false;

color[] pixelBuffer;
PGraphics pg;
PGraphics mask;
PGraphics bMask;
PImage img;

int ys = 25;
int yi = 15;

BezierWarp    bw;
QuadWarp      qw;
Flock         flock;
Minim         minim;
AudioPlayer   player;
AudioMetaData meta;
FFT           fft;

void setup() {
  //new FullScreen(this).enter();
  size(1280,720,OPENGL);
  frameRate(30);
  smooth();
  
  pg = createGraphics(width,height,OPENGL);
  mask = createGraphics(width,height,OPENGL);
  bMask = createGraphics(width,height,OPENGL);
  
  bw = new BezierWarp(this, 10);
  qw = new QuadWarp(this, 10);
  
  flock = new Flock();
  
  minim = new Minim(this);
  player = minim.loadFile("Go Cart - Loop Mix.mp3",1024);
  meta = player.getMetaData();
  
  
  for (int i = 0; i < numFlocks; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(random(width),random(height),flockType));
  }
  
  pg.beginDraw();
  pg.colorMode(HSB,360,100,100);
  pg.endDraw();
  
  bMask.beginDraw();
  bMask.smooth();
  bMask.background(255);
  bMask.endDraw();
  
  mask.beginDraw();
  mask.smooth();
  mask.background(0);
  mask.noStroke();
  for (int w = mask.width; w > 0; w -= 10) {
    mask.fill(255 - w * 255 / mask.width);
    mask.ellipse(mask.width / 2, mask.height / 2, w, w);
  }
  mask.endDraw();
  
  player.loop(); 
  fft = new FFT( player.bufferSize(), player.sampleRate() );
  
  textFont(createFont("Serif", 12));
}

void draw() {
  background(0);
  
  bMask.beginDraw();
  bMask.smooth();
  flock.bMask(bMask);
  bMask.endDraw();
  
  pg.beginDraw();
  pg.smooth();
  pg.fill(0,50);
  pg.rect(-20, -20, width+40, height+40); //fixed
  drawFFT();
  flock.run(pg);
  pg.endDraw();
  
  pg.mask(bMask);
  
  if ( maskFlag == true ) {
    pg.mask(mask);
  }
  if (gridFlag == true) {
    drawGrid();
  }
  if ( debug == true ) {
    drawMeta();
    image(pg,0,0);
  } else {
    //qw.render(img);
  }
}

void mousePressed() {
  if( mode == "PLAY" ) {
    cursor();
    flock.pull(mouseX,mouseY);
    for(int i = 0;i < Math.round(random(1,4)) ; i++) {
      flock.addRipple(new Ripple(mouseX*random(0.9,1.1),mouseY*random(0.9,1.1),random(5,20),int(random(180,200))));  
     }
  }
  else if ( mode == "ADD" ) {
    cursor();
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(mouseX,mouseY,flockType));
  }
  else if ( mode == "BARRIER" ) {
    cursor();
    flock.addBarrier(new Barrier(mouseX,mouseY,70));
  }
}

void stop() {
  player.close();
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
    if (maskFlag == false) {
      maskFlag = true;
    } else {
      maskFlag = false;
    }
      
  } 
  if (key == '7') {
      save("projection.jpg");
  }
  if (key == '8') {
    if (gridFlag == true) {
      gridFlag = false;
    } else {
      gridFlag = true;
    }
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

void drawGrid1() {
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

void drawGrid() {
  int gridSize = 10;
  noStroke();
  for (int x = 0; x < width; x+=gridSize) {
    for (int y = 0; y < height; y+=gridSize) {
      fill(random(255));
      rect(x,y, x+gridSize, y+gridSize);
    }
  }
}

void drawFFT() {
  pg.stroke(255);
  fft.forward( player.mix );
  for(int i = 0; i < fft.specSize(); i++)
  {
    pg.line( i, height, i, height - fft.getBand(i)*8 );
  }
}

void drawMeta() {
  int y = ys;
  text("File Name: " + meta.fileName(), 5, y);
  text("Length (in milliseconds): " + meta.length(), 5, y+=yi);
  text("Title: " + meta.title(), 5, y+=yi);
  text("Author: " + meta.author(), 5, y+=yi); 
  text("Album: " + meta.album(), 5, y+=yi);
  text("Date: " + meta.date(), 5, y+=yi);
  text("Comment: " + meta.comment(), 5, y+=yi);
  text("Track: " + meta.track(), 5, y+=yi);
  text("Genre: " + meta.genre(), 5, y+=yi);
  text("Copyright: " + meta.copyright(), 5, y+=yi);
  text("Disc: " + meta.disc(), 5, y+=yi);
  text("Composer: " + meta.composer(), 5, y+=yi);
  text("Orchestra: " + meta.orchestra(), 5, y+=yi);
  text("Publisher: " + meta.publisher(), 5, y+=yi);
  text("Encoded: " + meta.encoded(), 5, y+=yi);
}
