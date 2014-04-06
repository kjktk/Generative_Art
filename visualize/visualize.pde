PImage mapImage;
Table locationTable;
int rowCount;

Table dataTable;
Table nameTable;
float dataMin = -10;
float dataMax = 10;

float closestDist;
String closestText;
float closestTextX;
float closestTextY;

Integrator[] interpolators;

void setup() {
  size(640, 400);
  frameRate(60);
  mapImage = loadImage("map.png");
  
  locationTable = new Table("locations.tsv");
  //行数はグローバルに保存しておく
  rowCount = locationTable.getRowCount();
  
  dataTable = new Table("random.tsv");
  
  //初期値をIntegratorに設定
  interpolators = new Integrator[rowCount];
  for (int row = 0; row < rowCount; row++) {
    float initialValue = dataTable.getFloat(row, 1);
    interpolators[row] = new Integrator(initialValue, 0.7, 0.01);
  }
  
  nameTable = new Table("names.tsv");
  
  PFont font = loadFont("Verdana-12.vlw");
  textFont(font);
  
  smooth();
  noStroke();
  
  updateTable();

}

void draw() {
  background(0);
  image(mapImage, 0, 0);
  
  //値を更新
  for (int row = 0; row < rowCount; row++) {
    interpolators[row].update();
  }
  
  
  closestDist = MAX_FLOAT;
  
  //位置ファイルの行をループして取得
  for (int row = 0; row < rowCount; row++) {
    String abbrev = dataTable.getRowName(row);
    float x = locationTable.getFloat(abbrev, 1);
    float y = locationTable.getFloat(abbrev, 2);
    drawData(x, y, abbrev);
  }
  
  if (closestDist != MAX_FLOAT) {
    fill(0);
    textAlign(CENTER);
    text(closestText, closestTextX, closestTextY);
  }
}

void keyPressed() {
  if (key == ' ') {
    updateTable();
  }
}

void updateTable() {
  dataTable = new Table("http://benfry.com/writing/map/random.cgi");
  for (int row = 0; row < rowCount; row++) {
    float newValue = random(-10,10);
    interpolators[row].target(newValue);
  }
}

void drawData(float x,float y, String abbrev) {
  
  int row = dataTable.getRowIndex(abbrev);
  float value = interpolators[row].value;
  float radius = 0;
  
  if (value >= 0) {
    radius = map(value, 0, dataMax, 1.5, 15);
    fill(#333366,200);
  } else {
    radius = map(value, 0, dataMin, 1.5, 15);
    fill(#EC5166,200);
  }
  ellipseMode(RADIUS);
  ellipse(x, y, radius, radius);
  
  float d = dist(x, y, mouseX, mouseY);
  if (d < radius+2 && d < closestDist) {
    closestDist = d;
    String val = nfp(interpolators[row].target,0,2);
    String name = nameTable.getString(abbrev, 1);
    closestText = name + " " + val;
    closestTextX = x;
    closestTextY = y - radius - 4;
  }
}

