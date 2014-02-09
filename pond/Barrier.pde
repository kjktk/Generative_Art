class Barrier {
  PVector location;
  float diameter;
  float pushLength;
  
  Barrier(float _x, float _y, float _diameter) {
    location = new PVector(_x, _y);
    diameter = _diameter;
    pushLength = diameter * 10;
  }
  void run(ArrayList<Barrier> barriers) {
    render();
    push();
  }
  void render() {

    noStroke();
    fill(255,0,255,10);
    ellipse(location.x,location.y,pushLength,pushLength);
    fill(0,0,0,100);
    stroke(255,0,255,100);
    ellipse(location.x,location.y,diameter,diameter);
  }
  void push() {
    
  }
}
