import gab.opencv.*;
import java.util.List;
import javax.activation.MimetypesFileTypeMap;
import java.io.File;
import java.awt.Rectangle;
import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;

private ControlP5 cp5;
ControlFrame cf;

OpenCV full, sprockets;

PFont font;
boolean reset, process, processAll;
String path = "/Users/matthewepler/Documents/myProjects/Kinograph/code_current/kinograph/mm16_frame_extraction_multiple/data/";
String[] files;
int currentFrame;
boolean scrubber;
File dir;

Extractor extractor;
BatchProcessor b;



void setup() {
  getDirectory();
  currentFrame = 1;
  String imageFile = files[ currentFrame + 1 ];
  
  extractor = new Extractor( this, 800, imageFile );
  extractor.setDefaultValues();
  extractor.go();
  
  size( extractor.copy.width * 2, extractor.copy.height + 50 );
  font = loadFont( "HelveticaNeue-Light-16.vlw" );
  textFont( font, 18 );

  initControls();
}


void draw() {
  if ( mouseY > height - 75 ) {
    scrubber = true;
  } 
  else {
    scrubber = false;
  }

  if( !processAll ) {
    background( 50 );
    extractor.display(); 
  } else {
    background( 200, 20 );
    text( "PROCESSING BATCH", 0, 0 );
  }
}


// ============================================================= MOUSE RELEASED ========= //
void mouseReleased() {
  if ( !scrubber ) {
    if ( !extractor.roiSet ) {
      extractor.roiSet = true;
    } 
  } 
  else { // we're in scrubber and don't want to reload until we've let go
    if ( currentFrame > 0 ) {
      extractor.roiSet = true;
      extractor.sprocketSet = false;
      extractor.reload( files[ currentFrame - 1 ] );
    }
  }
}


// ============================================================= INIT CONTROLS ========= //
void initControls() {
  cp5 = new ControlP5( this );
  cf = addControlFrame( "Controls", 225, 900, 0, 0 );
  
  controlP5.Slider scrubber = cp5.addSlider( "scrubber" );
  scrubber.setValue( currentFrame );
  scrubber.setPosition( 75, height- 40 ).setSize( width - 100, 20 );
  scrubber.setRange( 1, files.length - 1 );
  scrubber.setNumberOfTickMarks( 24 );
  scrubber.setDefaultValue( files.length/2 );
  scrubber.snapToTickMarks( false );
  scrubber.setSliderMode(Slider.FLEXIBLE);
  scrubber.setValueLabel( "File " + currentFrame + " of " + (files.length-1) );
  scrubber.setCaptionLabel( "" );
}


// ============================================================= CONTROL FRAME ========= //
ControlFrame addControlFrame(String theName, int theWidth, int theHeight, int locX, int locY ) {
  Frame f = new Frame(theName);
  ControlFrame p = new ControlFrame(this, theWidth, theHeight);
  f.add(p);
  p.init();
  f.setTitle(theName);
  f.setSize(p.w, p.h);
  f.setLocation( locX, locY );
  f.setResizable(false);
  f.setVisible(true);
  return p;
}

void scrubber( int value )
{
  currentFrame = value;
  controlP5.Controller s = cp5.getController( "scrubber" );
  s.setValueLabel( "File " + currentFrame + " of " + (files.length - 1) );
}

void getDirectory() {
  dir = new File( path );

  if ( dir.isDirectory() )
  {
    files = dir.list();
    String success = "Directory \'" + dir.getName() + "\' loaded successfully.";
    println( success );
  } 
  else
  {
    String fail = "Failed to load directory. Please verify the path string.";
    fail += "\n";
    fail += "Path = " + path;
    println( fail );
    exit();
  }
}

void reset() {
  extractor = new Extractor( this, 800, files[ files.length/2 ] ); 
  extractor.setDefaultValues();
  extractor.go();
}

void processAll() {
  processAll = true;
  b = new BatchProcessor( this, dir, extractor );
  b.process();
  processAll = false;
}

