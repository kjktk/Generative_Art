class Barrier {
  PVector location;
  float diameter;
  boolean is_push;

  Barrier(float _x, float _y, float _diameter) {
    location = new PVector(_x, _y);
    diameter = _diameter;
    is_push = false;
  }
  void run() {
    render();
  }
  void render() {
    pushStyle();
    rectMode(RADIUS);
      strokeWeight(random(3));
      stroke(random(360), 100, 100, 50);
      noFill();
      rect(location.x, location.y, diameter*2, diameter*2);
      strokeWeight(1);
      noFill();
      stroke(random(360), 100, 100, 100);
      rect(location.x, location.y, diameter, diameter);
    popStyle();
  }
  void push(float _x, float _y) {
    is_push =true;
  }
}

