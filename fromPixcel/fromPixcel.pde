PImage img;
int mosaicSize = 3;
color[] _pixels;
ArrayList<Particle> p;
void setup() {
  size(640, 480);
  noStroke();
 
  img = loadImage("sakura.png");
  img.loadPixels();
  p = new ArrayList<Particle>();
  for(int j = 0; j< img.height; j+=mosaicSize) {
    for(int i = 0; i < img.width; i+=mosaicSize) {
      p.add(new Particle(i,j,5,5,img.pixels[j*img.width + i])); 
    }
  }
}
 
void draw() {
  background(0);
  for(int i = 0; i < p.size(); i++) {
    Particle dot = p.get(i);
    dot.update();
    dot.move(random(width),random(height));
  }
  

}

