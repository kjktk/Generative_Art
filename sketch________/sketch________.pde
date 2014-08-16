PImage img;
int mosaicSize = 3;
color[] _pixels;
void setup() {
  size(640, 480);
  noStroke();
 
  img = loadImage("sakura.png");
  img.loadPixels();
  _pixels= img.pixels;
}
 
void draw() {
  background(0);
  for (color c : _pixels) {
    
  }
}

