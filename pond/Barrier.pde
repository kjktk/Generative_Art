class Barrier {
  PVector location;
  float r;
  float dia;
  Barrier(float x,float y,float size, int type) {
    location = new PVector(x, y);
    dia = 3*size;
  }
  
}
