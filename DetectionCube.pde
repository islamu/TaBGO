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
    // Pseudocode:
    // INITIALISER les listes mesCubes et mesPoints
    // CRÉER une instance de OCRProcessor
    // DÉFINIR la couleur cible (maCouleur)
    // ASSIGNER l'image source
    // EXÉCUTER recherche()
    // EXÉCUTER trie()
    mesCubes = new ArrayList<Cube>();
    mesPoints = new ArrayList<Point>();
    ocrProcessor = new OCRProcessor();
    maCouleur = color(68, 101, 126);
    imageSource = src;
    recherche();
    trie();
  }

  void recherche() {
    // Pseudocode:
    // TROUVER les points dans l'image correspondant à maCouleur
    // POUR chaque point
    //     CALCULER son point moyen
    // FINPOUR
    // CRÉER des cubes à partir des points (taille entre min et max)
    // POUR chaque cube
    //     EXTRAIRE les caractères avec OCRProcessor
    //     ASSIGNER les caractères au cube
    // FINPOUR
    mesPoints = cherchePoint(imageSource, maCouleur);
    for (Point p : mesPoints) {
      p.pointMoyen = p.calculPointMoyen(p.mesPixels);
    }
    mesCubes = chercheCube(mesPoints, taille-150, taille+150);
    for (Cube monCube : mesCubes) {
      monCube.setCharacter(ocrProcessor.recognizeText(monCube.getImage(imageSource)));
    }
  }

  void trie() {
    // Pseudocode:
    // TRIER mesCubes par coordonnée y, puis x
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
    // Pseudocode:
    // INITIALISER une liste de points
    // POUR chaque pixel (x, y) dans l'image
    //     SI la couleur du pixel est proche de coul
    //         RECHERCHER un point existant proche de (x, y)
    //         SI trouvé
    //             AJOUTER le pixel au point
    //         SINON
    //             CRÉER un nouveau point avec ce pixel
    //         FINSI
    //     FINSI
    // FINPOUR
    // RETOURNER la liste des points
    List<Point> points = new ArrayList<Point>();
    source.loadPixels();
    for (int y = 0; y < source.height; y++) {
      for (int x = 0; x < source.width; x++) {
        color c = source.pixels[x + y * source.width];
        if (isNearCouleur(c, coul)) {
          boolean trouve = false;
          for (Point p : points) {
            if (p.isNear(x, y)) {
              p.ajoutPixel(new PixelScore(x, y, scoreCouleur(c, coul)));
              trouve = true;
              break;
            }
          }
          if (!trouve) {
            Point p = new Point();
            p.ajoutPixel(new PixelScore(x, y, scoreCouleur(c, coul)));
            points.add(p);
          }
        }
      }
    }
    return points;
  }

  List<Cube> chercheCube(List<Point> points, int min, int max) {
    // Pseudocode:
    // INITIALISER une liste de cubes
    // POUR chaque combinaison de 4 points (i, j, k, l)
    //     CRÉER un cube avec ces 4 points
    //     SI le cube est valide
    //         CALCULER la diagonale du cube
    //         SI la diagonale est entre min et max
    //             VÉRIFIER si le cube est unique (pas trop proche d'un autre)
    //             SI unique
    //                 AJOUTER le cube à la liste
    //             FINSI
    //         FINSI
    //     FINSI
    // FINPOUR
    // RETOURNER la liste des cubes
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
    // Pseudocode:
    // EXTRAIRE les composantes RGB de c1 et c2
    // DÉFINIR un seuil de 10
    // SI chaque composante de c1 est proche de celle de c2 (à ±seuil)
    //     RETOURNER vrai
    // SINON
    //     RETOURNER faux
    float r1 = red(c1), g1 = green(c1), b1 = blue(c1);
    float r2 = red(c2), g2 = green(c2), b2 = blue(c2);
    float seuil = 10;
    return (r1 >= (r2 - seuil) && r1 <= (r2 + seuil) && g1 >= (g2 - seuil) && g1 <= (g2 + seuil) && b1 >= (b2 - seuil) && b1 <= (b2 + seuil));
  }

  float scoreCouleur(color c1, color c2) {
    // Pseudocode:
    // EXTRAIRE les composantes RGB de c1 et c2
    // CALCULER la distance euclidienne entre les composantes RGB
    // RETOURNER la distance
    float r1 = red(c1), g1 = green(c1), b1 = blue(c1);
    float r2 = red(c2), g2 = green(c2), b2 = blue(c2);
    return sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2));
  }
}
