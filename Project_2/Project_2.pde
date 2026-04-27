final static float MOVE_SPEED = 5;
final static float SPRITE_SCALE = 50.0/128;
final static float SPRITE_SIZE = 50;
final static float GRAVITY = .6;
final static float GRAVX = .5;
final static float JUMP_SPEED = 12;

final static float RIGHT_MARGIN = 100;
final static float LEFT_MARGIN = 100;
final static float VERTICAL_MARGIN = 150;
final static float TOP_MARGIN = 400;

final static float CHECKPOINT_BOUNDS = 25;

final static int NEUTRAL_FACING = 0;
final static int RIGHT_FACING = 1;
final static int LEFT_FACING = 2;

Sprite pa;
Player p;
PImage grass, dirt, slope, test;

ArrayList<Sprite> platforms, background;
ArrayList<Checkpoint> checkpoints;

float view_x = 0;
float view_y = 0;

void setup()
{
  size(1600, 900);

  imageMode(CENTER);
  test = loadImage("player.png");
  //p = new Sprite(test, 1);
  p = new Player(test, 0.8);
  platforms = new ArrayList<Sprite>();
  background = new ArrayList<Sprite>();
  checkpoints = new ArrayList<Checkpoint>();

  grass = loadImage("grass_block_side.png");
  dirt = loadImage("dirt.png");
  slope = loadImage("slope.png");
 
  createPlatforms("map.csv");
}

void createPlatforms(String filename)
{
  String[] lines = loadStrings(filename);
  for (int row = 0; row < lines.length; row++)
  {
    String[] values = split(lines[row], ",");
    for (int col = 0; col < values.length; col++)
    {
      int isBlock = 0;
      PImage block = grass;
      float block_scale = 1;


      if (values[col].equals("1"))
      {
        block = grass;
        block_scale = SPRITE_SCALE;
        isBlock = 1;
      }
      
      else if (values[col].equals("2"))
      {
        block = dirt;
        block_scale = SPRITE_SCALE;
        isBlock = 1;
      }
     
      if (block != null && isBlock == 1)
      {


        Sprite s = new Sprite(block, block_scale);
        s.center_x = SPRITE_SIZE / 2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE / 2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      if (block != null && isBlock == 2)
      {
        Sprite s = new Sprite(block, block_scale);
        s.center_x = SPRITE_SIZE / 2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE / 2 + row * SPRITE_SIZE;
        background.add(s);
      }
      
      
      
    }
  }
}

void draw()
{
  background(155);
  scroll();
  // Horizontal movement with acceleration
  if (left && !right) {
    p.change_x -= GRAVX;
  } else if (right && !left) {
    p.change_x += GRAVX;
  } else {
    // friction (slow down when no input)
    if (isOnPlatforms(p, platforms))
      p.change_x *= 0.8;
  }

  // clamp max speed
  p.change_x = constrain(p.change_x, -MOVE_SPEED, MOVE_SPEED);
  println(p.center_x + " " + p.center_y);


  
  for (Sprite s : background)
    s.display();
  p.display();
  p.updateAnimation();
  resolvePlatformCollisions(p, platforms);

  checkCheckpoints();


  for (Sprite s : platforms)
    s.display();
    
     
}

void checkCheckpoints()
{
  if(checkpoints != null)
  {
  for (Checkpoint cp : checkpoints)
  {
    if (cp.isPlayerInside(p.center_x, p.center_y))
    {
      cp.teleportPlayer(p);
      break;
    }
  }
  }
}

//void checkPointCheck()
//  {
//      for(int i = 0; i < checkPointXY.get(0).size(); i++)
//      {
//        //println(checkPointXY.get(0).get(i) + " " + checkPointXY.get(1).get(i));
//          if((p.center_x > checkPointXY.get(0).get(i) - CHECKPOINT_BOUNDS) && p.center_x < checkPointXY.get(0).get(i) + CHECKPOINT_BOUNDS && p.center_y > checkPointXY.get(1).get(i) - CHECKPOINT_BOUNDS  && p.center_y < checkPointXY.get(1).get(i) + CHECKPOINT_BOUNDS)
//          {
//              p.center_x = endPointXY.get(0).get(i);
//              p.center_y = endPointXY.get(1).get(i);
//             //println("checked"); 
//        }
//      }
//  }

void scroll()
{
  float right_boundary = view_x + width - RIGHT_MARGIN;
  if (p.getRight() > right_boundary)
  {
    view_x += p.getRight() - right_boundary;
  }
  float left_boundary = view_x + LEFT_MARGIN;
  if (p.getLeft() < left_boundary)
  {
    view_x -= left_boundary - p.getLeft();
  }
  float bottom_boundary = view_y + height - VERTICAL_MARGIN;
  if (p.getBottom() > bottom_boundary)
  {
    view_y += p.getBottom() - bottom_boundary;
  }
  float top_boundary = view_y + TOP_MARGIN;
  if (p.getTop() < top_boundary)
  {
    view_y -= top_boundary - p.getTop();
  }
  translate(-view_x, - view_y);
}

boolean checkCollision(Sprite s1, Sprite s2)
{
  boolean noXOverlap = s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight();
  boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
  if (noXOverlap || noYOverlap)
  {
    return false;
  } else
  {
    return true;
  }
}

public ArrayList<Sprite> checkCollisionList (Sprite s, ArrayList<Sprite> list)
{
  ArrayList<Sprite> collision_list = new ArrayList<Sprite>();
  for (Sprite p : list)
  {
    if (checkCollision(s, p))
      collision_list.add(p);
  }
  return collision_list;
}

public boolean isOnPlatforms(Sprite s, ArrayList<Sprite> walls)
{
  s.center_y += 5;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  s.center_y -=5;
  if (col_list.size() > 0)
  {
    return true;
  } else
    return false;
}

public void resolvePlatformCollisions(Sprite s, ArrayList<Sprite> walls)
{
  s.change_y += GRAVITY;

  s.center_y += s.change_y;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  if (col_list.size() > 0)
  {
    Sprite collided = col_list.get(0);
    if (s.change_y > 0)
    {
      s.setBottom(collided.getTop());
    } else if (s.change_y < 0)
    {
      s.setTop(collided.getBottom());
    }
    s.change_y = 0;
  }

  s.center_x += s.change_x;
  col_list = checkCollisionList(s, walls);
  if (col_list.size() > 0)
  {
    Sprite collided = col_list.get(0);
    if (s.change_x > 0)
    {
      s.setRight(collided.getLeft());
      s.change_x = 0;
    } else if (s.change_x < 0)
    {
      s.setLeft(collided.getRight());
      s.change_x = 0;
    }
  }
}

boolean left = false;
boolean right = false;
boolean up = false;
boolean down = false;

void keyPressed() {
  if (keyCode == LEFT)  left = true;
  if (keyCode == RIGHT) right = true;
  if (keyCode == UP && isOnPlatforms(p, platforms))
  {
    p.change_y = -JUMP_SPEED;
  }
  if (keyCode == DOWN) down = true;
}

void keyReleased() {
  if (keyCode == LEFT)  left = false;
  if (keyCode == RIGHT) right = false;
  if (keyCode == UP) up = false;
  if (keyCode == DOWN) down = false;
}
