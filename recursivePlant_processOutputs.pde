// !!!!
// !!!!
// FOR THE SKETCH THAT IS ACTUALLY RUNNING IN THE RASPBERRY PI,
// LOOK IN THIS SAME FOLDER

import java.io.File;
import java.io.FilenameFilter;
import java.util.Iterator;

String[] words;
String imagesPath;

ArrayList<Plant> plants;

PVector spawnAreaLeftTopClose;
PVector spawnAreaRightBottomFar;

Timer plantSpawnerTimer;
int plantCountLimit;

void setup() {
  size(1500, 1000, P3D);
  //fullScreen(P3D);

  frameRate(40);
  ortho();
  //    hint(ENABLE_DEPTH_MASK);
  hint(ENABLE_DEPTH_SORT); // BILLBOARDS RENDER ALPHA CORRECTLY. MIGHT SLOW DOWN PERFORMANCE.
  imageMode(CENTER);
  rectMode(CENTER);

  words = loadStrings("words.txt");
  imagesPath = "illustrations/";

  plants = new ArrayList<Plant>();

  // 3D CENTER IS TRANSLATED TO SCREEN CENTER
  float debordement = width * 0.25;
  spawnAreaLeftTopClose = new PVector(-(width * 0.5) - debordement, 0, 0);
  spawnAreaRightBottomFar = new PVector((width * 0.5) + debordement, 0, -1000);

  //spawnAreaLeftTopClose = new PVector(-(width * 0.5), height * 0.7f, 0);
  //spawnAreaRightBottomFar = new PVector(width, height, -1000);

  plantSpawnerTimer = new Timer(10000);
  //plantSpawnerTimer.start();

  plantCountLimit = 10;
}


void draw() {
  background(255);


  //if (plantSpawnerTimer.isFinished()) {
  //  spawnPlantRandom();
  //  plantSpawnerTimer.start();
  //}

  pushMatrix();
  translate(width * 0.5, height - 100);
  //fill(0,255,0);
  //circle(0,0,40);

  // DRAW PLANTS
  for (Iterator it = plants.iterator(); it.hasNext(); ) {
    Plant plant = (Plant) it.next();

    plant.update();
    plant.render();

    if (plant.isReadyForDeletion()) {
      it.remove();
    }
  }



  popMatrix();
}

void spawnPlantRandom() {

  // IF OVERCROWDED, KILL A PLANT BEFORE SPAWNING ANOTHER ONE
  if (plants.size() >= plantCountLimit) {
    killPlant();
  }


  String[] plantList = loadFilenames(sketchPath() + "/data/illustrations");
  //String chosenFilePath = plantList[floor(random(plantList.length))];
  //printArray(plantList);
  
  String chosenFilePath = plantList[6]; // => Cactus Speciosus
  println("Plant => " + chosenFilePath);
  PImage illustration = getIllustration(chosenFilePath);

  // POSITION
  // RANDOM PLANT AND RANDOM POSITION IN THE BACKGROUND

  PVector posInit = new PVector();
  //if (plants.isEmpty()) {
  //float xPos = random(spawnAreaLeftTopClose.x, spawnAreaRightBottomFar.x);
  //float yPos = random(spawnAreaLeftTopClose.y, spawnAreaRightBottomFar.y);
  //float zPos = random(spawnAreaRightBottomFar.z, spawnAreaLeftTopClose.z);
  
  posInit.set(0, 0, 0);
  
//} else {
  //  // WAY TO SPACE OUT "EVENLY" AND NOT RANDOMLY
  //  // DECALLER LA NOUVELLE PLANTE ~75% DU WIDTH, PUIS WRAP AROUND
  //  float areaLength = abs(spawnAreaRightBottomFar.x - spawnAreaLeftTopClose.x);
  //  float lastPosX = plants.get(plants.size() - 1).pivot.x;
  //  lastPosX += random(areaLength * 0.5, areaLength * 0.75);

  //  float xPos = (lastPosX % areaLength) - areaLength * 0.5;
  //  float yPos = random(spawnAreaLeftTopClose.y, spawnAreaRightBottomFar.y);
  //  float zPos = random(spawnAreaRightBottomFar.z, spawnAreaLeftTopClose.z);
  //  posInit.set(xPos, yPos, zPos);
  //}


  Plant newPlant = new Plant(chosenFilePath.split("\\.")[0], posInit, illustration, words, false);

  plants.add(newPlant);
}

void killPlant() {

  int randomSelect = floor(random(0, plants.size()));
  plants.get(randomSelect).triggerShrinking();
}

public PImage getIllustration(String imageFileName) {
  return loadImage("illustrations/" + imageFileName);
}


String[] loadFilenames(String path) {

  File folder = new File(path);
  FilenameFilter filenameFilter = new FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(".png");
    }
  };
  return folder.list(filenameFilter);
}

void clearAllPlants() {
  plants.clear();
}

void keyPressed() {
  if (key == ' ') {
    spawnPlantRandom();
  } else if (key == 'c') {
    clearAllPlants();
  } else if (key == 'e') {
    // EXPORT TO IMAGE
    saveFrame("images/samples - parametric/granularity 0.95/g-0.95 max-2 min-1024_####.png");
  }
  
}
