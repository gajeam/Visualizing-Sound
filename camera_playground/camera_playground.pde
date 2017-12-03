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

AudioPlayer[] pianos;
AudioPlayer[] psalteriums;
AudioPlayer[] drums;

int neverPrint = 0;
// How many pixels to skip in either direction
int increment = 4;
// How many colors we have
int numColors = 5;
int kMinimumColorThreshold = 3;

int kWhite = 0;
int kRed = 1;
int kBlue = 2;
int kGreen = 3;
int kSkin = 4;

int kPianoColor = kBlue;
int kPsalteriumColor = kRed;
int kDrumsColor = kGreen;

int kNumZones = 8;
int kNumPitches = 10;

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
  checkColors[kRed] = new RGBColor(77., 28. , 24.);
  checkColors[kBlue] = new RGBColor(9., 20. , 79.);
  checkColors[kGreen] = new RGBColor(53., 74. , 70.);
  checkColors[kSkin] = new RGBColor(190., 132., 96);

  minim = new Minim(this);
  soundBoard = new int [kNumZones][kNumPitches]; 
  
  String [] pianoNotes =  {"c3", "d2", "e3", "a2", "g3",  "c5", "d5", "e5", "g5", "a5"}; // pentatonic scale
  String [] pslateriumNotes =  {"c3", "d3", "e3", "a3", "g2", "c4", "d4", "e4", "g4", "a4"}; // pentatonic scale
  String [] drumSounds = {"tom5", "tom5", "percussion2", "percussion2", "crash-cymbal1", "crash-cymbal1", "ride-cymbal1", "ride-cymbal1", "misc1", "misc1"};
  pianos = new AudioPlayer[kNumPitches];
  psalteriums = new AudioPlayer[kNumPitches];
  drums = new AudioPlayer[kNumPitches];
  for (int i = 0; i < kNumPitches; i++) {
    AudioPlayer pi = minim.loadFile("sounds/pianos/piano-key-" + pianoNotes[i] + ".wav");
    pi.rewind();
    pianos[i] = pi;
    
    AudioPlayer ps = minim.loadFile("sounds/psalterium/psalterium-" + pslateriumNotes[i] + ".wav");
    ps.rewind();
    psalteriums[i] = ps;
    
    AudioPlayer d = minim.loadFile("sounds/drums/" + drumSounds[i] + ".wav");
    d.rewind();
    drums[i] = d;
  }
  
  // Call this last
  time = millis();
  
  playChordForColor(kPianoColor);
  playChordForColor(kPsalteriumColor);
  playChordForColor(kDrumsColor);
  delay(100);
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
      if (time%10 == 0) {
        println("TADA!");
        playChordForColor(kPianoColor);
      }
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
    
    int freqColorId = kWhite; // default should be white
    int freqColorCount = kMinimumColorThreshold; // it has to beat this minimum
    for (int x = 1; x < numColors; x++) { // start iterating after white
      if (pitchColors[x] > freqColorCount) {
        freqColorId = x;
        freqColorCount = pitchColors[x];
      }
    }
    
    soundBoard[zone][pitchIterator] = freqColorId;
    pitchIterator++;
  }
  
  printSoundBoard();

   //Time to play some music!!
  int[] pitchArray = soundBoard[zone];
  for (int i = 0; i < kNumPitches; i++) {
    AudioPlayer[] instrument = pitchArrayForColor(pitchArray[i]);
    if (instrument != null) {
      AudioPlayer p = instrument[i];
      if (p.isPlaying()) {
        p.rewind();
      } else {
        p.loop(0);
      }
    }
  }
}
  
void playChordForColor(int kuler) {
  // pause everything else
  int[] colors = {kPianoColor, kPsalteriumColor, kDrumsColor};
  for (int i = 0; i < 3; i++) {
    AudioPlayer[] inst = pitchArrayForColor(colors[i]);
    for (int j = 0; j < kNumPitches; j++) {
      inst[j].rewind();
      inst[j].pause();
    }
  }
  
  // play the sound
  AudioPlayer[] instrument = pitchArrayForColor(kuler);
  instrument[2].loop(0);
  delay(200);
  instrument[0].loop(0);
  delay(400);
  instrument[4].loop(0);
  delay(500);
}

AudioPlayer[] pitchArrayForColor(int kuler) {
  if (kuler == kPianoColor) {
    return pianos;
  } else if (kuler == kPsalteriumColor) {
    return psalteriums; 
  } else if (kuler == kDrumsColor) {
    return drums;
  }
  return null;
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