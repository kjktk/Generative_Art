class ScoreKeeper {
  public int score;
  PFont scoreFont = loadFont("Technoidone-100.vlw");
  ScoreKeeper() {
    score = 0;
  }
  void drawNetScore() {
    textFont(scoreFont);
    textAlign(CENTER);
    textSize(size);
    text(score,0,size/4);
  }
  void pluseScore() {
    
  }
  void hightScore() {
    
  }
}
