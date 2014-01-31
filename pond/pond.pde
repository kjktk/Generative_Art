int RIPPLES = 30;
int FLOCKS = 100;
int interval = 0;
boolean mouseFlag = true;

Ripple[] ripples = new Ripple[RIPPLES];
Flock flock;

void setup() {
  size(displayWidth, displayHeight);
  colorMode(HSB,360,100,100);
  frameRate(30);
  smooth();
  
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
  if (interval > 30) {
    mouseFlag = true;
    interval = 0;
  }
  interval += 1;
}

void mousePressed() {
  if( mouseFlag == true ) {
    flock.pull(mouseX,mouseY);
    mouseFlag = false;
  }
  for(int i = ripples.length - 1; i > 0; i--) {
    ripples[i] = new Ripple(ripples[i - 1]);
  }
  ripples[0].init(mouseX,mouseY,random(5,15),int(random(180,220)));
  
}


