/*################################################################################################################
 ##############################            (C) Andres Perez-Lopez, ICAD 2015         ##############################
 ##############################            all wrongs reserved                       ##############################
################################################################################################################*/
  
import oscP5.*;
import netP5.*;
import java.util.Map;

OscP5 oscP5;


PImage image;
int a; 


int ellipseSize = 10;
IntList drawCountry;
IntList times;
int duration = 2000; //ms
int numCountries = 14;
HashMap<Integer,Point> countryLocs = new HashMap<Integer,Point>();
StringList countries = new StringList();

Point loc = new Point(0,0);
int locTime = 0;
int drawLoc = 0;

void setup() 
{
  size(580,408);
  frameRate(4);
  
  oscP5 = new OscP5(this,12000);

  image = loadImage("map_twitter.jpg");
  
  countries.append("DE");
  countries.append("SK");
  countries.append("SI");
  countries.append("HR");
  countries.append("CZ");
  countries.append("FR");
  countries.append("AT");
  countries.append("RO");
  countries.append("CH");
  countries.append("HU");
  countries.append("RS");
  countries.append("PL");
  countries.append("BA");
  countries.append("IT");

  drawCountry = new IntList();
  for (int i = 0; i < numCountries; i = i+1) {
    drawCountry.append(0);
  }
  
  times = new IntList();
  for (int i = 0; i < numCountries; i = i+1) {
    times.append(0);
  }

  countryLocs.put(0,new Point(266,26));
  countryLocs.put(1,new Point(356,174));
  countryLocs.put(2,new Point(296,249));
  countryLocs.put(3,new Point(329,257));
  countryLocs.put(4,new Point(290,111));
  countryLocs.put(5,new Point(17,157));
  countryLocs.put(6,new Point(335,175));
  countryLocs.put(7,new Point(552,301));
  countryLocs.put(8,new Point(140,212));
  countryLocs.put(9,new Point(395,204));
  countryLocs.put(10,new Point(425,292));
  countryLocs.put(11,new Point(439,32));
  countryLocs.put(12,new Point(374,311));
  countryLocs.put(13,new Point(247,380));
}

void draw() 
{
  
  for (int i = 0; i < numCountries; i = i+1) {
     if ((millis() - times.get(i)) > duration) {
       drawCountry.set(i,0);
     };
  };
  if ((millis() - locTime) > duration) {
     drawLoc = 0;
  };
  
  clear();
  image(image,0,0);
  
  fill(255,0,0);  
  for (int i = 0; i < numCountries; i = i+1) {
    if (drawCountry.get(i) == 1) {
      Point p = countryLocs.get(i);
      ellipse(p.x,p.y,ellipseSize,ellipseSize);
    };
  };
  
  fill(255,255,0);
  if (drawLoc == 1) {
    ellipse(loc.x,loc.y,ellipseSize,ellipseSize);
  };
  
}

void oscEvent(OscMessage theOscMessage) {
  String msgType = theOscMessage.addrPattern();
  if (msgType.equals("/cc")) {
    int cc = theOscMessage.get(0).intValue();
    drawCountry.set(cc,1);
    times.set(cc,millis());
    println(cc);    
  };
  if (msgType.equals("/loc")) {
    float x = theOscMessage.get(0).floatValue();
    float y = theOscMessage.get(1).floatValue();
    loc = new Point(int(x*image.width),int(y*image.height));
    locTime = millis();
    drawLoc = 1;
    print(x);
    print(":");
    println(y);   
  };

}

class Point {
  int x, y;
  Point (int newX, int newY) {
    x = newX;
    y = newY; 
  }
}

void mouseClicked() {
    println(mouseX);
    println(mouseY);
}
