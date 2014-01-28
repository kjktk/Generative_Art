/**
 * Flocking 
 * by Daniel Shiffman.  
 * 
 * An implementation of Craig Reynold's Boids program to simulate
 * the flocking behavior of birds. Each boid steers itself based on 
 * rules of avoidance, alignment, and coherence.
 * 
 * Click the mouse to add a new boid.
 */
import fullscreen.*;

Flock flock;

void setup() {
  new FullScreen(this).enter();
  
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

// Add a new boid into the System
void mousePressed() {
  int flockType = Math.round(random(0,4));
  flock.addBoid(new Boid(mouseX,mouseY,flockType));
}
