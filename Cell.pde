public class Cell 
{
  PVector pos;
  PVector goal; 
  PVector vel;
  PVector acc;
  float accSpeed;
  float speed;
  float startR;
  float r;
  float rGoal;
  float yoff = 0;  //For perlin noise  
  int gen;  
  color shade;
  color famShade;
  float sight;
  float repro;     //How many times original size to reproduce  
  float mutChance; 
  boolean fleeing = false;
  
  
  Cell(PVector _pos, float _r, int _gen, color _shade, color _famShade, float _accSpeed, float _speed, float _sight, float _repro) 
  {
    pos = _pos;
    newGoal();
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    accSpeed = constrain(_accSpeed, .05, 1);
    speed = constrain(_speed, 1, 20);
    r = constrain(_r, 1, 200);
    startR = r;
    rGoal = r;
    gen = _gen;    
    shade = _shade;
    famShade = _famShade;
    sight = constrain(_sight, 1, 500);
    repro = constrain(_repro, 1.2, 10);    
    mutChance = random(-0.15, 0.5);
  }
  
  
  String[] info() 
  {
    String[] info = new String[9];
    info[0] = ("X: " + this.pos.x + " Y: " + this.pos.y + "\n");
    info[1] = ("Velocity X: " + vel.x + " Velocity Y: " + vel.y + "\n");
    info[2] = ("Original Radius: " + Float.toString(startR) + "\n");
    info[3] = ("Radius: " + Float.toString(rGoal) + "\n");
    info[4] = ("Generation: " + Integer.toString(gen) + "\n");
    info[5] = ("Max Speed: " + Float.toString(speed) + "\n");
    info[6] = ("Sight Radius: " + Float.toString(sight) + "\n");
    info[7] = ("Reproduction: " + Float.toString(repro) + "\n");
    info[8] = ("Mutation: " + Float.toString(mutChance) + "\n");
    return info;   
  }
   
    
  void update() 
  {
    move();
    tele();
    grow();
    lookFood();
    lookCells();
    show();
  }
  
  
  void applyForce(PVector force) 
  {
    acc.add(force);
  }
  
  
  void move() 
  {
   float d = pos.dist(goal); //Distance to goal
   if (d < r) 
   {
     fleeing = false;
     newGoal();
   } 
   PVector dir = PVector.sub(goal, pos); //Figures out direction, adds to acceleration
   dir.setMag(accSpeed);
   applyForce(dir);
   vel.add(acc);
   vel.limit(speed);
   pos.add(vel); 
   acc.mult(0);
  }
  
  
  void tele() //Moves cell across screen if it goes off edge
  { 
   if (pos.x < -r) 
   {
     pos.x = width + r;
     newGoal();
   } 
   else if (pos.x > width + r)
   {
     pos.x = -r;
     newGoal();
   } 
   
   if (pos.y < -r) 
   {
     pos.y = height + r;
     newGoal();
   } 
   else if (pos.y > height + r) 
   {
     pos.y = -r;
     newGoal();
   }
  }
  
  
  void grow() 
  {
    if (r < rGoal) 
    {
      r += .1;
    }
    if (r > startR * repro) 
    {
      reproduce();
    }
  }
  
  
  void show() 
  {
    stroke(shade);
    strokeWeight(2);
    fill(shade, 200);
    pushMatrix();
    translate(pos.x, pos.y);
    beginShape();
    float xoff = 0;
    for (float a = 0; a < TWO_PI; a += 0.09) //Makes cell wavy
    {
      float offset = map(noise(xoff, yoff), 0, 1, .01 * -r, r);
      float newR = r + offset;
      float x = (newR * cos(a)) - vel.x * vel.mag();
      float y = (newR * sin(a)) - vel.y * vel.mag();
      vertex(x, y);
      xoff += 0.1;
    }
    endShape();
    popMatrix();
    yoff += .05;
  
    noStroke();
    fill(famShade);
    ellipse(pos.x, pos.y, r * 1.5, r * 1.5); //Puts family color in center of cell
    
    stroke(shade, 100);
    strokeWeight(.5);
    noFill();
    float vision = (r + sight) * 2;
    ellipse(pos.x, pos.y, vision, vision); //Draws vision radius
    
    line(pos.x, pos.y, goal.x, goal.y); //Draws line to goal
    
    color textCol = (brightness(famShade) > 127) ? 0 : 255;
    fill(textCol);
    textSize(r * 1.5);
    text(gen, pos.x, pos.y); //Draws generation number
  }
  
  
  void lookFood()
  { 
    float dist = sight * 2;
      for (Food f : foods) 
      {
        float d = pos.dist(f.pos);
        boolean canSee = d -r - f.size - sight <= 0;
        if (d < r)  //If touching food
        { 
          rGoal += f.value;
          eaten.add(f);
        } 
        else if (canSee && !fleeing)
        { 
            if (d < dist) 
            {
              goal = f.pos.copy();
              dist = d; //Makes sure cell's goal is closest food
            }
        }
      }
  }


  void lookCells()
  { 
    ArrayList<PVector> toFlee = new ArrayList<PVector>(); //Cells to flee from
    for (Cell other : cells) 
    {
      if (other == this) 
      { 
        break;
      }
      float d = pos.dist(other.pos);
      boolean touching = d - r - other.r <= 0;
      boolean ate = false; //Used to check if cell should bounce
    
      if (other.famShade != famShade) //If not same family
      { 
        boolean canSee = d - r - other.r - sight <= 0;  
        if (canSee) 
        {  
          boolean meBigger = r > 1.5 * other.r;
          boolean itBigger = other.r > 1.5 * r;
              
          if (meBigger && touching) 
          {
            rGoal += other.r / 10; //Eat other
            toRemove.add(other);
            newGoal();
            ate = true;
          } 
          else if (meBigger && !fleeing) 
          {
              goal = other.pos.copy(); 
          } 
          else if (itBigger) 
          {
              toFlee.add(other.pos.copy());   
          } 
        }       
      }
      if(touching && !ate) 
      {
        PVector force = awayVector(other.pos);
        force.setMag(r / 4);
        applyForce(force);
        other.applyForce(force.setMag(-1));
      }
    }
 
    if (toFlee.size() > 0) 
    {
      fleeing = true;
      fleeGoal(toFlee);
    }
  }
  
  
  void reproduce() 
  {
    for (int i = 0; i < 2; i++) 
    {
      float newX = (random(1) < .5) ? pos.x + r : pos.x - r;
      float newY = (random(1) < .5) ? pos.y + r : pos.y - r;
      PVector newP = new PVector(newX, newY);
      float newRad = ((r / 1.2) + mutChance);
      color newRGB = color(red(shade) + random(-mutChance, mutChance) * 80,
                           green(shade) + random(-mutChance, mutChance) * 80,
                           blue(shade) + random(-mutChance, mutChance) * 80);
      float nAccSp = accSpeed + accSpeed * mutChance;
      float nSpeed = speed + mutChance;
      float nSight = sight + mutChance;
      float nRepro = repro + mutChance;
      
      babies.add(new Cell(newP, newRad, gen + 1, newRGB, famShade, nAccSp, nSpeed, nSight, nRepro));
      toRemove.add(this);
    }
  }
  

  void newGoal()
  { 
    PVector v = PVector.random2D();
    v.setMag(sight + r);
    goal = PVector.add(pos, v);
  }
  
  
  void fleeGoal(ArrayList<PVector> flee) 
  {
    PVector v = new PVector(0, 0);
    for (PVector vec : flee) 
    {
      v.add(vec);
    }
    v.div(flee.size());
    PVector dir = awayVector(v);
    dir.setMag(sight + r);
    goal = PVector.add(dir, pos);
  }
  
  PVector awayVector(PVector other)
  { 
    PVector v = PVector.sub(pos, other);
    return v;
  } 
}
