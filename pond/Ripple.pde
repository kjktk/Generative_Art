float FRICTION = 0.985;

public class Ripple{
  int x, y;
  float dia;    
  float speed;
  int colorH;   
  boolean flag = false;
  
  Ripple(int _x,int _y, float _speed, int _colorH){
    x = _x;
    y = _y;
    speed = _speed;
    colorH = _colorH + int(random(-20,20));
    dia = 0.0;
    flag = true;
  }
  
  void run(ArrayList<Ripple> ripples) {
    if (flag == true) {
      rippleDraw();
      move();
    }
  }
  
  void rippleDraw(){
    noFill();
    
    if(speed > 1.0){
      stroke(colorH, 90, 95, 100*(speed-1)/3);
      strokeWeight(2);
      ellipse(x, y, dia, dia);
    }
    if(speed > 1.5){
      stroke(colorH, 90, 95, 100*(speed-1.5)/3);
      strokeWeight(5);
      ellipse(x, y, dia*0.7, dia*0.7);
    }
    if(speed > 2.0){
      stroke(colorH, 90, 95, 100*(speed-2.0)/3);
      strokeWeight(7);
      ellipse(x, y, dia*0.7, dia*0.7);
      strokeWeight(2);
      stroke(colorH, 90, 95, 100*(speed-3)/3);
      ellipse(x + random(-100,100), y + random(-100,100), dia *0.3, dia *0.3);
    }
  }
  
  void move(){
    dia += speed;      
    speed *= FRICTION;
    if(speed < 1.0){
      flag = false;
    }
  }
}

