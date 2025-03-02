class Plant { //<>// //<>// //<>//


  String name;
  //String binomialName;
  PVector pivot;
  PVector squaresOffset;
  float startingSquare;
  float biggestSquareAllowed;
  float smallestSquareAllowed;
  float granularity; // 0 - 1 => chance of continuing to divide instead of rendering the square

  PImage plantImage;
  String[] words;

  ArrayList<Square> squares;

  Timer flippingTimer;
  //int timerFlipping;
  int maxSquareFadeInDelay = 3000;

  boolean isAnimated = true;


  public Plant(String _name, PVector _pos, PImage illustration, String[] _words, boolean _isAnimated) {

    name = _name;
    //binomialName = DatabaseManager.getPlantField(name, "nomenclatureBinomiale");
    isAnimated = _isAnimated;
    words = _words;
    plantImage = illustration;
    // MOST OF THE CRUCIAL PLANT CREATION PARAMETERS ARE SET AT createPlant()

    pivot = _pos;
    //println(name + " : pos => \t" + pivot.x + " \t " + pivot.y + " \t " + pivot.z);
    squaresOffset = new PVector(0, 0);
    squares = new ArrayList<Square>();

    flippingTimer = new Timer(500);
    flippingTimer.start();

    maxSquareFadeInDelay = 1000;


    //p5.println("--| Spawning new Plant => " + name);
    createPlant();
  }

  public void update() {
    if (isAnimated) {
      flippingProcess();
    }
  }

  public void render() {

    //    pivot.set(Grid.snap(p5.width * 0.5f), Grid.snap(p5.height * 0.8f));
    //    pivot.set(0, 0);

    pushMatrix();
    translate(pivot.x, pivot.y, pivot.z); // GLOBAL POSITION OF PLANT
    stroke(0,0,255);
    //noFill();
    //circle(0, 0, 30);
    //line(pivot.x, pivot.y, pivot.z, pivot.x, pivot.y, 0);

    // DISPLAY NAME BELOW THE PLANT
    //displayName();

    // REPOSITION AT PIVOT POINT ACCORDING TO THE IMAGE
    translate(squaresOffset.x, squaresOffset.y);

    //    p5.image(plantImage, 0, 0);

    rectMode(CENTER);
    for (Iterator it = squares.iterator(); it.hasNext(); ) {
      Square square = (Square) it.next();

      square.update();
      square.render();e
    }

    popMatrix();
  }

  public void createPlant() {

    startingSquare = 1;

    biggestSquareAllowed = startingSquare / 1; // GOOD VALUES = / 2
    smallestSquareAllowed = (float) startingSquare / 1024; // GOOD VALUES = / 128
    granularity = 0.95f; // => PROBABILTY OF DESCENDING IN RECURSIVE SCALE

    createSquaresGrid(0, 0, startingSquare);
    centerSquarePosition();
  }

  public void createSquaresGrid(float resXStart, float resYStart, float squareSize) {

    //RECURSIVE LIMIT => SMALLEST SQUARE
    if (squareSize >= smallestSquareAllowed) {

      float halfSquare = squareSize * 0.5f;

      //EVEN IF STARTING FROM THE BIGGEST SQUARE, ONLY PROCESS WHEN REACHING A CERTAIN BIGGEST SIZE
      if (squareSize <= biggestSquareAllowed) {

        // THIS GRANULARITY CHECK WORKS INVERSIVELY (CUZ OF HOW THE ALGORITHM IS IMPLEMENTED):
        // IT'S ACTUALLY THE PROBABILITY OF STAYING IN THIS SQUARE AND NOT DESCENDING 
        if (random(1) > granularity) {

          float colorPickNormX = (resXStart + halfSquare) / startingSquare; //<>//
          float colorPickNormY = (resYStart + halfSquare) / startingSquare;

          int couleur = plantImage.get((int) (plantImage.width * colorPickNormX), (int) (plantImage.height * colorPickNormY));

          // ONLY CREATE A SQUARE IF PIXEL IN IMAGE IS NOT TRANSPARENT && IS NOT BLACK
          if (alpha(couleur) > 0 && brightness(couleur) > 0) {
            couleur = color(red(couleur), green(couleur), blue(couleur), 255); // FULL OPACITY TO COLORS
            //            p5.println("-| " + p5.red(color), p5.green(color), p5.blue(color));

            //float distanceFog = map(pivot.z, 0, -1000, 0.8, 0.2); // = square brigthness
            //couleur = desaturateColor(couleur, random(0, 0.5), distanceFog);


            PVector newPos = new PVector(resXStart, resYStart);
            String squareWord = words[(int) random(words.length)];
            float fadeInDelay = maxSquareFadeInDelay * (1 - colorPickNormY); // MAKE IT GROW FROM THE BOTTOM

            Square newSquare = new Square(newPos, couleur, squareSize, squareWord);
            newSquare.setFadeInDelay(fadeInDelay);

            //            p5.println("--| Square Size = " + squareSize);
            squares.add(newSquare);
          }
        } else {
          createSquaresGrid(resXStart, resYStart, halfSquare);
          createSquaresGrid(resXStart + halfSquare, resYStart, halfSquare);
          createSquaresGrid(resXStart, resYStart + halfSquare, halfSquare);
          createSquaresGrid(resXStart + halfSquare, resYStart + halfSquare, halfSquare);
        }
      } else {
        createSquaresGrid(resXStart, resYStart, halfSquare);
        createSquaresGrid(resXStart + halfSquare, resYStart, halfSquare);
        createSquaresGrid(resXStart, resYStart + halfSquare, halfSquare);
        createSquaresGrid(resXStart + halfSquare, resYStart + halfSquare, halfSquare);
      }
    }
  }

  public void centerSquarePosition() {
    // AFTER CREATING THE GRID, CHECK X AND Y BOUNDARIES AND SET THE PIVOT
    // ACCORDINGLY (PLANT PLANTED ON PIVOT)
    // THIS IS DONE CUZ ITS EASIER TO CALCULATE AFTER THE RECURSIVE GENERATION, AND
    // NOT BEFOREHAND

    float minX = 99999;
    float maxX = 0;
    float minY = 99999;
    float maxY = 0;

    for (Iterator it = squares.iterator(); it.hasNext(); ) {
      Square square = (Square) it.next();

      if (square.pos.x < minX) {
        minX = square.pos.x;
      }

      if (square.pos.x > maxX) {
        maxX = square.pos.x;
      }

      if (square.pos.y < minY) {
        minY = square.pos.y;
      }

      if (square.pos.y > maxY) {
        maxY = square.pos.y;
      }
    }

    //    p5.println("-|| minX: " + minX + " | " + "maxX: " + maxX + " | " +"minY: " + minY + " | " + "maxY: " + maxY + " | ");
    squaresOffset.set(-((maxX - minX) * 0.5f), -((maxY - minY)));
  }

  private color desaturateColor(int inColor, float factor, float brightness) {
    //    p5.println("--|| DESATURATING COLOR");

    // DESATURATE COLOR WITH AN INTENSITY OF factor, TOWARDS WHITE
    // AND MAKE IT A LITTLE BLUEISH

    float r = ((inColor >> 16) & 0xFF) / 255f;
    float g = ((inColor >> 8) & 0xFF) / 255f;
    float b = (inColor & 0xFF) / 255f;
    //    float a = ((inColor >> 24) & 0xFF) / 255f;

    float luminance = 0.3f * r + 0.6f * g + 0.1f * b; // overall image luminance model

    float new_r = r + (factor * (luminance - r)) - (1 - brightness);
    float new_g = g + (factor * (luminance - g)) - (1 - brightness);
    float new_b = b + (factor * (luminance - b)) - (1 - brightness) + 0.2f; // a little blueish

    return color(new_r * 255, new_g * 255, new_b * 255, 255);
  }

  public void flippingProcess() {

    //int freq = 500; // EVERY xxxx MILLISECONDS
    if(flippingTimer.isFinished()){
      flipRandomSquare();
      //println("-- || FLIPPING A SQUARE");
      flippingTimer.start();
    }
  }

  public void flipAllSquares() {
    for (Iterator it = squares.iterator(); it.hasNext(); ) {
      Square square = (Square) it.next();
      square.flip();
    }
  }

  public void flipRandomSquare() {
    int rnd = floor(random(squares.size()));
    squares.get(rnd).flip();
  }

  public void triggerShrinking() {
    for (Iterator it = squares.iterator(); it.hasNext(); ) {
      Square square = (Square) it.next();
      square.triggerShrinking();
    }
  }

  public boolean isShrinking() {
    return squares.get(0).isShrinking;
  }

  public boolean isReadyForDeletion() {
    // IF THE SIZE OF ALL THE SQUARES IS 0, INFORM FOR DELETION

    for (Iterator it = squares.iterator(); it.hasNext(); ) {
      Square square = (Square) it.next();

      if (!square.isMinuscule()) {
        return false;
      }
    }
    return true;
  }

  private void displayName() {
    fill(255);
    textSize(30);
    textAlign(CENTER);

    pushMatrix();
    translate(0, 40, 20);
    text(name, 0, 0);
    popMatrix();
  }
}
