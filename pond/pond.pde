import fullscreen.*;

Flock flock;

void setup() {
  //new FullScreen(this).enter();
  
  size(1280, 720);
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 10; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(width/2,height/2,flockType));
  }
}

void draw() {
  background(0);
  flock.run();
}

void mousePressed() {
  //int flockType = Math.round(random(0,4));
  //flock.addBoid(new Boid(mouseX,mouseY,flockType));
  flock.pull(mouseX,mouseY);
}


