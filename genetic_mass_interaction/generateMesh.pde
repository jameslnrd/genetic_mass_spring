import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

Ellipsoid earth;
ArrayList<Ellipsoid> massShapes = new ArrayList<Ellipsoid>();

void generateMesh2(PhysicalModel mdl, double offsX, double offsY, phyGenome genome, String mName, String lName) {
  // OLD ARGS: int dimX, int dimY, String mName, String lName, double masValue, double dist, double K_osc, double Z_osc, double K, double Z
  // add the masses to the model: name, mass, initial pos, init speed
  String masName;
  String solName;
  Vect3D X0, V0;

  // add masses
  for (phyGene gene : genome.genes) {
    // println("generating mass: " + gene.name);
    X0 = new Vect3D(gene.posX+offsX, gene.posY+offsY, 0.0);
    V0 = new Vect3D(0., 0., 0.);
    mdl.addOsc1D(gene.name, gene.masValue, gene.K_osc, gene.Z_osc, X0, V0);
  }

  // add springs
  for (phyGene gene : genome.genes) {
    for (String node2 : gene.conn) {
      if(node2 != null) {
        // println("generating spring: " + gene.name + " " + node2);
        mdl.addSpringDamper1D(gene.name, 0, gene.K, gene.Z, gene.name, node2);
      }
    }
  }
}
