int numRipples = 1;
int numFlocks = 50;
int numBarriers = 5;
int interval = 0;
int mouseMode = 0;

Flock flock;


void setup() {
  size(displayWidth, displayHeight);
  colorMode(HSB,360,100,100);
  frameRate(60);
  smooth();
  //noCursor();
  
  flock = new Flock();
  
  for (int i = 0; i < numFlocks; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(random(width),random(height),flockType));
  }
  

  background(0);
}

void draw() {
  fill(0,50);
  rect(-20, -20, width+40, height+40);
  flock.run();
//  for (int i = 0; i < ripples.length; i++) {
//    if ( ripples[i].getFlag()) {
//      ripples[i].move();
//      ripples[i].rippleDraw();
//    }
//  }
  
}

void mousePressed() {
  if( mouseMode == 0 ) {
    flock.pull(mouseX,mouseY);
    for(int i = 0;i < numRipples ; i++) {
      flock.addRipple(new Ripple(mouseX,mouseY,random(5,20),int(random(180,200))));
    }
  }
  else if ( mouseMode == 1 ) {
    
    for (int i = 0; i < numBarriers; i++) {
      flock.addBarrier(new Barrier(mouseX,mouseY,20));
    }
  }
}

void keyPressed() {
  if (key == ENTER) {
    if (mouseMode == 0) {
      mouseMode = 1;
    } else if (mouseMode == 1) {
      mouseMode = 0;
    }
  }
}
