/**
 * Much of this comes from the Processing video library
 * example called ColorSorting.
 * Thanks, Ben Fry!
 */
 
import processing.video.*;
import processing.sound.*;

RGBColor[] captureColors;
RGBColor[] checkColors;
int[] colorCounts;

Capture cam;

TriOsc[] tones;

// How many pixels to skip in either direction
int increment = 5;
// How many colors we have
int numColors = 4;

int kWhite = 0;
int kRed = 1;
int kBlue = 2;
int kGreen = 3;

void setup() {
  size(320, 480);
  cam = new Capture(this, 320, 240);
  cam.start();
  
  int count = (cam.width * cam.height) / (increment * increment);
  captureColors = new RGBColor[count];
  for (int i = 0; i < count; i++) {
    captureColors[i] = new RGBColor();
  }
  
  // Add the initial pixels we're going to compare to
  float whiteVal = 145.; // Max value: 255
  checkColors = new RGBColor[numColors];
  colorCounts = new int[numColors];
  
  checkColors[kWhite] = new RGBColor(whiteVal, whiteVal, whiteVal);
  checkColors[kRed] = new RGBColor(128., 53. , 146.);
  checkColors[kBlue] = new RGBColor(37., 96. , 133.);
  checkColors[kGreen] = new RGBColor(137., 164. , 63.);

  tones = new TriOsc[numColors];
  for (int i = 0; i < numColors; i++) {
    tones[i] = new TriOsc(this);
  }

  
  RGBColor white = new RGBColor(50., 100., 200.);
  println(white);
  LABColor labWhite = new LABColor(white);
  println(labWhite);
  RGBColor rgbWhite = new RGBColor(labWhite);
  println(rgbWhite);
}

void draw() {
  if(cam.available()) {
    cam.read();
    cam.loadPixels();

    background(0);
    noStroke();
    
    // Reset colors
    for (int i = 0; i < colorCounts.length; i++) {
      colorCounts[i] = 0;
    }
    
    // Capture all the colors and put them into an array
    int index = 0;
    for (int j = 0; j < cam.height; j += increment) {
      for (int i = 0; i < cam.width; i += increment) {
        int pixelColor = cam.pixels[j*cam.width + i];

        int r = (pixelColor >> 16) & 0xff;
        int g = (pixelColor >> 8) & 0xff;
        int b = pixelColor & 0xff;
        
        RGBColor newColor = new RGBColor(r, g, b);
        newColor = nearestColor(newColor);
        captureColors[index].set(newColor.r, newColor.g, newColor.b);
        
        colorCounts[newColor.id] = colorCounts[newColor.id] + 1; 
        index++;
      }
    }
    
    loadPixels();
    
    for (int h = 0; h < cam.height; h++) {
      for (int w = 0; w < cam.width; w++) {
        int pixelVal = h * cam.width + w;
        int colorIndex = h/increment * cam.width/increment + w/increment;
        pixels[pixelVal] = captureColors[colorIndex].kuler();;
      }
    }
    
    updatePixels();
    image(cam, 0, 240);
    
    // Map amount of red for amplitude
    tri.amp(map(colorCounts[kRed], 0, index, 1.0, 0.0));
    // Map amount of blue to frequency (20Hz to 1000Hz)  
    tri.freq(map(colorCounts[kBlue], 0, index, 80.0, 1000.0));
  }
}

RGBColor nearestColor(RGBColor input) {
  RGBColor nearestColor = checkColors[0];
  float nearestDistance = Float.MAX_VALUE;
  for (int i = 0; i < checkColors.length; i++) {
    if (distance(input, checkColors[i]) < nearestDistance) {
      nearestColor = checkColors[i];
      nearestColor.setId(i);
      nearestDistance = distance(input, checkColors[i]);
    }
  }
  return nearestColor;
}

public float distance(RGBColor a, RGBColor b) {
    // LAB distance
    LABColor labA = new LABColor(a);
    LABColor labB = new LABColor(b);  
    return labA.distanceFrom(labB);
    
    // Geometric distance
    //return sqrt(pow(a.r - b.r, 2) + pow(a.g - b.g, 2) + pow(a.b - b.b, 2));
}