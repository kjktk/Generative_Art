int _num = 700;
void setup() {
  size(600,600);
  background(255);
  smooth();
  noFill();
  strokeWeight(random(3));
  drawSun();
}

void drawSun() {
  float x, y, radius;
  for(int i = 0; i<_num; i++) {
    stroke(247,194,66);
    x = random(250,350);
    y = random(250,350);
    radius = random(100,400);
    ellipse(x,y, radius,radius);
  }
  for(int i = 0; i<_num; i++) {
    stroke(240,94,28);
    x = random(270,330);
    y = random(270,330);
    radius = random(100,200);
    ellipse(x,y, radius,radius);
  }
  for(int i = 0; i<50; i++) {
    stroke(255,0,66);
    x = width/2;
    y = height/2;
    radius = i;
    ellipse(x,y, radius,radius);
  }
}
