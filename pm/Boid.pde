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

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    location = new PVector(x, y);
    r = 50;
    maxspeed = 4;
    maxforce = 0.05;
    _scale = random(0.5,1.7);
  }
  
  void run(ArrayList<Boid> boids,PGraphics render) {
    flock(boids);
    update();
    borders();
    render(render);
  }
  
  void pull(ArrayList<Boid> boids,float x,float y) {
    PVector mouse = new PVector(x,y);
    for (Boid n : boids) {
      float d = PVector.dist(location,mouse);
      if (Math.abs(d) < 200) { 
          PVector steer = seek(mouse);
          steer.mult(0.3);
          applyForce(steer);
      }
      if (Math.abs(d) < 100) { 
          PVector steer = seek(mouse);
          steer.mult(0.8);
          applyForce(steer);
      }
    }
  }
  
 void push(ArrayList<Boid> boids,ArrayList<Barrier> barriers) {
   PVector sum = new PVector(0, 0);
   for (Boid n : boids) {
     for (Barrier barrier : barriers) {
       float d = PVector.dist(location, barrier.location);
       if (Math.abs(d) < barrier.diameter*3) {
         PVector steer = seek(barrier.location);
         steer.mult(-0.05);
         applyForce(steer);
       }
       else if (Math.abs(d) < barrier.diameter*2) {
         PVector steer = seek(barrier.location);
         steer.mult(-0.3);
         applyForce(steer);
       }
       else if (Math.abs(d) < barrier.diameter*1.5) {
         PVector steer = seek(barrier.location);
         steer.mult(-0.9);
         applyForce(steer);
       }
       else if (Math.abs(d) < barrier.diameter) {
         PVector steer = seek(barrier.location);
         steer.mult(-3.0);
         applyForce(steer);
       }
     }
   }
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids); 
    PVector ali = align(boids);      
    PVector coh = cohesion(boids);   
    
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  void update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    location.add(velocity);
    acceleration.mult(0);
  }


  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render(PGraphics render) {
    float theta = velocity.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
   
    render.pushMatrix();
    render.translate(location.x, location.y);
    render.rotate(theta);
    PImage img = imgs[_count/10 %imgs.length];
    render.tint(0,0,random(90,100));
    render.image(img,0,0,img.width*_scale,img.height*_scale);
    _count++;
    render.popMatrix(); 
  }

  void borders() {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
  }
  
  PVector separate (ArrayList<Boid> boids) {
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

  PVector align (ArrayList<Boid> boids) {
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

  PVector cohesion (ArrayList<Boid> boids) {
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

