class Net {
  PVector location;
  PVector velocity;
  float size;
  int score;
  int colorH;
  AudioSnippet addSE;
  PFont scoreFont = loadFont("Technoidone-100.vlw");
  boolean is_plus;
  Net(float _x, float _y, float _size, int _colorH) {
    location = new PVector(_x, _y);
    velocity = new PVector(0, 0);
    size = _size;
    colorH =_colorH;
    ScoreKeeper scorekeeper = new ScoreKeeper();
    addSE = minim.loadSnippet("button01a.mp3");
    is_plus = false;
    int score = 0;
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
        b.location.set(0,0);
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
    if (is_plus) {
      stroke(random(colorH - 10, colorH + 10), 100, 100, 100);
      rect(0, 0, size+10, size+10);
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
    text(score, 0, size/4);
    popMatrix();
    popStyle();
    is_plus = false;
  }
  void move(float _x, float _y) {
    float d = PVector.dist(location, new PVector(_x, _y)); 
    location.x += d;
    location.y += d;
  }
}

