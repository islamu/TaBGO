import java.util.ArrayList;
import java.util.Deque;
import java.util.ArrayDeque;
import java.util.List;
import java.util.Comparator;

public class FiltrageCubes {
  private TopCode topCode;
  private Cube cubarithme;

  public FiltrageCubes() {
    // Pseudocode:
    // INITIALISER topCode et cubarithme à null
    topCode = null;
    cubarithme = null;
  }

  public boolean estSuperieur(TopCode tc, Cube cube) {
    // Pseudocode:
    // SI tc et cube sont sur la même ordonnée (y)
    //     RETOURNER vrai si tc.x > cube.x
    // SINON
    //     RETOURNER vrai si tc.y > cube.y
    if (memeOrdonnee(tc, cube)) {
      return (tc.getCenterX() > cube.c.x);
    } else {
      return (tc.getCenterY() > cube.c.y);
    }
  }

  private boolean memeOrdonnee(TopCode tc, Cube cube) {
    // Pseudocode:
    // OBTENIR les coordonnées y de tc et cube
    // CALCULER une hauteur de tolérance basée sur le diamètre de tc
    // SI y(cube) est dans l'intervalle [y(tc) - hauteur, y(tc) + hauteur]
    //     RETOURNER vrai
    // SINON
    //     RETOURNER faux
    double y1 = tc.getCenterY();
    double y2 = cube.c.y;
    double height = (tc.getDiameter()) * 0.8;
    height /= 10;
    return (y1 - height <= y2 && y2 <= y1 + height);
  }

  private class ImageObject {
    boolean isTopCode;
    TopCode topCode;
    Cube cube;

    ImageObject(TopCode tc) {
      // Pseudocode:
      // DÉFINIR isTopCode à vrai
      // ASSIGNER tc à topCode
      // DÉFINIR cube à null
      isTopCode = true;
      topCode = tc;
      cube = null;
    }

    ImageObject(Cube c) {
      // Pseudocode:
      // DÉFINIR isTopCode à faux
      // DÉFINIR topCode à null
      // ASSIGNER c à cube
      isTopCode = false;
      topCode = null;
      cube = c;
    }

    float getY() {
      // Pseudocode:
      // SI isTopCode est vrai
      //     RETOURNER la coordonnée y de topCode
      // SINON
      //     RETOURNER la coordonnée y de cube
      return isTopCode ? topCode.getCenterY() : cube.c.y;
    }

    float getX() {
      // Pseudocode:
      // SI isTopCode est vrai
      //     RETOURNER la coordonnée x de topCode
      // SINON
      //     RETOURNER la coordonnée x de cube
      return isTopCode ? topCode.getCenterX() : cube.c.x;
    }
  }

  public List<Blocks> construitAlgorithme(List<TopCode> tc, List<Cube> lcubes, GestionBlocks g) {
    // Pseudocode:
    // CRÉER une liste combinée de tous les objets (TopCodes et Cubarithmes)
    // POUR chaque TopCode
    //     AJOUTER à la liste comme ImageObject
    // FINPOUR
    // POUR chaque Cube
    //     AJOUTER à la liste comme ImageObject
    // FINPOUR
    // TRIER la liste par y, puis x
    // INITIALISER les variables de contrôle (prev, cur, listBlocks, etc.)
    // POUR chaque objet dans la liste triée
    //     SI l'objet est un TopCode
    //         SI le code est 213 (définir bloc)
    //             FINALISER le bloc précédent (ajouter var1 et var2)
    //             COMMENCER un nouveau bloc
    //         FINSI
    //         SELON le code
    //             357 : ATTENDRE var1
    //             361 : ATTENDRE var2
    //             AUTRE : Gérer comme un bloc standard
    //         FINSI
    //         GÉRER les blocs de contrôle (stop, else, etc.)
    //         AJOUTER le TopCode à listBlocks
    //     SINON (l'objet est un Cube)
    //         SI en attente de var1
    //             AJOUTER la valeur du cube à var1Values
    //         SINON SI en attente de var2
    //             AJOUTER la valeur du cube à var2Values
    //         SINON
    //             AJOUTER le cube comme Cubarithme générique
    //         FINSI
    //     FINSI
    // FINPOUR
    // FINALISER le dernier bloc (ajouter var1 et var2)
    // RETOURNER listBlocks
    List<ImageObject> allObjects = new ArrayList<>();
    for (TopCode t : tc) {
      allObjects.add(new ImageObject(t));
    }
    for (Cube c : lcubes) {
      allObjects.add(new ImageObject(c));
    }

    allObjects.sort((o1, o2) -> {
      float y1 = o1.getY();
      float y2 = o2.getY();
      if (y1 != y2) {
        return Float.compare(y1, y2);
      }
      float x1 = o1.getX();
      float x2 = o2.getX();
      return Float.compare(x1, x2);
    });

    int prev = 0, cur = 0;
    List<Blocks> listBlocks = new LinkedList<>();
    Deque<Integer> parents = new ArrayDeque<>();
    boolean topLevel = false;
    boolean waitingForVar1 = false, waitingForVar2 = false;
    boolean inBlock = false;
    List<String> var1Values = new ArrayList<>();
    List<String> var2Values = new ArrayList<>();

    for (ImageObject obj : allObjects) {
      if (obj.isTopCode) {
        TopCode code = obj.topCode;
        if (code.getCode() == 213) {
          if (inBlock) {
            if (waitingForVar1 && !var1Values.isEmpty()) {
              for (String val : var1Values) {
                addCubarithme(g, prev, listBlocks, parents, val);
                prev = listBlocks.size() - 1;
              }
              waitingForVar1 = false;
            }
            if (waitingForVar2 && !var2Values.isEmpty()) {
              for (String val : var2Values) {
                addCubarithme(g, prev, listBlocks, parents, val);
                prev = listBlocks.size() - 1;
              }
              waitingForVar2 = false;
            }
            var1Values.clear();
            var2Values.clear();
          }
          inBlock = true;
          topLevel = true;
        }

        switch (code.getCode()) {
          case 31: case 213: case 217: case 227: case 47:
            topLevel = true;
            break;
          case 357:
            waitingForVar1 = true;
            break;
          case 361:
            waitingForVar2 = true;
            break;
          default:
            topLevel = false;
        }

        if (g.isStopBlock(code.getCode())) {
          prev = parents.removeFirst();
        } else if (g.isElseBlock(code.getCode())) {
          listBlocks.get(parents.peekFirst()).getInputs().put("SUBSTACK2", new ArrayList<>());
          listBlocks.get(parents.peekFirst()).setOpcode("control_if_else");
        } else {
          prev = addTopCode(g, prev, cur, listBlocks, parents, code, topLevel);
          cur = g.isVariable(code.getCode()) ? cur : cur + 1;
          cur = g.isDefinition(code.getCode()) ? cur + 1 : cur;
        }
      } else {
        Cube cube = obj.cube;
        println("cube : " + cube.getValue());
        if (waitingForVar1) {
          var1Values.add(cube.getValue());
        } else if (waitingForVar2) {
          var2Values.add(cube.getValue());
        } else {
          addCubarithme(g, prev, listBlocks, parents, cube.getValue());
        }
      }
    }

    if (inBlock) {
      if (waitingForVar1 && !var1Values.isEmpty()) {
        for (String val : var1Values) {
          addCubarithme(g, prev, listBlocks, parents, val);
          prev = listBlocks.size() - 1;
        }
      }
      if (waitingForVar2 && !var2Values.isEmpty()) {
        for (String val : var2Values) {
          addCubarithme(g, prev, listBlocks, parents, val);
          prev = listBlocks.size() - 1;
        }
      }
    }

    return listBlocks;
  }

  private int addTopCode(GestionBlocks g, int prev, int cur, List<Blocks> listBlocks, Deque<Integer> parents, TopCode code, boolean topLevel) {
    // Pseudocode:
    // SI le TopCode est un bloc de contrôle (non stop ou else)
    //     AJOUTER cur à la pile des parents
    //     AJOUTER le TopCode à listBlocks avec parent = premier parent
    // SINON
    //     SI la pile des parents est vide
    //         AJOUTER le TopCode à listBlocks sans parent
    //     SINON
    //         AJOUTER le TopCode à listBlocks avec parent = premier parent
    //     FINSI
    // FINSI
    // RETOURNER l'index du dernier bloc ajouté
    if (g.isControlBlock(code.getCode()) && !g.isStopBlock(code.getCode()) && !g.isElseBlock(code.getCode())) {
      parents.addFirst(cur);
      g.ajoutTopCode(listBlocks, code, topLevel, cur, prev, parents.peekFirst());
    } else {
      if (parents.isEmpty()) {
        g.ajoutTopCode(listBlocks, code, topLevel, cur, prev);
      } else {
        g.ajoutTopCode(listBlocks, code, topLevel, cur, prev, parents.peekFirst());
      }
    }
    return listBlocks.size() - 1;
  }

  private void addCubarithme(GestionBlocks g, int prev, List<Blocks> listBlocks, Deque<Integer> parents, String cubeValue) {
    // Pseudocode:
    // SI listBlocks n'est pas vide
    //     SI la pile des parents n'est pas vide
    //         AJOUTER le Cubarithme à listBlocks avec parent = premier parent
    //     SINON
    //         AJOUTER le Cubarithme à listBlocks avec parent = prev
    //     FINSI
    // FINSI
    if (!listBlocks.isEmpty()) {
      if (!parents.isEmpty()) {
        g.ajoutCubarithme(listBlocks, cubeValue, parents.peekFirst());
      } else {
        g.ajoutCubarithme(listBlocks, cubeValue, prev);
      }
    }
  }
}
