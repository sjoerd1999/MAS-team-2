// Has the floorplan data
// Displays the floorplan

class Environment {
  int H, W;                // How many squares by how many squares is the grid?
  int SZ = 5;             // How many pixels is each square?
  boolean[][] data;
  ArrayList<Room> rooms = new ArrayList<Room>();

  Environment() {
    String[] gridRaw = loadStrings("floorplan.txt");

    H = gridRaw.length;
    W = gridRaw[0].length();
    data = new boolean[H][W];
    rooms.add(new Room(6, 1, 26, 22, "WH125"));
    rooms.add(new Room(28, 1, 40, 22, "WH123"));
    rooms.add(new Room(42, 1, 54, 22, "WH121"));
    rooms.add(new Room(56, 1, 69, 22, "WH119"));

    rooms.add(new Room(1, 33, 14, 59, "WH124"));
    rooms.add(new Room(16, 31, 50, 59, "WH122"));
    rooms.add(new Room(1, 61, 25, 87, "WH120"));
    rooms.add(new Room(27, 61, 50, 87, "WH118"));

    rooms.add(new Room(56, 31, 73, 52, "WH116"));
    rooms.add(new Room(56, 54, 73, 73, "WH114"));

    rooms.add(new Room(5, 97, 21, 118, "WH117"));
    rooms.add(new Room(23, 97, 35, 118, "WH115"));
    rooms.add(new Room(37, 97, 50, 118, "WH113"));
    rooms.add(new Room(52, 104, 65, 118, "WH111"));


    for (int y = 0; y < H; y++) {
      for (int x = 0; x < W; x++) {
        data[y][x] = gridRaw[y].charAt(x) == 'x';
      }
    }
  }

  boolean get(int x, int y) {
    if (x >= 0 && x < W && y >= 0 && y < H) return data[y][x];
    else return true;
  }

  void display() {
    fill(150, 150, 170);
    rect(W*SZ/2, H*SZ/2, W*SZ, H*SZ);
    for (Room r : rooms) r.display();

    fill(200, 200, 220); 
    for (int y = 0; y < H; y++) {
      for (int x = 0; x < W; x++) {
        if (this.get(x, y)) {
          pushMatrix();
          translate(SZ / 2 + SZ * x, SZ / 2 + SZ * y, 10);
          box(SZ, SZ, 25);
          popMatrix();
        }
      }
    }
  }

  PVector getRandomTarget() {
    int x = floor(random(1, grid.W-1));
    int y = floor(random(1, grid.H-1));
    while (this.get(x, y)) {
      x = floor(random(1, grid.W-1));
      y = floor(random(1, grid.H-1));
    }
    return new PVector(x, y);
  }

  int getMaxAgents() {
    int tot = 0;
    for (Room r : rooms) tot += r.tables.size();
    return tot;
  }
}
