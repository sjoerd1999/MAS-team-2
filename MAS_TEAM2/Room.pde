class Room {
  int x, y, w, h;
  int tableSpacing = 4;
  ArrayList<PVector> tables = new ArrayList<PVector>();
  int numPersons = 0;
  String name = "";

  Room(int x_, int y_, int x2_, int y2_, String name_) {
    x = x_;
    y = y_;
    w = x2_-x_;
    h = y2_-y_;
    for (int xx = 1; xx < w-1; xx+=tableSpacing) {
      for (int yy = 1; yy < h-1; yy+=tableSpacing) {
        tables.add(new PVector(x+xx, y+yy));
      }
    }
    name = name_;
  }

  PVector getTable() {
    if (tables.size() <= numPersons) return(new PVector(0, 0));
    return tables.get(numPersons++).copy();
  }

  void display() {
    pushMatrix();
    translate(0, 0, 0.5);
    fill(255, 0, 0, 100);
    rect((x+0.5+w/2)*grid.SZ, (y+0.5+h/2)*grid.SZ, w*grid.SZ, h*grid.SZ);

    for (PVector t : tables) {
      pushMatrix();
      translate((t.x+0.5)*grid.SZ, (t.y+0.5)*grid.SZ, 2);
      fill(255, 0, 0, 100);
      box(3.5, 3.5, 4);
      translate(3, 0, 3.5+1);
      box(6, 8, 1);

      popMatrix();
    }

    if (controlPanel.showRoomLabels) {
      fill(255);
      translate(0, 0, 1);
      textSize(14);
      text(name, (x+w/2)*grid.SZ, (y+h/2)*grid.SZ);
    }
    popMatrix();
  }
}
