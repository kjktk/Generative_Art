int RIPPLES = 30;
int FLOCKS = 100;
int interval = 0;
int mouseMode = 0;
PGraphics pg;
PGraphics mask;
PFont font;
final int ELLIPSE_SIZE = 30;


Ripple[] ripples = new Ripple[RIPPLES];
Flock flock;

void setup() {
  size(displayWidth, displayHeight,P2D);
  
  frameRate(60);
  smooth();
  //noCursor();
  
  flock = new Flock();
  
  for (int i = 0; i < FLOCKS; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(random(width),random(height),flockType));
  }
  
  for(int i = 0;i < ripples.length ; i++) {
    ripples[i] = new Ripple();
  }
  
  pg = createGraphics(width, height,P2D);
  
  mask = createGraphics(width, height, P2D);
  

  

 

}

void draw() {
  background(0);
  mask.beginDraw();
    mask.smooth();
    mask.background(0);
    mask.noStroke();
    for (int w = mask.width; w > 0; w -= 10) {
      mask.fill(255 - w * 255 / mask.width);
      mask.ellipse(mask.width / 2, mask.height / 2, w, w);
    }
  mask.endDraw();
  
  pg.beginDraw();
    pg.smooth();
    pg.background(0,150,255);
    flock.run();
    for (int i = 0; i < ripples.length; i++) {
    if ( ripples[i].getFlag()) {
      ripples[i].move();
      ripples[i].rippleDraw();
    }
  }
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
    colorMode(HSB,360,100,100);
    ripples[0].init(mouseX,mouseY,random(5,20),int(random(180,220)));
  } else if ( mouseMode == 1) {
    
  }
}

