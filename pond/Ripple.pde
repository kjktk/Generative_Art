float FRICTION = 0.985; //波紋の減衰率

public class Ripple{
  int x, y;     //波紋の中心座標
  float dia;    //波紋の直径
  float speed;
  int colorH;   
  boolean flag;
  
  Ripple(){
    init(0, 0, 0, 0);
    flag = false;
  }

  public Ripple(Ripple src){
    this.x = src.x;
    this.y = src.y;
    this.speed = src.speed;
    this.colorH = src.colorH;
    this.dia = src.dia;
    this.flag = src.flag;
  }
  
  public void init(int _x, int _y, float _speed, int _colorH){
    x = _x;
    y = _y;
    speed = _speed;
    colorH = _colorH;
    dia = 0.0;
    flag = true;
  }
  
  public void rippleDraw(){
    noFill();
    
    if(speed > 1.0){
      stroke(colorH, 40, 95, 100*(speed-1)/3);
      strokeWeight(4);
      ellipse(x, y, dia, dia);
    }
    if(speed > 1.5){
      stroke(colorH, 40, 95, 100*(speed-1.5)/3);
      strokeWeight(3);
      ellipse(x, y, dia*0.7, dia*0.7);
    }
    if(speed > 2.0){
      stroke(colorH, 40, 95, 100*(speed-2.0)/3);
      strokeWeight(1);
      ellipse(x, y, dia*0.7, dia*0.7);
    }
  }
  
  public void move(){
    dia += speed;      //直径を速度分大きく
    speed *= FRICTION; //速度減衰
    if(speed < 1.0){   //速度が1.0以下になったら描画しない設定
      flag = false;
    }
  }
  
  public boolean getFlag(){
    return flag;
  }
}

