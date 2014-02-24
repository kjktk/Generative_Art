class Flock {
  ArrayList<Boid> boids;
  ArrayList<Barrier> barriers;
  ArrayList<Ripple> ripples;
  
  Flock() {
    boids = new ArrayList<Boid>();
    ripples = new ArrayList<Ripple>();
    barriers = new ArrayList<Barrier>();
  }

  void run(PGraphics render) {
    for (Boid b : boids) {
      b.run(boids,render);
      b.push(boids,barriers);
    }
    for (Ripple r : ripples) {
      r.run(ripples,render);
    }
    for (Barrier b : barriers) {
      b.run(barriers);
    }
  }
  void bMask(PGraphics mask) {
    for (Barrier b : barriers) {
      b.render(barriers,mask);
    }
  }
  void addBoid(Boid b) {
    boids.add(b);
  }
  void addRipple(Ripple r) {
    ripples.add(r);
  }
  void addBarrier(Barrier b) {
    barriers.add(b);
  }
  void deleteBarrier(float x,float y) {
    for (Barrier b : barriers) {
      if ( b.delete(barriers,x,y) == true) {
        barriers.remove(b);
      }
    }
  }
  void pull(float x,float y) {
    for (Boid b : boids) {
      b.pull(boids,x,y); 
    }
  }
}

