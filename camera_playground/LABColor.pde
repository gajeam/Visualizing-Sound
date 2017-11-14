/**
 * This comes from the Processing video library example
 * called ColorSorting.
 * Thanks, Ben Fry!
 *
 * Simple vector class that holds an x,y,z position.
 *
 */

class LABColor {
  float l, a, b;
  int id;

  LABColor() {
    this.id = -1;
  }

  LABColor(float x, float y, float z) {
    set(l, a, b);
  }

  LABColor(RGBColor rgbColor) {
    this.id = -1;
    float var_R = ( rgbColor.r / 255. );
    float var_G = ( rgbColor.g / 255. );
    float var_B = ( rgbColor.b / 255. );
    
    
    if ( var_R > 0.04045 ) var_R = pow((( var_R + 0.055 ) / 1.055 ), 2.4);
    else                   var_R = var_R / 12.92;
    if ( var_G > 0.04045 ) var_G = pow((( var_G + 0.055 ) / 1.055 ), 2.4);
    else                   var_G = var_G / 12.92;
    if ( var_B > 0.04045 ) var_B = pow((( var_B + 0.055 ) / 1.055 ), 2.4);
    else                   var_B = var_B / 12.92;
    
    var_R = var_R * 100.;
    var_G = var_G * 100.;
    var_B = var_B * 100.;
    
    float X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805;
    float Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722;
    float Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505;
    
    float ReferenceX = 95.047;
    float ReferenceY = 100.000;
    float ReferenceZ = 108.883;
    
    float var_X = X / ReferenceX;
    float var_Y = Y / ReferenceY;
    float var_Z = Z / ReferenceZ;
    
    if ( var_X > 0.008856 ) var_X = pow(var_X, ( 1./3. ));
    else                    var_X = ( 7.787 * var_X ) + ( 16. / 116. );
    if ( var_Y > 0.008856 ) var_Y = pow(var_Y, ( 1./3.));
    else                    var_Y = ( 7.787 * var_Y ) + ( 16. / 116. );
    if ( var_Z > 0.008856 ) var_Z = pow(var_Z, ( 1./3. ));
    else                    var_Z = ( 7.787 * var_Z ) + ( 16. / 116. );
    
    this.l = (116. * var_Y) - 16.;
    this.a = 500. * ( var_X - var_Y );
    this.b = 200. * ( var_Y - var_Z );
  }
  
  void set(float x, float y, float z) {
    this.l = x;
    this.a = y;
    this.b = z;
  }
  
  void setId(int id) {
    this.id = id;
  }
  
  float distanceFrom(LABColor otherColor) {
    return sqrt(pow(this.l - otherColor.l, 2) + pow(this.a - otherColor.a, 2) + pow(this.b - otherColor.b, 2));
      //return abs(this.l - otherColor.l) + abs(this.a - otherColor.a) + abs(this.b - otherColor.b);
        
  }
  
  public String toString() {
    return "LAB l:" + Float.toString(this.l) + " a:" + Float.toString(this.a) + " b:" + Float.toString(this.b);
  }
}