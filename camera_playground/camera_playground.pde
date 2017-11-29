/**
 * Much of this comes from the Processing video library
 * example called ColorSorting.
 * Thanks, Ben Fry!
 */
 
import processing.video.*;
import processing.sound.*;
import ddf.minim.*;

RGBColor[] captureColors;
RGBColor[] checkColors;
int[] colorCounts;

Capture cam;
Minim minim;

int[][] soundBoard;

AudioPlayer bass;
AudioPlayer kick;
AudioPlayer snare;
AudioPlayer zing;

int neverPrint = 0;
// How many pixels to skip in either direction
int increment = 5;
// How many colors we have
int numColors = 4;

int kWhite = 0;
int kRed = 1;
int kBlue = 2;
int kGreen = 3;

int kNumZones = 8;
int kNumPitches = 4;

int time;
int currentZone = 0;
int kNoteLength = 500;

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

  minim = new Minim(this);
  soundBoard = new int [kNumZones][kNumPitches]; 
  
  kick = minim.loadFile("sounds/kick.wav");
  snare = minim.loadFile("sounds/snare.wav");
  bass = minim.loadFile("sounds/bass.wav");
  zing = minim.loadFile("sounds/zing.wav");
  
  // Call this last
  time = millis();
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
        captureColors[index].setId(newColor.id);
        
        colorCounts[newColor.id] = colorCounts[newColor.id] + 1;
        index++;
      }
    }
    
    loadPixels();
    
    for (int h = 0; h < cam.height; h++) {
      for (int w = 0; w < cam.width; w++) {
        int pixelVal = h * cam.width + w;
        int colorIndex = h/increment * cam.width/increment + w/increment;
        pixels[pixelVal] = captureColors[colorIndex].kuler();
      }
    }
    
    updatePixels();
    image(cam, 0, 240);
    
    // Check to see if it's time to play music
    if (millis() - time >= kNoteLength) {
      time = millis();
      playNotesInZone(currentZone);
      currentZone = (currentZone+1)%kNumZones;
    }
  }
}


void playNotesInZone(int zone) {
  int totalWidth = cam.width / increment;
  int totalHeight = cam.height / increment;
  int zoneWidth = totalWidth/kNumZones;
  int pitchHeight = totalHeight/kNumPitches;
  
  int pitchIterator = 0;
  for (int j = zone * zoneWidth; j < totalWidth * totalHeight; j += (totalWidth * pitchHeight)) { // For every pitch within that zone
    int[] pitchColors = new int[numColors];
    for (int k = j; k < j + totalWidth * pitchHeight; k += totalWidth) { // For every row within that pitch
      for (int l = k; l < k + zoneWidth; l++) { // Iterate through that row
        pitchColors[captureColors[l].id] = pitchColors[captureColors[l].id] + 1;
      }
    }
    
    int freqColorId = -1;
    int freqColorCount = -1;
    for (int x = 0; x < numColors; x++) {
      if (pitchColors[x] > freqColorCount) {
        freqColorId = x;
        freqColorCount = pitchColors[x];
      }
    }
    
    soundBoard[zone][pitchIterator] = freqColorId;
    pitchIterator++;
  }
  
  printSoundBoard();

  // Time to play some music!!
  int[] pitchArray = soundBoard[zone];
  if(pitchArray[0] > 1) {
    bass.loop(0);
  }
  if(pitchArray[1] > 1) {
    snare.rewind();
    snare.loop(0);
  }
  if(pitchArray[2] > 1) {
    zing.rewind();
    zing.loop(0);
  }
  if(pitchArray[3] > 1) {
    kick.rewind();
    kick.loop(0);
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

void printSoundBoard() {
  // Print the board
  for(int i = 0; i < kNumPitches; i++) {
    for(int j = 0; j < kNumZones; j++) {
      print(soundBoard[j][i]);
      print(" ");
    }
    println();
  }
  println();
}
float distance(RGBColor a, RGBColor b) {
    // LAB distance
    LABColor labA = new LABColor(a);
    LABColor labB = new LABColor(b);  
    return labA.distanceFrom(labB);
    
    // Geometric distance
    //return sqrt(pow(a.r - b.r, 2) + pow(a.g - b.g, 2) + pow(a.b - b.b, 2));
}