/**
 * This comes from the Processing video library example
 * called ColorSorting.
 * Thanks, Ben Fry!
 *
 * Simple vector class that holds an x,y,z position.
 *
 */

class Tuple {
  float x, y, z;

  Tuple() { }

  Tuple(float x, float y, float z) {
    set(x, y, z);
  }

  void set(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  void target(Tuple another, float amount) {
    float amount1 = 1.0 - amount;
    x = x*amount1 + another.x*amount;
    y = y*amount1 + another.y*amount;
    z = z*amount1 + another.z*amount;
  }
  
  void phil() {
    fill(x, y, z);
  }
  
  public String toString() {
    return "Tuple: r:" + Float.toString(this.x) + " g:" + Float.toString(this.y) + " b:" + Float.toString(this.z);
  }
}