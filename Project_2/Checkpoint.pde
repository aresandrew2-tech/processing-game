class Checkpoint
{
  float x, y;        // trigger area
  float targetX, targetY; // teleport destination
  float size;

  Checkpoint(float x, float y, float targetX, float targetY, float size)
  {
    this.x = x;
    this.y = y;
    this.targetX = targetX;
    this.targetY = targetY;
    this.size = size;
  }

  boolean isPlayerInside(float px, float py)
  {
    return px > x - size && px < x + size &&
           py > y - size && py < y + size;
  }

  void teleportPlayer(Sprite p)
  {
    p.center_x = targetX;
    p.center_y = targetY;
  }
}
