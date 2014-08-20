class Particle
{
  float FRICTION = 0.985;
  float x, y;
  float initX, initY;
  float size;
  int colorH;
  float speed;
  boolean flag = false;
  Particle(float _x, float _y, float _size, float _speed, int _color) {
    x = _x;
    y = _y;
    initX = x;
    initY = y;
    size = _size;
    speed = _speed;
    colorH = _color;
    flag = true;
  }

  void update() {
    if (flag == true) {
      this.draw();
    }
  }

  void move(float tx, float ty) {
    float dist = sqrt((tx-x)*(tx-x)+(ty-y)*(ty-y));
    float direction = atan2(x-tx, ty-y)+HALF_PI;
    x -= speed*dist*cos(direction) / 100;
    y -= speed*dist*sin(direction) / 100;
    speed *= FRICTION;
    if (speed < 1.0) {
      flag = false;
    }
  }
  void pull(float tx, float ty) {
    float dist = sqrt((tx-x)*(tx-x)+(ty-y)*(ty-y));
    float direction = atan2(x-tx, ty-y)+HALF_PI;
    x += speed*dist*cos(direction) / 100;
    y += speed*dist*sin(direction) / 100;
    speed *= FRICTION;
    if (speed < 0.5) {
      flag = false;
    }
  }
  void init() {
    pull(initX, initY);
  }
  void draw() {
    pushStyle();
    colorMode(HSB);
    noFill();
    stroke(colorH, 100, 100, 100*speed/3);
    ellipse(x, y, size, size);
    stroke(colorH, 70, 100, 100*speed/3);
    ellipse(x  + random(-2), y + random(-2), size * 0.8, size *0.8);
    ellipse(x + random(2), y + random(2), size * 0.8, size *0.8);
    popStyle();
  }
  void explode() {
    x = random(width);
    y = random(height);
  }
  boolean is_flag() {
    return flag;
  }
}

