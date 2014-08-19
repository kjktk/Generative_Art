class Barrier {
  PVector location;
  float diameter;
  boolean is_sound;
  boolean is_push;
  
  Barrier(float _x, float _y, float _diameter) {
    location = new PVector(_x, _y);
    diameter = _diameter;
    is_sound = false;
    is_push = false;
  }
  void run(ArrayList<Barrier> barriers) {
    render();
  }
  void render() {
    pushStyle();
    if (is_sound) {
      strokeWeight(3);
      fill(random(360),50,100,100);
      rect(location.x,location.y,diameter*2,diameter*2);
      is_push =true;
      is_sound = false;
    } else {
      strokeWeight(1);
      fill(random(360),100,100,100);
      stroke(255,0,255,100);
      rect(location.x,location.y,diameter,diameter);
    }
    popStyle();
  }
  void sound() {
    is_sound = true;
  }
  void move(float _x, float _y) {
    
  }
}
