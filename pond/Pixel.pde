class Pixel
{
  float FRICTION = 0.985;
  float x, y;
  float initX, initY;
  float size;
  color colorH;
  float speed;
  boolean flag = false;
  Pixel(float _x, float _y, float _size, float _speed, color _color) {
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
    this.draw();
  }
  void move(float tx, float ty) {
    float dist = sqrt((tx-x)*(tx-x)+(ty-y)*(ty-y));
    float direction = atan2(x-tx, ty-y)+HALF_PI;
    x += speed*dist*cos(direction) / 100;
    y += speed*dist*sin(direction) / 100;
    speed *= FRICTION;
    if (speed < 1.0) {
      flag = false;
    }
  }
  void init() {
    move(initX, initY);
  }
  void draw() {
    pushStyle();
    translate(x, y);
    colorMode(HSB);
    noStroke();
    fill(colorH);
    ellipse(x, y, size, size);
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

