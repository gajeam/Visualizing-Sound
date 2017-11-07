/**
 * Much of this comes from the Processing video library
 * example called ColorSorting.
 * Thanks, Ben Fry!
 */
 
import processing.video.*;

Tuple[] captureColors;
Tuple[] drawColors;
Tuple[] checkColors;

Capture cam;

// How many pixels to skip in either direction
int increment = 5;
// Use this to increase the size of the video
int sizeFactor = 1;
void setup() {
  size(230, 480);
  cam = new Capture(this, 320, 240);
  cam.start();
  
  int count = (cam.width * cam.height) / (increment * increment);
  drawColors = new Tuple[count];
  captureColors = new Tuple[count];
  for (int i = 0; i < count; i++) {
    captureColors[i] = new Tuple();
    drawColors[i] = new Tuple(0.5, 0.5, 0.5);
  }
  
  // Add the initial pixels we're going to compare to
  checkColors = new Tuple[3];
  checkColors[0] = new Tuple(190., 190., 190.);  // White, or some gray
  checkColors[1] = new Tuple(255., 0. , 0.);     // Red
  checkColors[2] = new Tuple(0., 0. , 255.);     // Blue
}

void draw() {
  if(cam.available()) {
    cam.read();
    cam.loadPixels();

    background(0);
    noStroke();
    
    // Capture all the colors and put them into an array
    int index = 0;
    for (int j = 0; j < cam.height; j += increment) {
      for (int i = 0; i < cam.width; i += increment) {
        int pixelColor = cam.pixels[j*cam.width + i];

        int r = (pixelColor >> 16) & 0xff;
        int g = (pixelColor >> 8) & 0xff;
        int b = pixelColor & 0xff;
        
        Tuple testTuple = new Tuple(r, g, b);
        testTuple = nearestColor(testTuple);

        captureColors[index].set(testTuple.x, testTuple.y, testTuple.z);
        
        // Get the closest color
        
        index++;
      }
    }
    image(cam, 0, 0);
    
    
    beginShape(QUAD_STRIP);
    for (int i = 0; i < index; i++) {
      //drawColors[i].target(captureColors[i], 0.1);
      captureColors[i].phil();

      float x = map(i, 0, index, 0, width);
      vertex(x, height/2.0);
      vertex(x, height);
    }
    endShape();
  }
}

Tuple nearestColor(Tuple input) {
  Tuple nearestColor = checkColors[0];
  float nearestDistance = Float.MAX_VALUE;
  for (int i = 0; i < checkColors.length; i++) {
    if (distance(input, checkColors[i]) < nearestDistance) {
      nearestColor = checkColors[i];
      nearestDistance = distance(input, checkColors[i]);
    }
  }
  return nearestColor;
}

public float distance(Tuple a, Tuple b) {
  // Geometric distance
    //return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2) + pow(a.z - b.z, 2));
  // Absolute distance
    return abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z);

}