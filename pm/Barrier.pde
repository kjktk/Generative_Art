class Barrier {
  PVector location;
  float diameter;
  
  Barrier(float _x, float _y, float _diameter) {
    location = new PVector(_x, _y);
    diameter = _diameter;
  }
  void run(ArrayList<Barrier> barriers,PGraphics render) {
    render(render);
  }
  void render(PGraphics render) {
//    noStroke();
//    fill(255,0,255,10);
//    ellipse(location.x,location.y,pushLength,diameter*3);
    render.fill(0,0,0,100);
    render.stroke(255,0,255,100);
    render.ellipse(location.x,location.y,diameter,diameter);
  }
}
