float FRICTION = 0.985;

public class Ripple {
  int x, y;
  float dia;    
  float speed;
  int colorH;   
  public boolean flag = false;
  AudioSnippet mizuSE;
  String[] rippleModes = {
    "rect", "ellipse"
  };
  String rippleMode;

  Ripple(int _x, int _y, float _speed, int _colorH) {
    x = _x;
    y = _y;
    speed = _speed;
    colorH = _colorH + int(random(-50, 50));
    dia = 0.0;
    flag = true;
    mizuSE = minim.loadSnippet("mizu_"+int(random(27))+".mp3");
  }

  void run() {
    this.draw();
    move();
    mizuSE.play();
  }

  void draw() {
    pushStyle();
    colorMode(HSB);
    noFill();
    drawEllipseRipple();
    popStyle();
  }

  void move() {
    dia += speed;      
    speed *= FRICTION;
    if (speed < 1.0) {
      flag = false;
    }
  }
  void drawRectRipple() {
    rectMode(RADIUS);
    if (speed > 1.0) {
      stroke(colorH, 90, 95, 100*(speed-1)/3);
      strokeWeight(2);
      rect(x, y, dia, dia);
    }
    if (speed > 1.5) {
      stroke(colorH, 90, 95, 100*(speed-1.5)/3);
      strokeWeight(3);
      rect(x, y, dia*0.7, dia*0.7);
    }
    if (speed > 2.0) {
      stroke(colorH, 90, 95, 100*(speed-2.0)/3);
      strokeWeight(2);
      rect(x, y, dia*0.7, dia*0.7);
      strokeWeight(3);
      stroke(colorH, 90, 95, 100*(speed-3)/3);
      rect(x + random(-100, 100), y + random(-100, 100), dia *0.3, dia *0.3);
    }
  }
  void drawEllipseRipple() {
    if (speed > 1.0) {
      stroke(colorH, 90, 95, 100*(speed-1)/3);
      strokeWeight(2);
      ellipse(x, y, dia, dia);
    }
    if (speed > 1.5) {
      stroke(colorH, 90, 95, 100*(speed-1.5)/3);
      strokeWeight(3);
      ellipse(x, y, dia*0.7, dia*0.7);
      ellipse(x+random(-5,5), y+random(-5,5), dia*0.7, dia*0.7);
    }
    if (speed > 2.0) {
      stroke(colorH, 90, 95, 100*(speed-2.0)/3);
      strokeWeight(2);
      ellipse(x, y, dia*0.7, dia*0.7);
      strokeWeight(3);
      stroke(colorH, 90, 95, 100*(speed-3)/3);
      ellipse(x + random(-100, 100), y + random(-100, 100), dia *0.3, dia *0.3);
    }
  }
}

