// Bakeoff #3 - Escrita de Texto em Smartwatches
// IPM 2019-20, Semestre 2
// Entrega: exclusivamente no dia 22 de Maio, até às 23h59, via Discord

// Processing reference: https://processing.org/reference/

import java.util.Arrays;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;
import java.util.Map;
import java.util.Vector;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.FileReader;
import java.io.IOException;

// Screen resolution vars;
float PPI, PPCM;
float SCALE_FACTOR;

// Finger parameters
PImage fingerOcclusion;
int FINGER_SIZE;
int FINGER_OFFSET;

// Arm/watch parameters
PImage arm;
int ARM_LENGTH;
int ARM_HEIGHT;

// Arrow parameters
PImage leftArrow, rightArrow;
int ARROW_SIZE;

// Study properties
String[] phrases;                   // contains all the phrases that can be tested
int NUM_REPEATS            = 2;     // the total number of phrases to be tested
int currTrialNum           = 0;     // the current trial number (indexes into phrases array above)
String currentPhrase       = "";    // the current target phrase
String currentTyped        = "";    // what the user has typed so far
String currentLetter         = "|";
String currentWord         = "";
int lastButton             = -1;
int currentButton          = -1;
float time                 = 0;
float timeInterval         = 700; //1 second

// Performance variables
float startTime            = 0;     // time starts when the user clicks for the first time
float finishTime           = 0;     // records the time of when the final trial ends
float lastTime             = 0;     // the timestamp of when the last trial was completed
float lettersEnteredTotal  = 0;     // a running total of the number of letters the user has entered (need this for final WPM computation)
float charsEnteredTotal    = 0;
float lettersExpectedTotal = 0;     // a running total of the number of letters expected (correct phrases)
float errorsTotal          = 0;     // a running total of the number of errors (when hitting next)

float iHeight;
float iWidth;
int nButtons = 11;
ArrayList<Button> buttonsArray = new ArrayList<Button>();
String[] alphabet = {"<", "_", "abc", "def", ">>", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz"};
float keyTimer = 0;

color backgroundColor = color(255);
color keysColor = #E5E5E5;
color hoverColor = #FFCFE9;
color lettersColor = #8338EC;
color possibleColor = #FFBBE4;

String[] words;
String possibleWord         = "";

class Button {
  float x, y, w, h;
  String txt;
  int index;
  int currentChar = 0;

  Button(float X, float Y, float W, float H, int buttonIndex) {
    x = X;
    y = Y;
    w = W;
    h = H;
    index = buttonIndex;
    txt = alphabet[buttonIndex];
  }

  void display() {
    //noFill();
    strokeWeight(3);
    stroke(backgroundColor);
    if (didMouseClick(x, y, w, h)) {
      fill(hoverColor);
      rect(x, y, w, h, h/4);
    } else {
      fill(keysColor);
      rect(x, y, w, h, h/4);
    }
    fill(lettersColor);
    text(txt, x + w/2, y + h/2);
  }

  String getCurrentChar() {
    return "" + txt.charAt(currentChar);
  }

  void advanceChar() {
    currentChar = (currentChar + 1) % txt.length();
  }

  void resetChar() {
    currentChar = 0;
  }
}

//Setup window and vars - runs once
void setup() {
  //size(900, 900);
  fullScreen();
  textFont(createFont("Arial", 24));  // set the font to arial 24
  noCursor();                         // hides the cursor to emulate a watch environment

  // Load images
  arm = loadImage("arm_watch.png");
  fingerOcclusion = loadImage("finger.png");
  leftArrow = loadImage("left.png");
  rightArrow = loadImage("right.png");

  // Load phrases
  phrases = loadStrings("phrases.txt");                       // load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random());  // randomize the order of the phrases with no seed

  // Scale targets and imagens to match screen resolution
  SCALE_FACTOR = 1.0 / displayDensity();          // scale factor for high-density displays
  String[] ppi_string = loadStrings("ppi.txt");   // the text from the file is loaded into an array.
  PPI = float(ppi_string[1]);                     // set PPI, we assume the ppi value is in the second line of the .txt
  PPCM = PPI / 2.54 * SCALE_FACTOR;               // do not change this!

  FINGER_SIZE = (int)(11 * PPCM);
  FINGER_OFFSET = (int)(0.8 * PPCM);
  ARM_LENGTH = (int)(19 * PPCM);
  ARM_HEIGHT = (int)(11.2 * PPCM);
  ARROW_SIZE = (int)(2.2 * PPCM);
  iHeight = 3.0*PPCM;
  iWidth = 4.0*PPCM;


  int k = 0;

  for (int i = 0; i < 2; i++)
    for (int j = 0; j < 4; j++)
      buttonsArray.add(new Button(width/2 - 2.0*PPCM + (j*iWidth)/4, height/2 - 1.0*PPCM + (i*iHeight)/3, (iWidth)/4, (iHeight)/3, k++));          

  for (int j = 0; j < 3; j++)
    buttonsArray.add(new Button(width/2 - 2.0*PPCM + (j*iWidth)/3, height/2 - 1.0*PPCM + 2*iHeight/3, (iWidth)/3, (iHeight)/3, k++)); 

  words = loadStrings("words.txt");
}

void draw() { 
  // Check if we have reached the end of the study
  if (finishTime != 0)  return;

  background(255);                                                         // clear background

  // Draw arm and watch background
  imageMode(CENTER);
  image(arm, width/2, height/2, ARM_LENGTH, ARM_HEIGHT);

  // Check if we just started the application
  if (startTime == 0 && !mousePressed) {
    fill(lettersColor);
    textAlign(CENTER, CENTER);
    text("If you are ready to\nstart and have\nread the README\ntap to start time!\n\nGood Luck!", width/2, height/2);
  } else if (startTime == 0 && mousePressed) nextTrial();                    // show next sentence

  // Check if we are in the middle of a trial
  else if (startTime != 0) {

    // Draw very basic ACCEPT button - do not change this!
    textAlign(CENTER);
    noStroke();
    fill(0, 250, 0);
    rect(width/2 - 2*PPCM, height/2 - 5.1*PPCM, 4.0*PPCM, 2.0*PPCM);        
    fill(0);
    text("ACCEPT >", width/2, height/2 - 4.1*PPCM);

    // Draw screen areas
    // simulates text box - not interactive
    strokeWeight(3);
    stroke(backgroundColor);
    fill(backgroundColor);
    rect(width/2 - 2.0*PPCM, height/2 - 2.0*PPCM, 4.0*PPCM, 1.0*PPCM);
    textAlign(CENTER);
    fill(0);

    // THIS IS THE ONLY INTERACTIVE AREA (4cm x 4cm); do not change size
    strokeWeight(3);
    stroke(backgroundColor);
    fill(backgroundColor);
    rect(width/2 - 2.0*PPCM, height/2 - 1.0*PPCM, 4.0*PPCM, 3.0*PPCM);

    /*=============================================================
     T E X T    A R E A 
     =============================================================*/

    if (keyTimer != 0 && (millis()-keyTimer) > timeInterval && currentLetter != "" && currentLetter != "|") {
      buttonsArray.get(currentButton).resetChar();
      currentWord += currentLetter;
      currentLetter = "";
    }

    textFont(createFont("Arial", PPCM/2.3));
    textAlign(LEFT);
    fill(100);
    text("Phrase " + (currTrialNum + 1) + " of " + NUM_REPEATS, width/2 - 4.0*PPCM, height/2 - 8.1*PPCM);   // write the trial count        
    text("Target:     " + currentPhrase, width/2 - 4.0*PPCM, 100);                           // draw the target string
    fill(0);
    if (currentLetter == "|") text("Entered:  " + currentTyped + currentWord + "|", width/2 - 4.0*PPCM, height/2 - 6.1*PPCM);                      // draw what the user has entered thus          
    else text("Entered:  " + currentTyped + currentWord + currentLetter + "|", width/2 - 4.0*PPCM, height/2 - 6.1*PPCM);                      // draw what the user has entered thus          

    // Write current letter
    verifyWord();
    float w = textWidth(possibleWord);
    textAlign(CENTER, BOTTOM);
    fill(possibleColor);
    text(possibleWord, width/2, height/2 - 1.25 * PPCM);
    fill(lettersColor);
    if (possibleWord != "") textAlign(LEFT, BOTTOM);
    text(currentWord + currentLetter, width/2 - w/2, height/2 - 1.25 * PPCM);             // draw current letter
    noFill();

    /*===========================================================*/

    for (int i = 0; i < nButtons; i++) {
      textAlign(CENTER, CENTER);
      buttonsArray.get(i).display();
    }
  }

  // Draw the user finger to illustrate the issues with occlusion (the fat finger problem)
  imageMode(CORNER);
  image(fingerOcclusion, mouseX - FINGER_OFFSET, mouseY - FINGER_OFFSET, FINGER_SIZE, FINGER_SIZE);
}

// Check if mouse click was within certain bounds
boolean didMouseClick(float x, float y, float w, float h) {
  return (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h);
}

void verifyWord() {
  String s = currentWord;
  if (s.length() == 0 && currentLetter == "|") return;
  if (currentLetter != "|") s += currentLetter;
  for (String word : words)
    if (word.indexOf(s) == 0) {
      possibleWord = word;
      return;
    }
  possibleWord = "";
}

void mousePressed() {
  if (didMouseClick(width/2 - 2*PPCM, height/2 - 5.1*PPCM, 4.0*PPCM, 2.0*PPCM)) nextTrial(); // Test click on 'accept' button - do not change this!
  else if (didMouseClick(width/2 - 2.0*PPCM, height/2 - 1.0*PPCM, 4.0*PPCM, 3.0*PPCM)) {  // Test click on 'keyboard' area - do not change this condition! 
    // YOUR KEYBOARD IMPLEMENTATION NEEDS TO BE IN HERE! (inside the condition)
    if (startTime != 0) {
      Button button;

      // IF KEYS WITH LETTERS ARE PRESSED...
      for (int i = 2; i < nButtons; i++) {
        if (i == 4) continue;
        button = buttonsArray.get(i);
        if (didMouseClick(button.x, button.y, button.w, button.h)) {
          lastButton = currentButton;
          currentButton = button.index;

          if (lastButton != currentButton) {
            if (currentLetter != "" && currentLetter != "|") {
              currentWord += currentLetter;
              //verifyWord();
            }
            if (lastButton != -1) buttonsArray.get(lastButton).resetChar();
            currentLetter = button.getCurrentChar();
            keyTimer = millis();
          } else if (lastButton == currentButton) {
            if (millis()-keyTimer < timeInterval) button.advanceChar(); 
            else  button.resetChar();
            currentLetter = button.getCurrentChar();
            keyTimer = millis();
          }
        }
      }

      //if SPACEBAR is pressed...
      button = buttonsArray.get(1);
      if (didMouseClick(button.x, button.y, button.w, button.h)) {
        if (currentLetter != "" && currentLetter != "|") {
          currentWord += currentLetter;
        }
        currentTyped += currentWord + ' ';
        currentWord = "";
        currentLetter = "|";
        possibleWord = currentWord;
      }

      //if BACKSPACE is pressed...
      button = buttonsArray.get(0);
      if (didMouseClick(button.x, button.y, button.w, button.h)) {
        String[] words;
        String word;
        int len;
        if  (currentLetter != "|" && currentLetter != "") currentLetter = "";
        else if (currentWord.length() != 0) {
          len = currentWord.length();
          currentWord = currentWord.substring(0, len-1);
          currentLetter = "";
        } else if (currentTyped.length() != 0) { 
          len = currentTyped.length();
          if (currentTyped.charAt(len-1) == ' ') { // se o caracter que vai ser apagado e um espaco
            currentTyped = currentTyped.substring(0, len-1);
            if (len > 1 && currentTyped.charAt(len-2) != ' ') {
              words = currentTyped.split(" ");
              word = words[words.length-1];
              currentWord = word;
              currentLetter = "";
              currentTyped = currentTyped.substring(0, len-1 - word.length());
            }
          }
        }
        if (currentWord.length() == 0) currentLetter = "|"; //apagou uma palavra inteira
        possibleWord = "";
      }

      //if ENTER is pressed...
      button = buttonsArray.get(4);
      if (didMouseClick(button.x, button.y, button.w, button.h) && currentWord != "") {
        currentWord = possibleWord;
        currentTyped += currentWord + " ";
        currentLetter = "|";
        currentWord = "";
        possibleWord= "";
      }
    }
  }
}


void nextTrial() {
  if (currTrialNum >= NUM_REPEATS) return;                                            // check to see if experiment is done

  // Check if we're in the middle of the tests
  else if (startTime != 0 && finishTime == 0) {
    currentTyped += currentWord;
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + NUM_REPEATS);
    System.out.println("Target phrase: " + currentPhrase);
    System.out.println("Phrase length: " + currentPhrase.length());
    System.out.println("User typed: " + currentTyped);
    System.out.println("User typed length: " + currentTyped.length());
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim()));
    System.out.println("Time taken on this trial: " + (millis() - lastTime));
    System.out.println("Time taken since beginning: " + (millis() - startTime));
    System.out.println("==================");
    charsEnteredTotal += currentTyped.length();
    lettersExpectedTotal += currentPhrase.trim().length();
    lettersEnteredTotal += currentTyped.trim().length();
    errorsTotal += computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  // Check to see if experiment just finished
  if (currTrialNum == NUM_REPEATS - 1) {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime));
    System.out.println("Total letters entered: " + lettersEnteredTotal);
    System.out.println("Total letters expected: " + lettersExpectedTotal);
    System.out.println("Total errors entered: " + errorsTotal);

    float cps = (charsEnteredTotal) / ((finishTime - startTime) / 1000f);
    float wpm = (lettersEnteredTotal / 5.0f) / ((finishTime - startTime) / 60000f);   // FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal * .05;                                 // no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal - freebieErrors, 0) * .5f;

    System.out.println("Raw CPS: " + cps);
    System.out.println("Raw WPM: " + wpm);
    System.out.println("Freebie errors: " + freebieErrors);
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm - penalty));                         // yes, minus, because higher WPM is better
    System.out.println("==================");

    printResults(cps, wpm, freebieErrors, penalty);

    currTrialNum++;                                                                   // increment by one so this mesage only appears once when all trials are done
    return;
  } else if (startTime == 0) {                                                            // first trial starting now
    System.out.println("Trials beginning! Starting timer...");
    startTime = millis();                                                             // start the timer!
  } else currTrialNum++;                                                                // increment trial number

  lastTime = millis();                                                                // record the time of when this trial ended
  currentTyped = "";        // clear what is currently typed preparing for next trial
  currentWord = "";
  currentLetter = "|";
  possibleWord = "";
  currentPhrase = phrases[currTrialNum];                                              // load the next phrase!
}

// Print results at the end of the study
void printResults(float cps, float wpm, float freebieErrors, float penalty) {
  background(0);       // clears screen

  textFont(createFont("Arial", 16));    // sets the font to Arial size 16
  fill(255);    //set text fill color to white
  text(day() + "/" + month() + "/" + year() + "  " + hour() + ":" + minute() + ":" + second(), 100, 20);   // display time on screen

  text("Finished!", width / 2, height / 2); 
  text("Raw WPM: " + wpm, width / 2, height / 2 + 20);
  text("Raw CPS: " + cps, width / 2, height / 2 + 40);
  text("Freebie errors: " + freebieErrors, width / 2, height / 2 + 60);
  text("Penalty: " + penalty, width / 2, height / 2 + 80);
  text("WPM with penalty: " + (wpm - penalty), width / 2, height / 2 + 100);

  saveFrame("results-######.png");    // saves screenshot in current folder
}

// This computes the error between two strings (i.e., original phrase and user input)
int computeLevenshteinDistance(String phrase1, String phrase2) {
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++) distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++) distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
