Changements Apportés : 

1. Passage de la Reconnaissance Braille à l'OCR

Contexte





Système initial : Les Cubarithmes étaient des cubes physiques avec des motifs braille, interprétés par la classe Braille pour extraire un caractère unique (chiffre, lettre, ou signe).



Nouvelle approche : Utilisation de l'OCR avec Tesseract pour détecter des chaînes de caractères alphanumériques (ex. "123", "abc") sur les cubes.

Classes Modifiées ou Ajoutées





Cube :





Changement de monCharacter : Character → String pour gérer plusieurs caractères.



Ajout de getImage(PImage src) pour extraire l'image du cube.



Suppression des champs et méthodes liés au braille (s1 à s6, calculScore, etc.).



DetectionCube :





Remplacement de l'attribut monBraille par ocrProcessor.



Mise à jour de la méthode recherche pour utiliser ocrProcessor.recognizeText afin d'extraire les caractères des cubes via Tesseract.



Braille → OCRProcessor :





Suppression de la classe Braille.



Création de OCRProcessor :





Utilise Tess4J pour intégrer Tesseract.



Prétraite les images (niveaux de gris, seuillage) pour améliorer la précision.



Retourne une chaîne de caractères détectée.

Dépendances Ajoutées





Tess4J : Bibliothèque Java pour Tesseract.



Tesseract : Données d'entraînement (eng.traineddata) pour reconnaître les caractères.



2. Gestion de Plusieurs Blocs Empilés

Contexte





Structure des blocs :





Chaque bloc est défini par un TopCode (ex. code 213 pour "définir bloc").



TopCode 357 définit var1, TopCode 361 définit var2.



Les Cubarithmes suivants contiennent les valeurs de var1 et var2.



Exemple : Bloc 1 (TopCode 213, TopCode 357, Cube "5", TopCode 361, Cube "10").



Problème initial :





La méthode construitAlgorithme dans FiltrageCubes traitait les Cubarithmes avant leurs TopCodes correspondants, causant des erreurs d'association.



Pas de regroupement clair des Cubarithmes par bloc.

Classe Modifiée





FiltrageCubes :





Création d'une liste combinée triée (ImageObject) contenant TopCodes et Cubarithmes, triée par y puis x.



Regroupement des Cubarithmes par bloc :





Un nouveau bloc commence avec TopCode 213.



Les Cubarithmes sont associés à var1 ou var2 du bloc actuel jusqu'au prochain TopCode 213.



Finalisation des blocs : Les valeurs de var1 et var2 sont ajoutées à la liste des blocs Scratch (listBlocks) à la fin de chaque bloc.