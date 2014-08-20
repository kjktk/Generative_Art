class Carp extends Boid {
  int _count = 0;
  float _scale = 1;
  PImage[] imgs = new PImage[4];
  String[] imgNames = new String[] {
    "carp1", "carp", "carp4", "carp3", "carp2"
  };
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  int MAX_PARTICLE = 15;
  ArrayList <Particle> particles = new ArrayList<Particle>();

  Carp(float _x, float _y, int type) {
    super(_x, _y, type);
  }
}

