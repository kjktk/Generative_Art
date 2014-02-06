int RIPPLES = 30;
int FLOCKS = 100;
int interval = 0;
int mouseMode = 0;
color[] pixelBuffer;
PGraphics pg;
PGraphics mask;

Ripple[] ripples = new Ripple[RIPPLES];
Flock flock;


void setup() {
  size(displayWidth, displayHeight,P2D);
  colorMode(HSB,360,100,100);
  frameRate(60);
  smooth();
  //noCursor();
  pixelBuffer = new color[width * height];
  
  pg = createGraphics(width, height, P2D);
  mask = createGraphics(width,height, P2D);
  
  flock = new Flock();
  
  for (int i = 0; i < FLOCKS; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(random(width),random(height),flockType));
  }
  
  for(int i = 0;i < ripples.length ; i++) {
    ripples[i] = new Ripple();
  }

}

void draw() {
  background(200,100,100);
  flock.run();
  for (int i = 0; i < ripples.length; i++) {
    if ( ripples[i].getFlag()) {
      ripples[i].move();
      ripples[i].rippleDraw();
    }
  }
  loadPixels();
  arrayCopy(pixels,pixelBuffer);
  for (int i = 0; i < width * height; i++) {
    pixels[i] = 0;
  }
  updatePixels();
  
  mask.beginDraw();
    mask.background(0);
    mask.noStroke();
    for (int w = mask.height+10; w > 0; w -= 1) {
      mask.fill(255 - w * 255 / mask.height+10);
      mask.ellipse(mask.width / 2, mask.height / 2, w, w);
    }
  mask.endDraw();
  
  pg.beginDraw();
    pg.smooth();
    pg.loadPixels();
    for (int i = 0; i < width * height; i++) {
        pg.pixels[i] = pixelBuffer[i];
    }
    pg.updatePixels();
  pg.endDraw();
  
  pg.mask(mask);
  image(pg, 0, 0);
}

void mousePressed() {
  if( mouseMode == 0 ) {
    flock.pull(mouseX,mouseY);
    for(int i = ripples.length - 1; i > 0; i--) {
      ripples[i] = new Ripple(ripples[i - 1]);
    }
    ripples[0].init(mouseX,mouseY,random(5,20),int(random(180,200)));
  } else if ( mouseMode == 1) {
    
  }
}

