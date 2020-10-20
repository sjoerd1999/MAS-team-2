import java.util.Random;

class Agent {
  PathFinder pf;
  Random r = new Random();

  // Movement constants
  float speed = 0.2;
  float maxVelocity = 0.6;
  float returnVelocity = 0.2;
  float loseVelocity = 1.035;

  // Movement position/velocity
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector fpos = new PVector(0, 0); // Position in grid
  PVector targetPos = new PVector(0, 0);

  // Walking animation
  float aniFrame = 0;

  // Basic Agent parameters
  int age = r.nextInt(25-18 + 1) + 18;    // between 18 and 25
  boolean wearsMask = false;
  int socialDistance = 5;                // used in the avoid method

  // Covid-19 parameters
  String[] states = {"Susceptible", "Infected", "Recovered"};
  String currentState = states[0]; // Susceptible by default
  float transmissionProbability = 0.001;
  String measure = "";        // currently employed covid measure

  Agent(PVector position_, String measure_) {
    double rnd = Math.random();
    if (rnd < 0.1)
      currentState = states[1]; // Randomly spawn infected individuals

    this.measure = measure_;
    if (measure.equals("Mask")) {
      if (rnd < 0.8)
        wearsMask = true;         // Make some people wear a mask
    } else if (measure.equals("SocialDistance")) {
      socialDistance = 15;
    }

    pos = position_.copy();
    pf = new PathFinder();
  }



  void run() {
    //if (PVector.dist(pos, PVector.mult(targetPos, grid.SZ)) < 10 && random(10) < 0.05) setTargetRandom();
    move();
    recover();

    aniFrame+=vel.mag()*(aniFrames / 18.00)*1.1;
    if (floor(aniFrame) >= aniFrames || vel.mag() < 0.1) aniFrame = 0;
  }



  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //-----------------------------------------GETTERS AND SETTERS---------------------------------------------//
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void setTarget(PVector t) {
    pf.setTarget((int)t.x, (int)t.y);
    targetPos.set(t.x+0.5, t.y+0.5);
  }

  void setTargetRandom() {
    setTarget(grid.getRandomTarget());
  }

  String getCurrentState() {
    return this.currentState;
  }

  void setCurrentState(String s) {
    this.currentState = s;
  }



  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //----------------------------------MOVING AROUND USING PATHFINDING----------------------------------------//
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void move() {
    pf.run();

    String dir = pf.navGrid[int(fpos.y)][int(fpos.x)];
    float speed_ = speed;
    if (PVector.dist(pos, targetPos) < 30) speed_ = speed * (PVector.dist(pos, targetPos)/30.0);
    if (dir.equals("d")) vel.y+=speed_;
    else if (dir.equals("u")) vel.y-=speed_;
    else if (dir.equals("r")) vel.x+=speed_;
    else if (dir.equals("l")) vel.x-=speed_;

    // Wall avoidance
    pos.x+=vel.x;
    pos.x = constrain(pos.x, 0, grid.W*grid.SZ);
    fpos.set(constrain(floor(pos.x/(grid.SZ*1.00)), 0, grid.W-1), constrain(floor(pos.y/(grid.SZ*1.00)), 0, grid.H-1));
    if (pf.navGrid[int(fpos.y)][int(fpos.x)].equals("_")) {
      if (vel.x>0) {
        vel.x*=-(returnVelocity+random(0.1, 0.3));
        pos.x=(fpos.x*grid.SZ)-1;
      } else if (vel.x<0) {
        vel.x*=-(returnVelocity+random(0.1, 0.3));
        pos.x=(fpos.x*grid.SZ)+grid.SZ+1;
      }
    }

    pos.y+=vel.y;
    pos.y = constrain(pos.y, 0, grid.H*grid.SZ);
    fpos.set(constrain(floor(pos.x/(grid.SZ*1.00)), 0, grid.W-1), constrain(floor(pos.y/(grid.SZ*1.00)), 0, grid.H-1));
    if (pf.navGrid[int(fpos.y)][int(fpos.x)].equals("_")) {      
      if (vel.y>0) {
        vel.y *= -(returnVelocity +random(0.1, 0.3));
        pos.y = (fpos.y * grid.SZ) - 1;
      } else if (vel.y<0) {
        vel.y *= -(returnVelocity + random(0.1, 0.3));
        pos.y = (fpos.y * grid.SZ) + grid.SZ + 1;
      }
    }

    vel.div(loseVelocity);
    if (vel.mag() > maxVelocity) vel.setMag(maxVelocity);

    if (PVector.dist(pos, PVector.mult(targetPos, grid.SZ)) < 3 && vel.mag() < 0.1) {
      pos = PVector.mult(targetPos, grid.SZ);
      vel.setMag(0);
    }
  }



  void avoid(Agent a) {
    float dist = PVector.dist(a.pos, pos); // sqrts take quite some time to process, so using distance squared now instead

    //float distSq = sq(a.pos.x-pos.x)+sq(a.pos.y-pos.y);
    if (dist < this.socialDistance) {
      PVector force = PVector.sub(pos, a.pos);
      force.setMag(1/(dist+0.1));
      //float pforce = 1+constrain(PVector.dist(pos,PVector.mult(targetPos, 20))*0.01, 0, 1.0);
      //println(pforce);
      //force.mult(pforce);
      vel.add(force);
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //------------------------------------COVID19 INFECTING/RECOVERING-----------------------------------------//
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // I can infect others if I am carrying the virus
  // Only infect Susceptible individuals -> enter Infected state
  void infect(Agent a) {
    float dist = PVector.dist(a.pos, pos);
    if (dist < 20 && this.currentState.equals("Infected") && a.getCurrentState().equals("Susceptible")) {
      double rnd = Math.random();
      if (rnd < this.transmissionProbability) {
        a.setCurrentState("Infected");
      }
    }
  }

  // recover from the infection very simple implementation
  void recover() {
    double rnd = Math.random();
    if (rnd < 0.001 && this.getCurrentState().equals("Infected"))
      this.setCurrentState("Recovered");
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //----------------------------------DISPLAYING THE AGENT AND TARGET----------------------------------------//
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////


  void show() {
    float angle = atan2(vel.y, vel.x);
    int state = (getCurrentState().equals("Infected") ? 1 : getCurrentState().equals("Recovered") ? 2 : 0);
    PShape humanObj = human[state].getChild(floor(aniFrame));
    if (PVector.dist(pos, PVector.mult(targetPos, grid.SZ)) < 3 && vel.mag() < 0.1) {
      humanObj = human[state].getChild("SIT");
      angle = 0;
    }

    pushMatrix();
    translate(pos.x, pos.y);
    rotateX(HALF_PI);
    rotateY(angle+HALF_PI);
    shape(humanObj);
    popMatrix();
  }

  void showTarget() {
    stroke(0, 40);
    strokeWeight(1);
    line(pos.x, pos.y, targetPos.x*grid.SZ, targetPos.y*grid.SZ);
    pushMatrix();
    translate(targetPos.x*grid.SZ, targetPos.y*grid.SZ);
    stroke(0, 100);
    line(-3, -3, 3, 3);
    line(3, -3, -3, 3);
    popMatrix();
    noStroke();
  }
}
