import fullscreen.*;

Flock flock;
float x,y,r;
boolean click = false;


void setup() {
  //new FullScreen(this).enter();
  noFill();
  stroke(0,128,255);
  size(1280, 720);
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 100; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(width/2,height/2,flockType));
  }
}

void draw() {
  background(0);
  flock.run();
  if (click) {
    r+=10;
    ellipse(x,y,r,r);
  }
  
}

void mousePressed() {
  //int flockType = Math.round(random(0,4));
  //flock.addBoid(new Boid(mouseX,mouseY,flockType));
  flock.pull(mouseX,mouseY);
  x = mouseX;
  y = mouseY;
  r = 0;
  click = true;
}


