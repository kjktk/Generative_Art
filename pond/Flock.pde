class Flock {
  public ArrayList<Boid> boids;
  public ArrayList<Barrier> barriers;


  Flock() {
    boids = new ArrayList<Boid>();
    barriers = new ArrayList<Barrier>();
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);
      b.push(boids, barriers);
    }
    for (Barrier b : barriers) {
      b.run();
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }
  void removeBoid(Boid b) {
    boids.remove(b);
  }
  void addBarrier(Barrier b) {
    barriers.add(b);
  }
  void pull(float x, float y) {
    for (Boid b : boids) {
      b.pull(boids, x, y);
    }
  }
}

