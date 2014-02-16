float FRICTION = 0.985; //波紋の減衰率

public class Ripple{
  float x, y;     //波紋の中心座標
  float dia;    //波紋の直径
  float speed;
  int colorH;   
  boolean flag = false;
  
  
  Ripple(float _x,float _y, float _speed, int _colorH){
    x = _x;
    y = _y;
    speed = _speed;
    colorH = _colorH;
    dia = 0.0;
    flag = true;
  }
  
  void run(ArrayList<Ripple> ripples, PGraphics render) {
    if (flag == true) {
      rippleDraw(render);
      move();
    }
  }
  
  void rippleDraw(PGraphics render){
      render.noFill();
      render.colorMode(HSB,360,100,100);
      if(speed > 1.0){
        render.stroke(colorH, 100, 100, 100*(speed-1)/3);
        render.strokeWeight(3);
        render.ellipse(x, y, dia, dia);
      }
      if(speed > 1.5){
        render.stroke(colorH, 100, 100, 100*(speed-1.5)/3);
        render.strokeWeight(7);
        render.ellipse(x, y, dia*0.7, dia*0.7);
      }
      if(speed > 2.0){
        render.stroke(colorH, 100, 100, 100*(speed-2.0)/3);
        render.strokeWeight(10);
        render.ellipse(x, y, dia*0.5, dia*0.5);
      }
  }
  
  void move(){
    dia += speed;      //直径を速度分大きく
    speed *= FRICTION; //速度減衰
    if(speed < 1.0){   //速度が1.0以下になったら描画しない設定
      flag = false;
    }
  }
}

