import java.util.Arrays;
import ddf.minim.UGen;

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

import miPhysics.*;

int dimX = 25;
int dimY = 25;

float m = 1.0;
float k = 0.2;
float z = 0.0001;
float dist = 25;
float z_tension = 25;
float fric = 0.00001;
float grav = 0.;

int listeningPoint = 15;
int excitationPoint = 10;

int maxListeningPt;

public class PhyUGen extends UGen
{
  
  private String listeningPoint;

  private float oneOverSampleRate;
  public int center_x;
  public int center_y;
  public phyGenome genome;
  PApplet app;
  private ArrayList<Ellipsoid> massShapes = new ArrayList<Ellipsoid>();
  private float zZoom = 1;


  PhysicalModel mdl;

  // strat with ony one constructor for the function.
  public PhyUGen(PApplet app, int sampleRate, phyGenome genome, double offsX, double offsY)
  {
    super();
    // TODO use findCenter
    this.center_x = (int)offsX;
    this.center_y = (int)offsY;
    this.genome = genome;
    this.app = app;
    
    this.mdl = new PhysicalModel(sampleRate, displayRate);
    mdl.setGravity(0.000);
    mdl.setFriction(fric);

    generateMesh2(mdl, offsX, offsY, genome, "osc", "spring");

    listeningPoint = "mass_5";

    this.mdl.init();
  }

  /**
   * This routine will be called any time the sample rate changes.
   */
  protected void sampleRateChanged()
  {
    oneOverSampleRate = 1 / sampleRate();
    this.mdl.setSimRate((int)sampleRate());
  }

  @Override
  protected void uGenerate(float[] channels)
  {
    float sample;
    synchronized(lock) {
      this.mdl.computeStep();
  
      // calculate the sample value
      if(this.mdl.matExists(listeningPoint)) {
        sample =(float)(this.mdl.getMatPosition(listeningPoint).z * 0.01);
      } else {
        sample = 0;
      }
      Arrays.fill(channels, sample);
    }
  }
  
  void drawLine(Vect3D pos1, Vect3D pos2) {
    line((float)pos1.x, 
         (float)pos1.y, 
         zZoom *(float)pos1.z, 
         (float)pos2.x, 
         (float)pos2.y, 
         zZoom * (float)pos2.z);
  }
  
  void renderLinks(int r, int g, int b){
    for( int i = 0; i < (mdl.getNumberOfLinks()); i++){
      switch (mdl.getLinkTypeAt(i)){
        case SpringDamper1D:
          strokeWeight(2);
          stroke(r, g, b);
          // strokeWeight(mdl.getLinkDampingAt(i));
          drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
          break;
        case UNDEFINED:
          break;
      }
    }
  }
  
  void addColoredShape(PVector pos, color col, float size) {
    Ellipsoid tmp = new Ellipsoid(app, 20, 20);
    tmp.setRadius(size);
    tmp.moveTo(pos.x, pos.y, pos.z);
    tmp.strokeWeight(0);
    tmp.fill(col);
    tmp.tag = "";
    tmp.drawMode(Shape3D.TEXTURE);
    massShapes.add(tmp);
  }

  void createShapeArray() {
    for ( int i = 0; i < mdl.getNumberOfMats(); i++) {
      switch (mdl.getMatTypeAt(i)) {
      case Mass3D:
        addColoredShape(mdl.getMatPosAt(i).toPVector(), color(120, 120, 0), 40);
        break;
      case Mass2DPlane:
        addColoredShape(mdl.getMatPosAt(i).toPVector(), color(120, 0, 120), 10);
        break;
      case Ground3D:
        addColoredShape(mdl.getMatPosAt(i).toPVector(), color(30, 100, 100), 25);
        break; 
      case HapticInput3D:
        addColoredShape(mdl.getMatPosAt(i).toPVector(), color(255, 10, 10), 40);
        break; 
      case Osc1D:
        addColoredShape(mdl.getMatPosAt(i).toPVector(), color(30, 0, 230), 6);
        break;
      case UNDEFINED:
        break;
      }
    }
  }


  void renderModelShapes() {
    PVector v;
    synchronized(lock) { 
      for ( int i = 0; i < mdl.getNumberOfMats(); i++) {
        v = mdl.getMatPosAt(i).toPVector().mult(100.);
        massShapes.get(i).moveTo(v.x, v.y, v.z);
      }
  
  
      for ( int i = 0; i < mdl.getNumberOfLinks(); i++) {
        switch (mdl.getLinkTypeAt(i)) {
        case Spring3D:
          stroke(0, 255, 0);
          drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
          break;
        case Damper3D:
          stroke(125, 125, 125);
          drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
          break; 
        case SpringDamper3D:
          stroke(0, 0, 255);
          drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
          break;
        case Rope3D:
          stroke(210, 235, 110);
          drawLine(mdl.getLinkPos1At(i), mdl.getLinkPos2At(i));
          break;
        case Contact3D:
          break; 
        case PlaneContact3D:
          break;
        case UNDEFINED:
          println("a");
          break;
        }
      }
    }
    for (Ellipsoid massShape : massShapes)
      massShape.draw();
  }
}
