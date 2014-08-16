class Particle
{
  float FRICTION = 0.985;
  float x,y;
  float size;
  color colorH;
  float speed;
  boolean flag = false;
  Particle(float _x,float _y,float _size,float _speed){
    x = _x;
    y = _y;
    size = _size;
    speed = _speed;
    colorH = color(random(300),100*speed/3,100*speed/3);
    flag = true;
  }
   
  void update(){
    if (flag == true) {
      this.draw();
    }
  }
 
  void move(float tx,float ty){
    float dist = sqrt((tx-x)*(tx-x)+(ty-y)*(ty-y));
    float direction = atan2(x-tx,ty-y)+HALF_PI;
    x -= speed*dist*cos(direction) / 100;
    y -= speed*dist*sin(direction) / 100;
    speed *= FRICTION;
    if(speed < 1.0){
      flag = false;
    }
  }
  void draw(){
    pushStyle();
    colorMode(HSB);
    noStroke();
    fill(colorH);
    ellipse(x,y, size, size);
    popStyle();
  }
  void explode() {
    x = random(100) - 50;
    y = random(100) - 50;
  }
  boolean is_flag() {
    return flag;
  }
}
