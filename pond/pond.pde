import java.awt.Point;

int numRipples = 1;
int numFlocks = 50;
int numBarriers = 5;
int mode = 0;
color[] pixelBuffer;
PGraphics pg;
PImage img;

Render render;
Surface[] surfaces;
Flock flock;

int selectedSurfaceIndex;
Point selectedVertex;

boolean adjustMode;

void setup() {
  size(displayWidth, displayHeight,P3D);
  colorMode(HSB,360,100,100);
  frameRate(30);
  smooth();
  //noCursor();
  
  surfaces = new Surface[3];
  for (int i = 0; i < surfaces.length; i++) {
    surfaces[i] = new Surface((width*i)/(surfaces.length+1), (height*i)/(surfaces.length+1),
                              width/(surfaces.length+1), height/(surfaces.length+1));
  }
  
  selectedSurfaceIndex = 0;

  background(0);
}

void draw() {
//  
//  if (mousePressed) {
//    if( mode == 0 ) {
//      flock.pull(mouseX,mouseY);
//      for(int i = 0;i < numRipples ; i++) {
//        flock.addRipple(new Ripple(mouseX,mouseY,random(3,25),int(random(165,200))));
//      }
//    }
//  }
  pg  = render.draw(pg);
  img = pg.get(0,0,pg.width,pg.height);
  
  surfaces[0].draw(img);
  surfaces[1].draw(img);
  surfaces[2].draw(img);
  
  if (adjustMode) adjustMode();
}

void mousePressed() {
  
  if ( mode == 1 ) {
    if (!adjustMode) return;
    double minDist = Double.MAX_VALUE;
    Surface surface = surfaces[selectedSurfaceIndex];
    for (Point p : surface.getVertices()) {
    double d = p.distance(new Point(mouseX, mouseY));
    if (d < minDist) {
      minDist = d;
      selectedVertex = p;
      }
    }
    for (int i = 0; i < numBarriers; i++) {
      flock.addBarrier(new Barrier(mouseX,mouseY,20));
    }
  }
}

void mouseDragged() { if (adjustMode) selectedVertex.setLocation(mouseX, mouseY); }
void mouseReleased() { if (adjustMode) selectedVertex = null; }


void keyPressed() {
  if (key == ENTER) {
    if (mode == 0) {
      mode = 1;
    } else if (mode == 1) {
      mode = 0;
    }
  }
  if (key == 'a') {
    adjustMode = !adjustMode;
  }

  if (key == 'n') {
    selectedSurfaceIndex = (selectedSurfaceIndex+1) % surfaces.length;
  } else if (key == 'p') {
    selectedSurfaceIndex = (surfaces.length + selectedSurfaceIndex-1) % surfaces.length;
  }
}

void adjustMode() {
  for (Surface surface : surfaces) {
    ellipseMode(CENTER);

    stroke(255, 255, 255);
    if (surface == surfaces[selectedSurfaceIndex]) {
      stroke(255, 255, 0);
      strokeWeight(3);
    } else {
      stroke(255);
      strokeWeight(1);
    }
    noFill();    
    beginShape();
    Point[] vertices = surface.getVertices();
    for (Point v : vertices) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
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

