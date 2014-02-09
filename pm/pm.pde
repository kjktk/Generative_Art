import processing.opengl.*;

int numRipples = 1;
int numFlocks = 50;
int numBarriers = 5;
int interval = 0;
int mouseMode = 0;
color[] pixelBuffer;
PGraphics pg;
PImage img;

Flock flock;


int   selected = -1;  // 選択されている頂点
int   pos[][] = {{0,0},{400,0},{400,300},{0,300}}; // 頂点座標

void setup() {
  size(displayWidth, displayHeight,P3D);
  colorMode(HSB,360,100,100);
  frameRate(30);
  smooth();
  //noCursor();
  
  pg = createGraphics(width, height);
  pixelBuffer = new color[width * height];
  flock = new Flock();
  for (int i = 0; i < numFlocks; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(random(width),random(height),flockType));
  }
  background(0);
  
}

void draw() {
  background(0);
  img = renderImage();

  // ビデオテクスチャの描画
  beginShape();
    texture(img);  
    vertex(pos[0][0], pos[0][1], 0, 0);
    vertex(pos[1][0], pos[1][1], img.width, 0);
    vertex(pos[2][0], pos[2][1], img.width, img.height);
    vertex(pos[3][0], pos[3][1], 0, img.height);
  endShape(CLOSE);

  // マウスによる頂点操作
  if ( mousePressed && selected >= 0 ) {
    pos[selected][0] = mouseX;
    pos[selected][1] = mouseY;
  }
  else {
    float min_d = 20; // この値が頂点への吸着の度合いを決める
    selected = -1;
    for (int i=0; i<4; i++) {
      float d = dist( mouseX, mouseY, pos[i][0], pos[i][1] );
      if ( d < min_d ) {
        min_d = d;
        selected = i;
      }      
    }
  }
  if ( selected >= 0 ) {
    ellipse( mouseX, mouseY, 20, 20 );
  }
}

void mousePressed() {
  if( mouseMode == 0 ) {
      flock.pull(mouseX,mouseY);
      for(int i = 0;i < numRipples ; i++) {
        flock.addRipple(new Ripple(mouseX,mouseY,random(5,20),int(random(180,200))));
      }
    }
  else if ( mouseMode == 1 ) {
    for (int i = 0; i < numBarriers; i++) {
      flock.addBarrier(new Barrier(mouseX,mouseY,20));
    }
  }
}

void keyPressed() {
  if (key == ENTER) {
    if (mouseMode == 0) {
      mouseMode = 1;
    } else if (mouseMode == 1) {
      mouseMode = 0;
    }
  }
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
