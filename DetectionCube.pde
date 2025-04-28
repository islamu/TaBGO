import java.util.ArrayList;
import java.util.List;
import java.util.Collections;
import java.util.Comparator;
class DetectionCube {
  List<Cube> mesCubes;
  List<Point> mesPoints;
  OCRProcessor ocrProcessor;
  private color maCouleur;
  private PImage imageSource;
  private int taille = 150;

  DetectionCube(PImage src) {
    mesCubes = new ArrayList<Cube>();
    mesPoints = new ArrayList<Point>();
    ocrProcessor = new OCRProcessor();
    maCouleur = color(68, 101, 126);
    imageSource = src;
    recherche();
    trie();
  }

  List<Cube> getListCubes() {
    return mesCubes;
  }

  void recherche() {
    mesPoints = cherchePoint(imageSource, maCouleur);
    for (Point p : mesPoints) {
      p.pointMoyen = p.calculPointMoyen(p.mesPixels);
    }
    mesCubes = chercheCube(mesPoints, taille - 150, taille + 150);
    for (Cube monCube : mesCubes) {
      monCube.setCharacter(ocrProcessor.recognizeText(monCube.getImage(imageSource)));
    }
  }

  void trie() {
    Collections.sort(mesCubes, new Comparator<Cube>() {
      @Override
      public int compare(Cube c1, Cube c2) {
        if (c1.c.y != c2.c.y) {
          return Float.compare(c1.c.y, c2.c.y);
        }
        return Float.compare(c1.c.x, c2.c.x);
      }
    });
  }

  List<Point> cherchePoint(PImage source, color coul) {
    List<Point> points = new ArrayList<Point>();
    source.loadPixels();
    for (int y = 0; y < source.height; y++) {
      for (int x = 0; x < source.width; x++) {
        color c = source.pixels[x + y * source.width];
        if (isNearCouleur(c, coul)) {
          boolean trouve = false;
          for (Point p : points) {
            if (p.isNear(x, y)) {
              p.add(new PixelScore(x, y, scoreCouleur(c, coul)));
              trouve = true;
              break;
            }
          }
          if (!trouve) {
            Point p = new Point();
            p.add(new PixelScore(x, y, scoreCouleur(c, coul)));
            points.add(p);
          }
        }
      }
    }
    return points;
  }

  List<Cube> chercheCube(List<Point> points, int min, int max) {
    List<Cube> cubes = new ArrayList<Cube>();
    for (int i = 0; i < points.size(); i++) {
      for (int j = i + 1; j < points.size(); j++) {
        for (int k = j + 1; k < points.size(); k++) {
          for (int l = k + 1; l < points.size(); l++) {
            Cube c = new Cube(points.get(i).pointMoyen, points.get(j).pointMoyen, points.get(k).pointMoyen, points.get(l).pointMoyen);
            if (c.estValide(imageSource)) {
              float d = dist(c.min.x, c.min.y, c.max.x, c.max.y);
              if (d >= min && d <= max) {
                boolean add = true;
                for (Cube cube : cubes) {
                  if (dist(cube.c.x, cube.c.y, c.c.x, c.c.y) <= 10) {
                    add = false;
                    break;
                  }
                }
                if (add) {
                  cubes.add(c);
                }
              }
            }
          }
        }
      }
    }
    return cubes;
  }

  boolean isNearCouleur(color c1, color c2) {
    float r1 = red(c1), g1 = green(c1), b1 = blue(c1);
    float r2 = red(c2), g2 = green(c2), b2 = blue(c2);
    float seuil = 10;
    return (r1 >= (r2 - seuil) && r1 <= (r2 + seuil) && g1 >= (g2 - seuil) && g1 <= (g2 + seuil) && b1 >= (b2 - seuil) && b1 <= (b2 + seuil));
  }

  float scoreCouleur(color c1, color c2) {
    float r1 = red(c1), g1 = green(c1), b1 = blue(c1);
    float r2 = red(c2), g2 = green(c2), b2 = blue(c2);
    return sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2));
  }
}
