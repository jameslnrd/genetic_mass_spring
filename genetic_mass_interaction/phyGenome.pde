import java.util.Arrays; //<>//
import java.util.Random;


int MAX_NODES = 10;
int MAX_CONNS = 5;

int MAXDIST_X = 60;
int MAXDIST_Y = 30;

public class phyGenome
{
  public ArrayList<phyGene> genes;
  Random rand = new Random();

  public phyGenome()
  {
    genes = new ArrayList<phyGene>(MAX_NODES);
    for (int i = 0; i < MAX_NODES; i++) {
      genes.add(new phyGene("mass_"+i, MAX_CONNS));
    }
  }

  public phyGenome(phyGenome a)
  {
    genes = new ArrayList<phyGene>(MAX_NODES);
    for (phyGene gene : a.genes) {
      phyGene newGene = new phyGene(gene);
      genes.add(newGene);
    }
  }

  public PVector findCenter()
  {
    // TODO!
    PVector center = new PVector(0, 0);
    return center;
  }

  // choose which genes will be mutated based on mutationProb
  public void mutate(float mutationProb, float mutationAmount)
  {
    for (int i = 0; i < MAX_NODES; i++) {
      if (rand.nextFloat() > 1-mutationProb)
        genes.get(i).mutate(mutationAmount);
    }
  }

  // like mutate(), but with completely random gene prob
  public void evolve(float mutationProb, float randomizeProb, float mutationAmount)
  {
    Random rand = new Random();
    for (int i = 0; i < MAX_NODES; i++) {
      if (rand.nextFloat() < mutationProb)
        genes.get(i).mutate(mutationAmount);
      if (rand.nextFloat() < randomizeProb)
        genes.get(i).randomize();
    }
  }

  //
  public void randomize()
  {
    boolean firstElem = true;
    int posX = 0;
    int posY = 0;
    int j = 0;
    for (phyGene gene : this.genes) {
      if (firstElem) {
        gene.posX = 10;
        gene.posY = 10;
      } else {
        if (rand.nextFloat() < 0.9) {
          gene.posX = j*MAXDIST_X/10;
          gene.posY += 0;
        } else {
          gene.posX = rand.nextInt(MAXDIST_X) - MAXDIST_X/2;
          gene.posY = rand.nextInt(MAXDIST_Y) - MAXDIST_Y/2;
        }
      }

      gene.masValue = firstElem ? 5000 : (1 + rand.nextFloat() * 10);
      gene.K_osc = 0.006 + rand.nextFloat() * 0.0006;
      gene.Z_osc = 0.00001 + rand.nextFloat() * 0.000001;
      gene.K = 0.09 + rand.nextFloat() * 0.009;
      gene.Z = 0.0001 + rand.nextFloat() * 0.00001;
      for (int i=0; i<MAX_CONNS; i++) {
        if (firstElem) {
          continue;
        } else {
          if (rand.nextFloat() < 0.9) {
            gene.conn.add("mass_"+(j-1));
          } else if (rand.nextFloat() < 0.25) {
            gene.conn.add("mass_"+rand.nextInt(j));
          }
        }
        //        if(j > 0 && rand.nextFloat() > 0.5) 
        //          gene.conn[i] = "mass_"+rand.nextInt(j);
        //        if(j > 0 && rand.nextFloat() > 0.75) 
        //          gene.conn[i] = "mass_"+(j-1);
        //        else if(rand.nextFloat() > 0.85)
        //          gene.conn[i] = "mass_0";
      }
      posX = gene.posX;
      posY = gene.posY;
      firstElem = false;
      j++;
    }
  }
}
