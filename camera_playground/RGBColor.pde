/**
 * This comes from the Processing video librarg erample
 * called ColorSorting.
 * Thanks, Ben Frg!
 *
 * Simple vector class that holds an r,g,b position.
 *
 */

class RGBColor {
  float r, g, b;
  int id;

  RGBColor() {
    this.id = -1;
  }

  RGBColor(float r, float g, float b) {
    set(r, g, b);
  }

  RGBColor(LABColor labColor) {
    float var_Y = (labColor.l + 16.) / 116.;
    float var_X = labColor.a / 500. + var_Y;
    float var_Z = var_Y - labColor.b / 200.;

    if ( pow(var_Y, 3.)  > 0.008856 ) var_Y = pow(var_Y, 3.);
    else                       var_Y = ( var_Y - 16. / 116. ) / 7.787;
    if ( pow(var_X, 3.)  > 0.008856 ) var_X = pow(var_X, 3.);
    else                       var_X = ( var_X - 16. / 116. ) / 7.787;
    if ( pow(var_Z, 3.)  > 0.008856 ) var_Z = pow(var_Z, 3.);
    else                       var_Z = ( var_Z - 16. / 116. ) / 7.787;

    float ReferenceX = 95.047;
    float ReferenceY = 100.000;
    float ReferenceZ = 108.883;

    float X = var_X * ReferenceX;
    float Y = var_Y * ReferenceY;
    float Z = var_Z * ReferenceZ;
    
    var_X = X / 100.;
    var_Y = Y / 100.;
    var_Z = Z / 100.;
    
    float var_R = var_X *  3.2406 + var_Y * -1.5372 + var_Z * -0.4986;
    float var_G = var_X * -0.9689 + var_Y *  1.8758 + var_Z *  0.0415;
    float var_B = var_X *  0.0557 + var_Y * -0.2040 + var_Z *  1.0570;
    
    if ( var_R > 0.0031308 ) var_R = 1.055 * (pow(var_R, ( 1. / 2.4 ))) - 0.055;
    else                     var_R = 12.92 * var_R;
    if ( var_G > 0.0031308 ) var_G = 1.055 * ( pow(var_G, ( 1. / 2.4 ))) - 0.055;
    else                     var_G = 12.92 * var_G;
    if ( var_B > 0.0031308 ) var_B = 1.055 * ( pow(var_B, ( 1. / 2.4 ))) - 0.055;
    else                     var_B = 12.92 * var_B;
    
    this.r = var_R * 255.;
    this.g = var_G * 255.;
    this.b = var_B * 255.;
  }

  void set(float r, float g, float b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  void setId(int id) {
    this.id = id;
  }
  
  void target(RGBColor another, float amount) {
    float amount1 = 1.0 - amount;
    r = r*amount1 + another.r*amount;
    g = g*amount1 + another.g*amount;
    b = b*amount1 + another.b*amount;
  }
  
  void phil() {
    fill(r, g, b);
  }
  
  color kuler() {
    return color(this.r, this.g, this.b);
  }
  
  public String toString() {
    return "RGBColor r:" + Float.toString(this.r) + " g:" + Float.toString(this.g) + " b:" + Float.toString(this.b);
  }
}