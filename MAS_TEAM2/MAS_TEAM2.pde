/*
TO DO:
 MOVEMENT:
 - Finish 'keep on the right side' movement (still a bit buggy when close to door openings)
 - Fine-tune movement parameters so agents walk at walking speed (~1.4 m/s)
 - Make use of timetables;
 Between 8:50 and 9:00 students will enter the building and go to a room
 Then they will leave between 10:45 and 11:00, during which new students will enter
 Repeat for other times
 Lunch? Bathroom? Coffeebreaks? (first the above points)
 
 COVID:
 - Get and implement covid19-specific paramenters/behaviour
 - Quarantine infected cases?
 - 
 
 VISUALIZATION:
 - A bit of framerate optimization for large number of agents.
 - Bigger floorplan(?)
 - Show more readable graphs (with labels)
 
 SIMULATION:
 - Integrate an option to set deltaT (the timestep), which then also changes movement speed, avoid forces, infection rates, etc.
 
 AGENTS:
 - Make agents autonomous, not the main sketch saying they should go somewhere, but the agents deciding for themselves
 
 Probs a lot more to add...
 
 */

// Press spacebar to spawn agents
// Press 'm' to start moving them

import peasy.*;
PeasyCam cam;

Environment grid;
ControlPanel controlPanel;
ArrayList<Agent> agents = new ArrayList<Agent>();

int aniFrames = 9;             // Make this lower to improve startup time. Less frames in the animation = faster boot (1, 9 and 18 work well)
PShape[] human = new PShape[3]; // Human walking 3D models. [0] = susceptible, [1] = infected, [2] = recovered

float timer;                    // How many seconds (real life seconds) the simulation has been run.
float deltaT = 1/30.00;         // Seconds per frame

String[] measures = {"Mask", "SocialDistance"};

void setup() {
  size(1200, 800, P3D);
  //fullScreen(P3D);

  rectMode(CENTER);
  textAlign(CENTER, CENTER);

  grid= new Environment();
  controlPanel = new ControlPanel();
  cam = new PeasyCam(this, 1000);
  loadModels();
  frameRate(30);
}

void loadModels() {
  // Colors for the 3 states; susceptible, infected, recovered
  color[] colors = {color(72, 255, 100), color(255, 100, 100), color(72, 184, 232)};

  // Load 3d model data for the human visualization
  for (int s = 0; s < 3; s++) {
    human[s] = createShape(GROUP);
    for (int i = 0; i< aniFrames; i++) {
      PShape load = loadShape("3Dmodels/wlk" + (1 + i * (36 / aniFrames)) + ".obj");
      load.setFill(colors[s]);
      load.translate(0, 0, -i*8.45 * (18.00 / aniFrames));
      human[s].addChild(load);
    }
    PShape sit = loadShape("3Dmodels/sit.obj");
    sit.scale(0.1);
    sit.translate(0, -3.5);
    sit.setFill(colors[s]);
    human[s].addName("SIT", sit);
    human[s].scale(0.1);
  }
}

void draw() {
  applyLights();
  translate(-grid.W*grid.SZ/2, -grid.H*grid.SZ/2);
  surface.setTitle("FPS: " + frameRate);

  // Run the simulation for a couple of iterations each frame, depending on the set simulationspeed
  for (int iteration = 0; iteration < controlPanel.simulationSpeed; iteration++) {
    for (Agent a : agents) {
      a.run();
    }
    
    for (int i = 0; i < agents.size(); i++) {
      for (int j = 0; j < agents.size(); j++) {
        if (i != j) {
          agents.get(i).avoid(agents.get(j));
          agents.get(i).infect(agents.get(j));
        }
      }
    }
    
    controlPanel.update();
    timer+=deltaT;
  }
  
  // Visualize!
  for (Agent a : agents) {
    a.show();
    a.showTarget();
  }
  grid.display();
  controlPanel.display();
}

void applyLights() {
  lights();
  background(255, 255, 255);  

  double dst_ = cam.getDistance() + 100;
  float dst = (float)dst_ + 0;
  pointLight(100, 0, 255, -dst, dst, dst);
  pointLight(0, 0, 255, dst, -dst, 0);
  pointLight(0, 255, 0, dst, dst, -dst);
  pointLight(255, 255, 0, -dst, -dst, 0);
  directionalLight(40, 80, 100, 0, -1, 0);

  noStroke();
  fill(100, 100, 170, 180);
  sphere((float)cam.getDistance() + 400);
}


void keyPressed() {
  if (key == ' ') {
    // Add some agents in the grid at random locations
    for (int y = 0; y < grid.H; y++) {
      for (int x = 0; x < grid.W; x++) {
        if (!grid.get(x, y) && random(10) < 0.1 && agents.size() < grid.getMaxAgents()) {
          agents.add(new Agent(new PVector(random((grid.SZ * x), (grid.SZ * x) + grid.SZ), random((grid.SZ * y), (grid.SZ * y) + grid.SZ)),measures[0]));
        }
      }
    }
  }

  if (key == 'm') {
    for (Room r : grid.rooms) r.numPersons = 0;
    for (Agent a : agents) {
      //a.setTargetRandom();
      int roomN = floor(random(grid.rooms.size()));
      while (grid.rooms.get(roomN).numPersons >= grid.rooms.get(roomN).tables.size()) roomN = floor(random(grid.rooms.size()));
      a.setTarget(grid.rooms.get(roomN).getTable());
    }
  }
}

void mousePressed() {
  controlPanel.mousePressed();
}

void mouseReleased() {
  controlPanel.mouseReleased();
}
