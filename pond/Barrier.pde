class Barrier {
  PVector location;
  float diameter;
  float pushLength;
  
  Barrier(float _x, float _y, float _diameter) {
    location = new PVector(_x, _y);
    diameter = _diameter;
    pushLength = diameter * 2;
  }
  void render() {
    noFill();
    stroke(255,0,255,63);
    ellipse(location.x,location.y,diameter,diameter);
    fill(255,0,255,10);
    ellipse(location.x,location.y,pushLength,pushLength);
  }
  void push() {
    
  }
}
