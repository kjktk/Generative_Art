import fullscreen.*;

Flock flock;

void setup() {
  new FullScreen(this).enter();
  size(1280, 720);
  colorMode(HSB,360,100, 100);
  noFill();
  strokeWeight(6);
  smooth();
  
  flock = new Flock();
  
  // Add an initial set of boids into the system
  for (int i = 0; i < 50; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(random(width),random(height),flockType));
  }
}

void draw() {
  float max_size = width * height;
  background(0);
  flock.run();
  if (click) {
    for (int i = 0; i < c; i++){
      r[i]+=10;
      stroke(x[i] * y[i] /max_size * 360,40,90); 
      ellipse(x[i],y[i],r[i],r[i]);
    }
  }
  
}

void mousePressed() {
  flock.pull(mouseX,mouseY);
}


