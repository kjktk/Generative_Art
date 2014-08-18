PImage img;
ArrayList <PixelArt> wagara;
void setup() {
  size(640, 480);
  colorMode(HSB,360,100,100);
  noStroke();
 
  wagara = new ArrayList<PixelArt>();
  for (int i = 0; i < 1; i++) {
    img = loadImage("sakura.png");
    wagara.add(new PixelArt(random(width),random(height),img));
  }
}
 
void draw() {
  background(0);
  for (PixelArt w : wagara) {
    w.update();
  }
}

