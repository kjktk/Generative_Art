class Barrier {
  PVector location;
  float diameter;
  
  Barrier(float _x, float _y, float _diameter) {
    location = new PVector(_x, _y);
    diameter = _diameter;
  }
  void run(ArrayList<Barrier> barriers) {
  }
  void render(ArrayList<Barrier> barriers,PGraphics mask) {
    noStroke();
    mask.fill(0);
    mask.ellipse(location.x,location.y,diameter,diameter);

  }
}
