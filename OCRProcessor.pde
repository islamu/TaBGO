import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;
import java.awt.image.BufferedImage;
import processing.core.PImage;

class OCRProcessor {
  private Tesseract tesseract;

  OCRProcessor() {
    // Pseudocode:
    // CRÉER une instance de Tesseract
    // DÉFINIR le chemin des données (tessdata)
    // DÉFINIR la langue (anglais)
    // LIMITER les caractères reconnus à 0-9 et a-z
    try {
      tesseract = new Tesseract();
      String tessDataPath = dataPath("") + "/tessdata";
      println("Chemin tessdata utilisé : " + tessDataPath); // Débogage
      tesseract.setDatapath(tessDataPath);
      tesseract.setLanguage("eng");
      //tesseract.setTessVariable("tessedit_char_whitelist", "0123456789abcdefghijklmnopqrstuvwxyz");
    } catch (Exception e) {
      println("Erreur lors de l'initialisation de Tesseract : " + e.getMessage());
      e.printStackTrace();
    }
  }

  private BufferedImage toBufferedImage(PImage img) {
    // Pseudocode:
    // CRÉER une BufferedImage de la taille de img
    // CHARGER les pixels de img
    // COPIER les pixels dans BufferedImage
    // RETOURNER BufferedImage
    BufferedImage bimg = new BufferedImage(img.width, img.height, BufferedImage.TYPE_INT_ARGB);
    img.loadPixels();
    bimg.setRGB(0, 0, img.width, img.height, img.pixels, 0, img.width);
    return bimg;
  }

  String recognizeText(PImage cubeImage) {
    // Pseudocode:
    // ESSAYER
    //     PRÉTRAITER l'image (niveaux de gris, seuillage)
    //     CONVERTIR l'image en BufferedImage
    //     APPLIQUER l'OCR avec Tesseract
    //     NETTOYER le résultat (supprimer espaces)
    //     SI le résultat contient uniquement des caractères alphanumériques
    //         RETOURNER le résultat
    //     FINSI
    // ATTRAPER une exception
    //     AFFICHER l'erreur
    //     RETOURNER une chaîne vide
    // FINESSAYER
    try {
      if (cubeImage == null) {
        println("Erreur : l'image passée à recognizeText est null");
        return "";
      }
      PImage processedImg = preprocessImage(cubeImage);
      BufferedImage bimg = toBufferedImage(processedImg);
      String result = tesseract.doOCR(bimg).trim();
      if (result.matches("[0-9a-z]+")) {
        return result;
      } else {
        println("Résultat OCR non alphanumérique : " + result);
      }
    } catch (TesseractException e) {
      println("Erreur OCR : " + e.getMessage());
      e.printStackTrace();
    }
    return "";
  }

  private PImage preprocessImage(PImage img) {
    // Pseudocode:
    // APPLIQUER un filtre de niveaux de gris à img
    // APPLIQUER un seuillage (threshold 0.5) pour améliorer le contraste
    // RETOURNER l'image prétraitée
    PImage processed = img.get(); // Créer une copie pour ne pas modifier l'original
    processed.filter(GRAY);
    processed.filter(THRESHOLD, 0.5);
    return processed;
  }
}
