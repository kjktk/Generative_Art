class Net {
  PVector location;
  PVector velocity;
  float size;
  public int score;
  int colorH;
  public int question;
  AudioSnippet addSE;
  PFont scoreFont = loadFont("Technoidone-100.vlw");
  PFont answerFont = createFont("HiraMinPro-W6", 50);
  boolean is_plus;
  public boolean is_score;
  public boolean answer;
  public boolean is_question;
  PGraphics pg;
  public Boid catched;
  public boolean isHightScore;
  Net(float _x, float _y, float _size, int _colorH) {
    location = new PVector(_x, _y);
    velocity = new PVector(0, 0);
    size = _size;
    colorH =_colorH;
    ScoreKeeper scorekeeper = new ScoreKeeper();
    addSE = minim.loadSnippet("button01a.mp3");
    is_plus = false;
    is_score = false;
    score = 0;
    question = 1;
    answer = false;
    isHightScore = false;
  }
  void run() {
    this.draw();
  }
  void catchCarp(ArrayList <Boid> boids) {
    for (int i = 0; i < boids.size (); i++) {
      Boid b = boids.get(i);
      float d = PVector.dist(location, b.location);
      if (Math.abs(d) < size) {
        addSE.play();
        addSE.rewind();
        is_plus = true;
        b.location.set(0, 0);
        boids.remove(i);
        score++;
      }
    }
  }
  void draw() {
    pushStyle();
    strokeWeight(3);
    stroke(random(colorH - 10, colorH + 10), 50, 100, 10);
    noFill();
    pushMatrix();
    translate(location.x, location.y);
    rectMode(RADIUS);
    rect(0, 0, size, size);
    if (is_plus || answer) {
      stroke(random(colorH - 10, colorH + 10), 100, 100, 100);
      fill(random(colorH - 10, colorH + 10), 100, 100, 100);
      rect(0, 0, size+10, size+10);
      rect(0, 0, size+15, size+15);
    } else if (isHightScore) {
      rect(0, 0, size+15, size+15);
      
    } else {
      rect(0, 0, size+5, size+5);
    }
    strokeWeight(1);
    for (int i = int (-size); i < int(size); i+= 20) {
      line(i, -size, i, size);
    }
    for (int i = int (-size); i < int(size); i+= 20) {
      line(-size, i, size, i);
    }
    textFont(scoreFont);
    textAlign(CENTER);
    if (is_plus) {
      textSize(size* 1.1);
    } else {
      textSize(size);
    }
    if (is_score) {
      text(score, 0, size/4);
    } else if (is_question) {
      textFont(answerFont);
      if (question == 1) {
        text("楽しい", 0, size/7);
      } else {
        text("つまらん", 0, size/7);
      }
    }
    popMatrix();
    popStyle();
    is_plus = false;
  }
  void move(float _x, float _y) {
    float dist = sqrt((_x-location.x)*(_x-location.x)+(_y-location.y)*(_y-location.y));
    float direction = atan2(location.x-_x, _y-location.y)+HALF_PI;
    location.x += dist*cos(direction);
    location.y += dist*sin(direction);
  }
  void answer() {
    if (answer == false) {
      answer = true;
    }
  }
  void drawNet() {
    pg = createGraphics(int(size), int(size), OPENGL);
    //  PGraphicsに描画する
    pg.beginDraw();
    pg.background(0);
    pg.pushStyle();
    pg.strokeWeight(3);
    pg.stroke(random(colorH - 10, colorH + 10), 50, 100, 10);
    pg.noFill();
    pg.pushMatrix();
    pg.translate(location.x, location.y);
    pg.rectMode(RADIUS);
    pg.rect(0, 0, size, size);
    if (is_plus) {
      pg.stroke(random(colorH - 10, colorH + 10), 100, 100, 100);
      pg.rect(0, 0, size+10, size+10);
    } else {
      pg.rect(0, 0, size+5, size+5);
    }
    pg.strokeWeight(1);
    for (int i = int (-size); i < int(size); i+= 20) {
      pg.line(i, -size, i, size);
    }
    for (int i = int (-size); i < int(size); i+= 20) {
      pg.line(-size, i, size, i);
    }
    pg.popMatrix();
    pg.popStyle();
    pg.endDraw();
    beginShape();
    texture(pg);  
    vertex(pos[0][0], pos[0][1], 0, 0);
    vertex(pos[1][0], pos[1][1], pg.width, 0);
    vertex(pos[2][0], pos[2][1], pg.width, pg.height);
    vertex(pos[3][0], pos[3][1], 0, pg.height);
    endShape(CLOSE);
    if ( mousePressed && selected >= 0 ) {
      pos[selected][0] = mouseX;
      pos[selected][1] = mouseY;
    } else {
      float min_d = 20; // この値が頂点への吸着の度合いを決める
      selected = -1;
      for (int i=0; i<4; i++) {
        float d = dist( mouseX, mouseY, pos[i][0], pos[i][1] );
        if ( d < min_d ) {
          min_d = d;
          selected = i;
        }
      }
    }
    if ( selected >= 0 ) {
      ellipse( mouseX, mouseY, 20, 20 );
    }
  }
}

