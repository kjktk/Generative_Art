PImage mapImage;
Table locationTable;
int rowCount;

Table dataTable;
Table nameTable;
float dataMin = -10;
float dataMax = 10;

void setup() {
  size(640, 400);
  mapImage = loadImage("map.png");
  
  locationTable = new Table("locations.tsv");
  //行数はグローバルに保存しておく
  rowCount = locationTable.getRowCount();
  
  dataTable = new Table("random.tsv");
  
  for (int row = 0; row < rowCount; row++) {
    float value = dataTable.getFloat(row, 1);
    if (value > dataMax) {
      dataMax = value;
    }
    if (value < dataMin) {
      dataMin = value;
    }
  }
  
  nameTable = new Table("names.tsv");
  
  PFont font = loadFont("Verdana-12.vlw");
  textFont(font);

}

void draw() {
  background(0);
  image(mapImage, 0, 0);
  smooth();
  fill(192, 0, 0);
  noStroke();
  //位置ファイルの行をループして取得
  for (int row = 0; row < rowCount; row++) {
    String abbrev = dataTable.getRowName(row);
    float x = locationTable.getFloat(abbrev, 1);
    float y = locationTable.getFloat(abbrev, 2);
    drawData(x, y, abbrev);
  }
}

void keyPressed() {
  if (key == ' ') {
    updateTable();
  }
}

void updateTable() {
  for (int row = 0; row < rowCount; row++) {
    float newValue = random(dataMin, dataMax);
    dataTable.setFloat(row, 1, newValue);
  }
}

void drawData(float x,float y, String abbrev) {
  float value = dataTable.getFloat(abbrev, 1);
  float radius = 0;
  
  if (value >= 0) {
    float a = map(value, 0, dataMax, 0, 255);
    radius = map(value, 0, dataMax, 1.5, 15);
    fill(#333366, a);
  } else {
    float a = map(value, 0, dataMax, 0, 255);
    radius = map(value, 0, dataMin, 1.5, 15);
    fill(#EC5166, a);
  }
  ellipseMode(RADIUS);
  ellipse(x, y, radius, radius);
  
  if (dist(x, y, mouseX, mouseY) < radius+2) {
    fill(0);
    textAlign(CENTER);
    String name = nameTable.getString(abbrev, 1);
    text(nf(value,0,2) + "(" + name + ")", x, y - radius - 4);
  }
}

