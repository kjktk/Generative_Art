int numRipples = 1;
int numFlocks = 50;
int numBarriers = 5;
int interval = 0;
int mouseMode = 0;
color[] pixelBuffer;
PGraphics pg;
PImage img;

Surface[] surfaces;
Render render;


void setup() {
  size(displayWidth, displayHeight,P3D);
  colorMode(HSB,360,100,100);
  frameRate(30);
  smooth();
  //noCursor();
  render = new Render();
  
  surfaces = new Surface[3];
  for (int i = 0; i < surfaces.length; i++) {
    surfaces[i] = new Surface((width*i)/(surfaces.length+1), (height*i)/(surfaces.length+1),
                              width/(surfaces.length+1), height/(surfaces.length+1));
  }
  
  background(0);
  
}

void draw() {
  background(0);
  img = render.renderImage();
  surfaces[0].draw(img);
  surfaces[1].draw(img);
  surfaces[2].draw(img);
}

void mousePressed() {
//  if( mouseMode == 0 ) {
//    flock.pull(mouseX,mouseY);
//    for(int i = 0;i < numRipples ; i++) {
//      flock.addRipple(new Ripple(mouseX,mouseY,random(5,20),int(random(180,200))));
//    }
//  }
//  else if ( mouseMode == 1 ) {
//    
//    for (int i = 0; i < numBarriers; i++) {
//      flock.addBarrier(new Barrier(mouseX,mouseY,20));
//    }
//  }
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

