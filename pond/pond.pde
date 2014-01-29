import fullscreen.*;

Flock flock;

boolean click = false;
float[] x = new float[10];
float[] y = new float[10];
float[] r = new float[10];
int c;

void setup() {
  //new FullScreen(this).enter();
  noFill();
  stroke(0,128,255);
  size(1280, 720);
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 50; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(random(width),random(height),flockType));
  }
}

void draw() {
  background(0);
  flock.run();
  if (click) {
    for (int i = 0; i < c; i++){
      r[i]+=10;
      ellipse(x[i],y[i],r[i],r[i]);
    }
  }
  
}

void mousePressed() {
  //int flockType = Math.round(random(0,4));
  //flock.addBoid(new Boid(mouseX,mouseY,flockType));
  flock.pull(mouseX,mouseY);
  if(c < 10){
    x[c] = mouseX;
    y[c] = mouseY;
    r[c] = 0;
    c++;
    click = true;
  }
  else
    c = 0;
}


