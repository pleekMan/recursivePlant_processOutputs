class Square {

  public PVector pos;
  PVector screenAbsolutePos;
  float size;
  float sizeMultiplier;
  float sizeSpeed;
  int couleur;

  String word;
  float wordWidth;

  float angle;
  boolean isFlipping;
  float flipPosition;
  private float flipDirection;
  boolean showWord;
  float wordZoomFactor;

  private float pointerZoomFactor;
  boolean pointerOverZone;

  float fadeInValue;
  float fadeInDelay;
  float fadeInTimer;

  int flipWaitTimer;

  boolean isShrinking;


  public Square(PVector _pos, int _color, float _size, String _word) {

    sizeMultiplier = 800;
    size = _size * sizeMultiplier;
    sizeSpeed = 0; // USED FOR SHRINKING AT THE END
    pos = _pos;
    pos.mult(sizeMultiplier);
    screenAbsolutePos = new PVector(9999, 9999, 9999); // 9999: AVOID A FLICKERING BUG WHEN fadeIn

    textSize(48); // RESETTING TEXT SIZE TO 48, FOR CALCULATIONS.
    word = _word;
    wordWidth = 48f / textWidth(word) * size; // p5.textWidth(word) * (1f / wordToSquareRatio);
    wordZoomFactor = 0;

    couleur = _color;

    angle = PI;
    isFlipping = false;
    flipPosition = 0; // 0 -> 1
    showWord = false;
    flipWaitTimer = millis();

    fadeInValue = 0;
    fadeInDelay = 2000; // millisecs
    fadeInTimer = millis();

    pointerZoomFactor = 0;
    flipDirection = 1;
    pointerOverZone = false;

    isShrinking = false;
  }

  public void update() {
    // SQUARE REACTION BASED ON POINTER PROXIMITY
    // setZoomFactor();

    // FADE IN
    if (fadeInValue < 1) {
      if (millis() - fadeInTimer >= fadeInDelay) {
        fadeInValue += 0.1;
      }
    }

    // FLIP BACK (HIDE) AFTER xxxx milliseconds
    if (showWord && isFlipWaitFinished()) {
      flip();
      //      allowWordZoom = false;
      //      wordZoomDirection = -1;
    }

    // FLIPPING CALCS
    if (isFlipping) {
      flipPosition += (0.005 * flipDirection);

      //      float toMap = easeInOutQuint(flipPosition);
      // angle = p5.map(toMap, 0, 1, flipStartAngle, flipTargetAngle);

      if (flipPosition >= 1 || flipPosition <= 0) {
        isFlipping = false;
        flipPosition = round(flipPosition); // CONSTRAIN TO CLOSEST (0 or 1)
      }
    }

    // TO HAVE A CONTINUATION IN THE FLIPPING ANIMATION:
    // CHOOSE THE BIGGEST VALUE OUT OF THE 2 PROCESSES, REGULAR flip AND pointer
    // INTERACTION
    float finalFlipPosition = max(pointerZoomFactor, easeInOutQuint(flipPosition));
    showWord = finalFlipPosition >= 0.5f;

    wordZoomFactor = map(pointerZoomFactor, 0.5f, 1, 1, 4);
    wordZoomFactor = constrain(wordZoomFactor, 1, 4);

    angle = map(finalFlipPosition, 0, 1, PI, 0);

    size -= sizeSpeed;
    size = constrain(size, 0, 9999);
  }



  public void setZoomFactor() {

    float pointerDistanceMax = 50;
    float pointerDistance = dist(screenAbsolutePos.x, screenAbsolutePos.y, mouseX, mouseY);
    if (pointerDistance < pointerDistanceMax) {
      pointerZoomFactor = map(pointerDistance, pointerDistanceMax, 0, 0, 1);
      pointerOverZone = true;

      textSize(20);
      //      text("", pos.x, pos.y);

      return; // quit after the first pointer
    } else {
      pointerZoomFactor = 0;
      pointerOverZone = false;
    }
  }


  public void render() {

    pushMatrix();

    translate(pos.x + (size * 0.5f), pos.y + (size * 0.5f));
    //    p5.translate(pos.x, pos.y);

    rotateY(angle);

    // THE SQUARE LUI-MEME

    float positionForColorLerp = map(flipPosition, 0.5, 1, 0, 1);

    // NORMAL COLORING PROCESS
    // --->
    /*
    if (showWord) {

      //positionForColorLerp = constrain(positionForColorLerp, 0, 1);
      color empty = color(0);
      color fadedColor = lerpColor(couleur, empty, positionForColorLerp);

      stroke(couleur);
      fill(fadedColor);
      //noFill();
    } else {
      fill(couleur, (int) (fadeInValue * 255));
      noStroke();
    }
    // <---
    */
    
    noFill();
    stroke(0);
    square(0, 0, size);
    
    // TEMP: SHOW SQUARE SIZE FROM STRUCTURE
    textSize(15);
    fill(255,0,0);
    rotateY(-angle);
    text(word,0,0);
    //    drawShadowySquare(xCentering, yCentering, size, color, fadeInValue);

    // SAVING SCREEN ABSOLUTE COORDINATES AFTER ALL THOSE PUSH/POPS MATRIX..
    screenAbsolutePos.set(screenX(0, 0, 0), screenY(0, 0, 0), screenZ(0, 0, 0));
    //    screenAbsolutePos.set(p5.modelX(-xCentering, yCentering, 0), p5.modelY(-xCentering, yCentering, 0), p5.modelZ(-xCentering, yCentering, 0));

    // THE WORD (DRAW FONTS AFTER ALL OTHER GEOMETRY (OPENGL TRANSPARENCY BUFFER
    // ISSUES) )
    if (showWord) {

      color white = color(200);
      color empty = color(200, 0);
      color fadedColor = lerpColor(empty, white, positionForColorLerp);

      if (isShrinking) {
        fill(fadedColor, 255 * (isShrinking ? 0 : 1));
      } else {
        if (pointerZoomFactor > 0.5) {
          fill(200);
        } else {
          fill(fadedColor);
        }
      }


      //fill(200, 255 * (isShrinking ? 0 : 1)); // When shrinkin, just stop showing words
      textAlign(LEFT);

      pushMatrix();
      scale(wordZoomFactor);
      translate(0, 0, 3f); // NUDGE IT AWAY FROM THE SQUARE (Z-FIGHTING)
      textSize(wordWidth);
      //text(word, -(size * 0.5f), (size * 0.25f));
      text(word, -(size * 0.5f), (size * 0.15f));
      popMatrix();
    }

    popMatrix();

    //    p5.noFill();
    //    p5.stroke(255, 0, 0);
    //    p5.square(screenAbsolutePos.x, screenAbsolutePos.y, size);
  }


  public void flip() {

    if (isFlipWaitFinished()) {

      flipDirection = flipPosition < 0.5 ? 1 : -1;

      if (!isFlipping) {
        isFlipping = true;
        showWord = !showWord;

        flipWaitTimer = millis();
      }
    }
  }

  public boolean isFlipWaitFinished() {
    return millis() - flipWaitTimer >= 5000;
  }

  public void triggerShrinking() {
    sizeSpeed = random(0.5f, 2f);
    isShrinking = true;
  }

  public boolean isMinuscule() {
    return size < 0.1;
  }

  public void setFadeInDelay(float _millis) {
    fadeInDelay = _millis;
  }

  public float easeInOutQuint(float valueNorm) {
    return valueNorm < 0.5 ? 16 * valueNorm * valueNorm * valueNorm * valueNorm * valueNorm : 1 - pow(-2 * valueNorm + 2, 5) / 2;
  }
}
