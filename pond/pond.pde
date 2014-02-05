int RIPPLES = 30;
int FLOCKS = 100;
int interval = 0;
int mouseMode = 0;

Ripple[] ripples = new Ripple[RIPPLES];
Flock flock;

void setup() {
  size(displayWidth, displayHeight);
  colorMode(HSB,360,100,100);
  frameRate(30);
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

}

void draw() {
  background(0);
  flock.run();
  for (int i = 0; i < ripples.length; i++) {
    if ( ripples[i].getFlag()) {
      ripples[i].move();
      ripples[i].rippleDraw();
    }
  }
}

void mousePressed() {
  if( mouseMode == 0 ) {
    flock.pull(mouseX,mouseY);
    for(int i = ripples.length - 1; i > 0; i--) {
      ripples[i] = new Ripple(ripples[i - 1]);
    }
    ripples[0].init(mouseX,mouseY,random(5,20),int(random(180,220)));
  } else if ( mouseMode == 1) {
    
  }
}


