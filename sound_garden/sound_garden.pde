import ddf.minim.*;
import ddf.minim.ugens.*;
 
Minim       minim;
AudioOutput out;
AudioPlayer[]       pianos;

int numNotes = 10;

void setup()
{ 
  minim = new Minim(this);
 
  // use the getLineOut method of the Minim object to get an AudioOutput object
  out = minim.getLineOut();
 
  // create a sine wave Oscil, set to 440 Hz, at 0.5 amplitude
  String [] notes =  {"c3", "d3", "e3", "g3", "a3", "c4", "d4", "e4", "g4", "a4"};
  
  pianos = new AudioPlayer[numNotes];
  for (int i = 0; i < numNotes; i++) {
    AudioPlayer p = minim.loadFile("sounds/pianos/piano-key-" + notes[i] + ".wav");
    p.rewind();
    pianos[i] = p;
  }
}

void draw() {
  
  int noteCount = int(random(1, 4));
  int r1 = int(random(0, numNotes));
  int r2 = noteCount > 1 ? int(random(0, numNotes)) : -1;
  int r3 = noteCount > 2 ? int(random(0, numNotes)) : -1;


  for (int i = 0; i < numNotes; i++) {
    AudioPlayer p = pianos[i];
    if (i == r1 || i == r2 || i == r3) {
      if (p.isPlaying()) {
        p.rewind();
      } else {
        p.loop(0);
      }
    }
  }
  delay(1500);
}