ArrayList<Cell> cells = new ArrayList<Cell>();
ArrayList<Cell> babies = new ArrayList<Cell>();
ArrayList<Cell> toRemove = new ArrayList<Cell>();
ArrayList<Food> foods = new ArrayList<Food>();
ArrayList<Food> eaten = new ArrayList<Food>();
int startCells = 50;
int maximCells = 100;
int startFoods = startCells / 2;
int maximFoods = maximCells / 2;


void setup() 
{
  fullScreen(1);
  textAlign(CENTER, CENTER);
  for (int i = 0; i < startCells; i++) 
  {
    randCell();
  }
  for (int i = 0; i < startFoods; i++) 
  {
    randFood();
  }
}


void draw()  //<>//
{
  background(51);
  for (Food food : foods) 
  {
    food.show();
  } 
  foods.removeAll(eaten);
  eaten.clear(); //Removes all eaten food
  for (Cell cell : cells) 
    {
    cell.update();
    }
  cells.removeAll(toRemove); //Removes all cells marked to be dead
  toRemove.clear();
  cells.addAll(babies); //Adds all babies to cells
  babies.clear();
  if (cells.size() < maximCells && frameCount % 100 == 0) 
  {
    randCell();
  }
  if (foods.size() < maximFoods && frameCount % 25 == 0) 
  {
    randFood();
  }
} //<>//


void randCell() {
  PVector pos = new PVector(random(width), random(height));
  int radius = int(random(3, 10));
  color rgb = color(int(random(255)),
                    int(random(255)),
                    int(random(255)));
  float accSpeed = random(.05, .2);
  float speed = random(.1, 2);
  float sight = int(random(200));
  float repro = int(random(2.55, 5));
  cells.add(new Cell(pos, radius, 1, rgb, rgb, accSpeed, speed, sight, repro));
}


void randFood() 
{
  int x = int(random(width));
  int y = int(random(height));
  PVector pos = new PVector(x, y);
  foods.add(new Food(pos));
}


void mousePressed() 
{
  if (mouseButton == RIGHT) 
  {
    PVector pos = new PVector(mouseX, mouseY);
    foods.add(new Food(pos));
  } 
  else if (mouseButton == LEFT) //Prints info about cell if you click on it
  {
     for (Cell c : cells) {
       boolean top = mouseY < c.pos.y + c.r;
       boolean bot = mouseY > c.pos.y - c.r;
       boolean lef = mouseX > c.pos.x - c.r;
       boolean rig = mouseX < c.pos.x + c.r;
       if (top && bot && lef && rig) 
       {
         for(String s : c.info()) 
         {
           print(s);
         }
         print("\n");
       }
     }
  }
}
