class Emitter {
  int MAX_PARTICLE = 1;
  ArrayList <Particle> particles;
  PVector location;
  PVector velocity;
  PVector acceleration;
  
  Emitter (float _x,float _y) {
    location = new PVector(_x, _y);
    acceleration = new PVector(0, 0);
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    
    //Particle
    particles = new ArrayList <Particle>();
  }
  void update() {
    for (int i = 0; i < MAX_PARTICLE; i++) {
      particles.add(new Particle(location.x,location.y,random(30),random(5),(int)random(360)));
    }
    
    for(int i = 0; i < particles.size(); i++) {
      Particle p = particles.get(i);
      if(p.is_flag()){
        p.update();
        p.move(random(location.x - 10,location.x + 10),random(location.y-10,location.y+10));
      } else {
        particles.remove(i);
      }
    }
  }
  void move(float _x,float _y) {
    location.x = _x;
    location.y = _y;
  }
}
