public class Food 
{
  PVector pos;
  int size;
  int value;
  
  Food(PVector _pos) 
  {
    pos = _pos;
    size = 5;
    value = 1;
  }
  
  void show() 
  {
    stroke(255);
    fill(110, 0, 110);
    rect(pos.x, pos.y, size, size);
  }
}
