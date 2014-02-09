class Render {
  int numRipples = 1;
  int numFlocks = 50;
  int numBarriers = 5;
  int mode = 0;
  color[] pixelBuffer;
  PGraphics pg;
  Flock flock;
  
  Render() {
    pg = createGraphics(width, height);
    pixelBuffer = new color[width * height];
    flock = new Flock();
    for (int i = 0; i < numFlocks; i++) {
      int flockType = Math.round(random(0,4));
      flock.addBoid(new Boid(random(width),random(height),flockType));
    }
  }
  PImage renderImage() {
    fill(0,50);
    //drawGrid();
    rect(-20, -20, width+40, height+40); //fixed
    flock.run();

    loadPixels();
    arrayCopy(pixels,pixelBuffer);
    for (int i = 0; i < width * height; i++) {
      pixels[i] = 0;
    }
    updatePixels();
    pg.beginDraw();
    pg.smooth();
    pg.loadPixels();
    for (int i = 0; i < width * height; i++) {
      pg.pixels[i] = pixelBuffer[i];
    }
    pg.updatePixels();
    pg.endDraw();
    PImage img = pg.get(0,0,pg.width,pg.height);
    return img;
  }
  

}


