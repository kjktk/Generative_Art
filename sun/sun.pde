import processing.opengl.*;
int i;
void setup() {
  size(500, 300, OPENGL);
  frameRate(30);
  sphereDetail(1);
}
void draw() {
  
  translate(width/2,height/2,0);
  sphereDetail(i);
  sphere(100);
  if( i > 50) {
    i = 0;
  }
  i++;
}
