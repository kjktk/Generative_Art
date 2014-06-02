import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import codeanticode.syphon.*; 
import processing.opengl.*; 
import controlP5.*; 
import fullscreen.*; 
import ddf.minim.*; 
import ddf.minim.effects.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class pond extends PApplet {








int numRipples = 1;
int numFlocks = 50;
int numBarriers = 5;
int interval = 0;
String mouseMode = "PLAY";
Boolean debug = false;
int[] pixelBuffer;
PGraphics pg;
PImage img;
Minim minim;
AudioPlayer bgm;
AudioPlayer seAdd;
SyphonServer server;

Flock flock;
public void setup() {
  //base setting
  size(displayWidth,displayHeight,P3D);
  colorMode(HSB,360,100,100);
  background(0);
  frameRate(30);
  smooth();
  //noCursor();

  //minim
  minim = new Minim(this);
  bgm = minim.loadFile("loop.mp3");
  //bgm.play();
  seAdd = minim.loadFile("button01a.mp3");

  //flock
  flock = new Flock();
  for (int i = 0; i < numFlocks; i++) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(random(width),random(height),flockType));
  }

  //syphon
  server = new SyphonServer(this, "Processing Syphon");
}

public void draw() {
  fill(0,50);
  drawGrid();
  rect(-20, -20, width+40, height+40); //fixed
  flock.run();
  server.sendImage(g);
}

public void stop() {
  bgm.close();
  minim.stop();
  super.stop();
}

public void mousePressed() {
  if( mouseMode == "PLAY" ) {
    flock.pull(mouseX,mouseY);
    for(int i = 0;i < numRipples ; i++) {
      flock.addRipple(new Ripple(mouseX,mouseY,random(5,20),PApplet.parseInt(random(180,200))));
    }
    seAdd.play();
    seAdd.rewind();
  }
  else if ( mouseMode == "ADD" ) {
    int flockType = Math.round(random(0,4));
    flock.addBoid(new Boid(mouseX,mouseY,flockType));
    seAdd.play();
    seAdd.rewind();

  }
  else if ( mouseMode == "BARRIER" ) {
    flock.addBarrier(new Barrier(mouseX,mouseY,random(90)));
  }
}

public void keyPressed() {
  switch(key) {
    case 1:
      mouseMode = "PLAY";
      break;
    case 2:
      mouseMode = "ADD";
      break;
    case 3:
      mouseMode = "BARRIER";
      break;
  }
}
public void debugMode() {

}

public void drawGrid() {
  int gridSize = 10;
  stroke(127, 127);
  strokeWeight(1);
  for (int x = 0; x < width; x+=gridSize) {
    line(x, 0, x, height);
  }
  for (int y = 0; y < height; y+=gridSize) {
    line(0, y, width, y);
  }
}


public PImage renderImage() {
  fill(0,50);
  rect(-20, -20, width+40, height+40); //fixed
  flock.run();

  loadPixels();
  arrayCopy(pixels,pixelBuffer);
  for (int i = 0; i < width * height; i++) {
    pixels[i] = 0;
  }
  updatePixels();
  pg.beginDraw();
  pg.smooth();
  pg.loadPixels();
  for (int i = 0; i < width * height; i++) {
    pg.pixels[i] = pixelBuffer[i];
  }
  pg.updatePixels();
  pg.endDraw();
  PImage img = pg.get(0,0,pg.width,pg.height);
  return img;
}
class Barrier {
  PVector location;
  float diameter;
  
  Barrier(float _x, float _y, float _diameter) {
    location = new PVector(_x, _y);
    diameter = _diameter;
  }
  public void run(ArrayList<Barrier> barriers) {
    render();
    push();
  }
  public void render() {
//    noStroke();
//    fill(255,0,255,10);
//    ellipse(location.x,location.y,pushLength,diameter*3);
    fill(0,0,0,100);
    stroke(255,0,255,100);
    ellipse(location.x,location.y,diameter,diameter);
  }
  public void push() {
    
  }
}
class Boid {
  int _count = 0;
  float _scale = 1;
  PImage[] imgs = new PImage[4];
  String[] imgNames = new String[]{
     "carp1","carp","carp4","carp3","carp2"
  };
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed


  Boid(float x, float y, int type) {
    for (int i = 0; i < 4; i++) {
      imgs[i] = loadImage(imgNames[type]+"_"+i+".png");
    }
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    location = new PVector(x, y);
    r = 50;
    maxspeed = 4;
    maxforce = 0.05f;
    _scale = random(0.5f,1.7f);
  }

  public void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  public void pull(ArrayList<Boid> boids,float x,float y) {
    PVector mouse = new PVector(x,y);
    for (Boid n : boids) {
      float d = PVector.dist(location,mouse);
      if (Math.abs(d) < 200) {
          PVector steer = seek(mouse);
          steer.mult(0.3f);
          applyForce(steer);
      }
      if (Math.abs(d) < 100) {
          PVector steer = seek(mouse);
          steer.mult(0.8f);
          applyForce(steer);
      }
    }
  }

 public void push(ArrayList<Boid> boids,ArrayList<Barrier> barriers) {
   PVector sum = new PVector(0, 0);
   for (Boid n : boids) {
     for (Barrier barrier : barriers) {
       float d = PVector.dist(location, barrier.location);
       if (Math.abs(d) < barrier.diameter*3) {
         PVector steer = seek(barrier.location);
         steer.mult(-0.05f);
         applyForce(steer);
       }
       else if (Math.abs(d) < barrier.diameter*2) {
         PVector steer = seek(barrier.location);
         steer.mult(-0.3f);
         applyForce(steer);
       }
       else if (Math.abs(d) < barrier.diameter*1.5f) {
         PVector steer = seek(barrier.location);
         steer.mult(-0.9f);
         applyForce(steer);
       }
       else if (Math.abs(d) < barrier.diameter) {
         PVector steer = seek(barrier.location);
         steer.mult(-3.0f);
         applyForce(steer);
       }
     }
   }
  }

  public void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  public void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5f);
    ali.mult(1.0f);
    coh.mult(1.0f);

    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update location
  public void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  public PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);  // A vector pointing from the location to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  public void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up

    pushMatrix();
    translate(location.x, location.y);
    rotate(theta);
    PImage img = imgs[_count/10 %imgs.length];
    tint(0,0,100,random(150,200));
    image(img,0,0,img.width*_scale,img.height*_scale);
    _count++;
    popMatrix();

  }

  public void borders() {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
  }

  public PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;

    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }

    if (count > 0) {
      steer.div((float)count);
    }

    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  public PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    }
    else {
      return new PVector(0, 0);
    }
  }

  public PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 100;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.location);
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);
    }
    else {
      return new PVector(0, 0);
    }
  }
}

class Flock {
  ArrayList<Boid> boids;
  ArrayList<Barrier> barriers;
  ArrayList<Ripple> ripples;

  Flock() {
    boids = new ArrayList<Boid>();
    ripples = new ArrayList<Ripple>();
    barriers = new ArrayList<Barrier>();
  }

  public void run() {
    for (Boid b : boids) {
      b.run(boids);
      b.push(boids,barriers);
    }
    for (Ripple r : ripples) {
      r.run(ripples);
    }
    for (Barrier b : barriers) {
      b.run(barriers);
    }
  }

  public void addBoid(Boid b) {
    boids.add(b);
  }

  public void addRipple(Ripple r) {
    ripples.add(r);
  }
  public void addBarrier(Barrier b) {
    barriers.add(b);
  }

  public void pull(float x,float y) {
    for (Boid b : boids) {
      b.pull(boids,x,y);
    }
  }
  public void push() {

  }
}

float FRICTION = 0.985f; //\u6ce2\u7d0b\u306e\u6e1b\u8870\u7387

public class Ripple{
  int x, y;     //\u6ce2\u7d0b\u306e\u4e2d\u5fc3\u5ea7\u6a19
  float dia;    //\u6ce2\u7d0b\u306e\u76f4\u5f84
  float speed;
  int colorH;   
  boolean flag = false;
  
  Ripple(int _x,int _y, float _speed, int _colorH){
    x = _x;
    y = _y;
    speed = _speed;
    colorH = _colorH;
    dia = 0.0f;
    flag = true;
  }
  
  public void run(ArrayList<Ripple> ripples) {
    if (flag == true) {
      rippleDraw();
      move();
    }
  }
  
  public void rippleDraw(){
    noFill();
    
    if(speed > 1.0f){
      stroke(colorH, 90, 95, 100*(speed-1)/3);
      strokeWeight(2);
      ellipse(x, y, dia, dia);
    }
    if(speed > 1.5f){
      stroke(colorH, 90, 95, 100*(speed-1.5f)/3);
      strokeWeight(5);
      ellipse(x, y, dia*0.7f, dia*0.7f);
    }
    if(speed > 2.0f){
      stroke(colorH, 90, 95, 100*(speed-2.0f)/3);
      strokeWeight(7);
      ellipse(x, y, dia*0.7f, dia*0.7f);
    }
  }
  
  public void move(){
    dia += speed;      //\u76f4\u5f84\u3092\u901f\u5ea6\u5206\u5927\u304d\u304f
    speed *= FRICTION; //\u901f\u5ea6\u6e1b\u8870
    if(speed < 1.0f){   //\u901f\u5ea6\u304c1.0\u4ee5\u4e0b\u306b\u306a\u3063\u305f\u3089\u63cf\u753b\u3057\u306a\u3044\u8a2d\u5b9a
      flag = false;
    }
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "pond" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
