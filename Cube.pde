import java.util.Hashtable; 
import java.util.Map; 
/**
 * Classe Cube modélisant le cube dans l'espace ainsi que son caractère en braille.
 * Cette classe servira à déterminer si un cube répond aux caractéristiques recherchés.
 *  p1-----m1---->p2  
 *  |  s1  |  s2  |
 *  d1------m2-----d2
 *  |  s3  c  s4  |
 *  d4------m3-----d3
 *  |  s5  |  s6  |
 *  p4<----m4-----p3
 *
 *@author Felix Dupeysset
 *
 */
class Cube {
  PVector p1, p2, p3, p4, min, max, c;
  float largeur, hauteur;
  String monCharacter;

  Cube(PVector rp1, PVector rp2, PVector rp3, PVector rp4) {
    // Pseudocode:
    // INITIALISER les sommets du cube avec les points donnés
    // DÉFINIR monCharacter comme une chaîne vide
    p1 = rp1;
    p2 = rp2;
    p3 = rp3;
    p4 = rp4;
    monCharacter = "";
  }

  PImage getImage(PImage src) {
    // Pseudocode:
    // CALCULER les coordonnées min et max du cube
    // EXTRAIRE la sous-image de src entre (min.x, min.y) et (max.x, max.y)
    // RETOURNER la sous-image
    calculCoordoneesPoints();
    int x = (int)min.x;
    int y = (int)min.y;
    int w = (int)(max.x - min.x);
    int h = (int)(max.y - min.y);
    return src.get(x, y, w, h);
  }

  boolean estValide(PImage src) {
    // Pseudocode:
    // SI les diagonales sont perpendiculaires ET égales
    //   ET le centre est symétrique
    //   ET l'orientation est horaire
    //   ET les côtés sont égaux
    //     CALCULER les coordonnées min, max et centre
    //     RETOURNER vrai
    // SINON
    //     RETOURNER faux
    if (diagonalePerpendiculaire() && diagonaleEgales() && centreSymetrie() && orientationHoraire() && coteEgaux()) {
      calculCoordoneesPoints();
      return true;
    }
    return false;
  }

  void setCharacter(String monChar) {
    // Pseudocode:
    // ASSIGNER monChar à monCharacter
    monCharacter = monChar;
  }

  String getValue() {
    // Pseudocode:
    // RETOURNER la valeur de monCharacter
    return monCharacter;
  }

  void dessineCube() {
    // Pseudocode:
    // DÉFINIR la couleur de contour en rouge
    // DESSINER les lignes entre les sommets (p1-p2, p1-p4, p2-p3, p4-p3)
    // DÉFINIR la taille du texte à 50
    // REMPLIR en blanc
    // AFFICHER monCharacter au centre du cube
    stroke(255, 0, 0);
    int decallage = 0;
    strokeWeight(1);
    line(decallage+p1.x, p1.y, decallage+p2.x, p2.y);
    line(decallage+p1.x, p1.y, decallage+p4.x, p4.y);
    line(decallage+p2.x, p2.y, decallage+p3.x, p3.y);
    line(decallage+p4.x, p4.y, decallage+p3.x, p3.y);
    textSize(50);
    fill(255, 255, 255);
    text(monCharacter, decallage+c.x, c.y+100);
  }

  private boolean coteEgaux() {
    // Pseudocode:
    // CALCULER les distances entre les sommets (d12, d23, d34, d41)
    // SI chaque distance est proche de la suivante (à ±10%)
    //     RETOURNER vrai
    // SINON
    //     RETOURNER faux
    float d12 = dist(p1.x, p1.y, p2.x, p2.y);
    float d23 = dist(p2.x, p2.y, p3.x, p3.y);
    float d34 = dist(p3.x, p3.y, p4.x, p4.y);
    float d41 = dist(p4.x, p4.y, p1.x, p1.y);
    return (d12 >= (d23 - d23/10) && d12 <= (d23 + d23/10) && d23 >= (d34 - d34/10) && d23 <= (d34 + d34/10) && d34 >= (d41 - d41/10) && d34 <= (d41 + d41/10));
  }

  private boolean orientationHoraire() {
    // Pseudocode:
    // CALCULER les vecteurs (p2-p1) et (p4-p1)
    // CALCULER le produit vectoriel (x1*y2 - y1*x2)
    // SI produit vectoriel <= 0
    //     RETOURNER vrai (orientation horaire)
    // SINON
    //     RETOURNER faux
    float x1 = p2.x - p1.x;
    float y1 = p2.y - p1.y;
    float x2 = p4.x - p1.x;
    float y2 = p4.y - p1.y;
    return (x1 * y2 - y1 * x2) <= 0;
  }

  private boolean centreSymetrie() {
    // Pseudocode:
    // CALCULER le centre des diagonales (p1-p3 et p2-p4)
    // SI la distance entre les centres est <= 10
    //     RETOURNER vrai
    // SINON
    //     RETOURNER faux
    PVector c1 = new PVector((p1.x + p3.x) / 2, (p1.y + p3.y) / 2);
    PVector c2 = new PVector((p2.x + p4.x) / 2, (p2.y + p4.y) / 2);
    return dist(c1.x, c1.y, c2.x, c2.y) <= 10;
  }

  private boolean diagonaleEgales() {
    // Pseudocode:
    // CALCULER les longueurs des diagonales (p1-p3 et p2-p4)
    // SI les longueurs sont proches (à ±10%)
    //     RETOURNER vrai
    // SINON
    //     RETOURNER faux
    float d13 = dist(p1.x, p1.y, p3.x, p3.y);
    float d24 = dist(p2.x, p2.y, p4.x, p4.y);
    return d13 >= (d24 - d24/10) && d13 <= (d24 + d24/10);
  }

  private boolean diagonalePerpendiculaire() {
    // Pseudocode:
    // CALCULER les vecteurs des diagonales (p3-p1 et p4-p2)
    // CALCULER le produit scalaire des vecteurs
    // SI le produit scalaire est proche de 0 (entre -10 et 10)
    //     RETOURNER vrai (diagonales perpendiculaires)
    // SINON
    //     RETOURNER faux
    PVector v1 = new PVector(p3.x - p1.x, p3.y - p1.y);
    PVector v2 = new PVector(p4.x - p2.x, p4.y - p2.y);
    float scalaire = v1.x * v2.x + v1.y * v2.y;
    return scalaire >= -10 && scalaire <= 10;
  }

  private void calculCoordoneesPoints() {
    // Pseudocode:
    // CALCULER min comme le minimum des x et y des sommets
    // CALCULER max comme le maximum des x et y des sommets
    // CALCULER c comme le centre (moyenne de min et max)
    // CALCULER largeur et hauteur du cube
    min = new PVector(min(min(p1.x, p2.x), min(p3.x, p4.x)), min(min(p1.y, p2.y), min(p3.y, p4.y)));
    max = new PVector(max(max(p1.x, p2.x), max(p3.x, p4.x)), max(max(p1.y, p2.y), max(p3.y, p4.y)));
    c = new PVector((min.x + max.x) / 2, (min.y + max.y) / 2);
    largeur = dist(min.x, min.y, max.x, min.y);
    hauteur = dist(min.x, min.y, min.x, max.y);
  }
}
