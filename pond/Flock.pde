class Flock {
  ArrayList<Boid> boids;
  ArrayList<Barrier> barriers;
  ArrayList<Ripple> ripples;

  Flock() {
    boids = new ArrayList<Boid>();
    ripples = new ArrayList<Ripple>();
    barriers = new ArrayList<Barrier>();
  }

  void run() {
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

  void addBoid(Boid b) {
    boids.add(b);
  }

  void addRipple(Ripple r) {
    ripples.add(r);
  }
  void addBarrier(Barrier b) {
    barriers.add(b);
  }

  void pull(float x,float y) {
    for (Boid b : boids) {
      b.pull(boids,x,y);
    }
  }
  void push() {

  }
}

