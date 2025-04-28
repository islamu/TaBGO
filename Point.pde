/**
 * Classe Point modélisant un nuage de pixels voisins intéressants.
 * Cette classe servira à déterminer le point moyen d'un nuage de PixelScore.
 * @author Felix DUPEYSSET
 */
class Point {
  List<PixelScore> mesPixels;
  PVector pointMoyen;

  Point() {
    mesPixels = new ArrayList<PixelScore>();
    pointMoyen = new PVector(-1, -1);
  }

  Point(PixelScore monPoint) {
    mesPixels = new ArrayList<PixelScore>();
    mesPixels.add(monPoint);
    pointMoyen = nonMinSuppressor(mesPixels);
  }

  /**
   * Ajoute un pixel à la liste des pixels 
   * @param monPixel de type PixelScore correspond au pixel à ajouter
   */
  void add(PixelScore monPixel) {
    mesPixels.add(monPixel);
    nonMinSuppressor(mesPixels);
  }
  
  /**
   * Détermine le point moyen du nuage de pixel à l'aide d'une moyenne pondérée par rapport au score;
   * @param listePoints de type ArrayList<PixelScore> correspond à la liste des PixelScore
   * @return un point de type PVector, qui correspond au point moyen du nuage de pixel;
   */
  PVector calculPointMoyen(List<PixelScore> listePoints) {
    PVector monPoint = new PVector();
    
    float moyennex = 0;
    float moyenney = 0;
    float dx = 0;
    
    for (PixelScore point : listePoints) {
      moyennex += point.x * (1 - (point.score / 255));
      moyenney += point.y * (1 - (point.score / 255));
      dx += (1 - (point.score / 255));
    }
    monPoint = new PVector(moyennex / dx, moyenney / dx);
   
    return monPoint;
  }
  
  /**
   * Détermine le point moyen du nuage de pixel en prenant celui qui a le plus faible score de zone
   * @param listePixels de type ArrayList<PixelScore> correspond à la liste des PixelScore
   * @return un point de type PVector, qui correspond au point moyen du nuage de pixel;
   */
  PVector nonMinSuppressor(List<PixelScore> listePixels) {
    PixelScore debut = new PixelScore(-1, -1, 9999999);
    
    for (PixelScore p : listePixels) {
      if (p.score < debut.score) {
        debut = p;
      }
    }
    
    PVector out = new PVector(debut.x, debut.y); 
    return out;
  }
  
  /**
   * Détermine si un pixel est proche d'au moins 1 pixel dans le nuage de pixel du point;
   * @param monPixel de type PixelScore correspond à un pixel
   * @return true si le pixel a au moins 1 pixel proche, sinon false;
   */
  boolean isNear(PixelScore monPixel) {
    boolean trouve = false;
    for (PixelScore pixel : mesPixels) {
      if (dist(pixel.x, pixel.y, monPixel.x, monPixel.y) < 20) {
        trouve = true;
        break;
      }
    }
    return trouve;
  }

  /**
   * Surcharge de isNear pour accepter des coordonnées (x, y) directement
   * @param x coordonnée x du pixel
   * @param y coordonnée y du pixel
   * @return true si le pixel (x, y) est proche d'au moins 1 pixel dans le nuage, sinon false
   */
  boolean isNear(int x, int y) {
    // Créer un PixelScore temporaire avec un score fictif (par exemple, 0)
    PixelScore tempPixel = new PixelScore(x, y, 0);
    return isNear(tempPixel);
  }

  /**
   * Détermine la distance entre ce point et un autre;
   * @param monPoint de type Point correspond à un point
   * @return une valeur de type float, correspondant à la distance entre deux points;
   */
  float distance(Point monPoint) {
    return dist(pointMoyen.x, pointMoyen.y, monPoint.pointMoyen.x, monPoint.pointMoyen.y);
  }
}
