// Bakeoff #2 - Seleção de Alvos e Fatores Humanos //<>// //<>//
// IPM 2019-20, Semestre 2
// Bake-off: durante a aula de lab da semana de 20 de Abril
// Submissão via Twitter: exclusivamente no dia 24 de Abril, até às 23h59

// Processing reference: https://processing.org/reference/

import java.util.Collections;

// Target properties
float PPI, PPCM;
float SCALE_FACTOR;
float TARGET_SIZE;
float TARGET_PADDING, MARGIN, LEFT_PADDING, TOP_PADDING;

// Study properties
ArrayList<Integer> trials  = new ArrayList<Integer>();    // contains the order of targets that activate in the test
int trialNum               = 0;                           // the current trial number (indexes into trials array above)
final int NUM_REPEATS      = 3;                           // sets the number of times each target repeats in the test - FOR THE BAKEOFF NEEDS TO BE 3!
boolean ended              = false;
float[] fitts              = new float[48];

BullsEye bullsEye;

int time;
int wait = 50;


// Performance variables
int startTime              = 0;      // time starts when the first click is captured
int finishTime             = 0;      // records the time of the final click
int hits                   = 0;      // number of successful clicks
int misses                 = 0;      // number of missed clicks

// Class used to store properties of a target
class Target {
    int x, y;
    float w;

    Target(int posx, int posy, float twidth) {
        x = posx;
        y = posy;
        w = twidth;
    }
}

class BullsEye {
    int x, y, nx, ny, xincrement, yincrement;
    int frames = 3;
    float w;

    BullsEye(Target target) {
        x = target.x;
        y = target.y;
        w = target.w;
        nx = target.x;
        ny = target.y;
        xincrement = 0;
        yincrement = 0;
    }

    void move() {
        if (abs(nx-x) < abs(xincrement))
            x = nx;
        else
            x+=xincrement;
        if (abs(ny-y) < abs(yincrement))
            y = ny;
        else
            y+=yincrement;
    }

    void setNext(Target target) {
        nx = target.x;
        ny = target.y;
        xincrement = int((nx-x)/frames);
        yincrement = int((ny-y)/frames);
    }

    void display() {
        color blue = color(0, 128, 255);
        color green = color(0, 255, 0);
        color yellow = color(255, 255, 0);
        color orange = color(255, 128, 0);
        color red = color(255, 0, 0);
        color circle1 = lerpColor(blue, red, .33);
        color circle2 = lerpColor(blue, green, 0);
        color circle3 = lerpColor(blue, green, .33);
        color circle4 = lerpColor(blue, green, .66);
        color circle5 = lerpColor(green, yellow, .33);
        color circle6 = lerpColor(green, yellow, 1);
        color circle7 = lerpColor(yellow, orange, .33);
        color circle8 = lerpColor(yellow, orange, .66);
        color circle9 = lerpColor(orange, red, 0);
        color circle10 = lerpColor(orange, red, .33);
        color circle11 = lerpColor(orange, red, .66);
        fill(circle1);
        circle(x, y, w + 77);
        fill(circle2);
        circle(x, y, w + 70);
        fill(circle3);
        circle(x, y, w + 63);
        fill(circle4);
        circle(x, y, w + 56);
        fill(circle5);
        circle(x, y, w + 49);
        fill(circle6);
        circle(x, y, w + 42);
        fill(circle7);
        circle(x, y, w + 35);
        fill(circle8);
        circle(x, y, w + 28);
        fill(circle9);
        circle(x, y, w + 21);
        fill(circle10);
        circle(x, y, w + 14);
        fill(circle11);
        circle(x, y, w + 7);
    }
    void smoothDisplay() {
        color blue = color(0, 128, 255);
        color green = color(0, 255, 0);
        color yellow = color(255, 255, 0);
        color orange = color(255, 128, 0);
        color red = color(255, 0, 0);
        color circle1 = lerpColor(blue, red, .33);
        color circle2 = lerpColor(blue, green, 0);
        color circle3 = lerpColor(blue, green, .33);
        color circle4 = lerpColor(blue, green, .66);
        color circle5 = lerpColor(green, yellow, .33);
        color circle6 = lerpColor(green, yellow, 1);
        color circle7 = lerpColor(yellow, orange, .33);
        color circle8 = lerpColor(yellow, orange, .66);
        color circle9 = lerpColor(orange, red, 0);
        color circle10 = lerpColor(orange, red, .33);
        color circle11 = lerpColor(orange, red, .66);
        fill(circle1);
        if (millis() - time >= 1*wait) circle(x, y, w + 77);
        fill(circle2);
        if (millis() - time >= 2*wait) circle(x, y, w + 70);
        fill(circle3);
        if (millis() - time >= 3*wait) circle(x, y, w + 63);
        fill(circle4);
        if (millis() - time >= 4*wait) circle(x, y, w + 56);
        fill(circle5);
        if (millis() - time >= 5*wait) circle(x, y, w + 49);
        fill(circle6);
        if (millis() - time >= 6*wait) circle(x, y, w + 42);
        fill(circle7);
        if (millis() - time >= 7*wait) circle(x, y, w + 35);
        fill(circle8);
        if (millis() - time >= 8*wait) circle(x, y, w + 28);
        fill(circle9);
        if (millis() - time >= 9*wait) circle(x, y, w + 21);
        fill(circle10);
        if (millis() - time >= 10*wait) circle(x, y, w + 14);
        fill(circle11);
        if (millis() - time >= 11*wait) circle(x, y, w + 7);
    }
}

void arrow(float x1, float y1, float x2, float y2, float w) {
    PVector p = new PVector( x2-x1, y2-y1, 0);
    PVector q = new PVector( x2-x1, y2-y1, 0);
    p.limit(w);
    q.limit(dist(x1, y1, x2, y2)-(w/2+15));
    strokeWeight(5);
    stroke(255, 255, 0);
    line(x1+p.x, y1+p.y, x1+q.x, y1+q.y );
    pushMatrix();
    translate( x1+q.x, y1+q.y );
    p.limit(20);
    rotate(radians(30));
    line(0, 0, -p.x, -p.y);
    rotate(radians(-60));
    line(0, 0, -p.x, -p.y);
    popMatrix();
    noStroke();
}

// Setup window and vars - runs once
void setup() {
    //size(900, 900);              // window size in px (use for debugging)
    fullScreen();                // USE THIS DURING THE BAKEOFF!
  
    SCALE_FACTOR    = 1.0 / displayDensity();            // scale factor for high-density displays
    String[] ppi_string = loadStrings("ppi.txt");        // The text from the file is loaded into an array.
    PPI            = float(ppi_string[1]);               // set PPI, we assume the ppi value is in the second line of the .txt
    PPCM           = PPI / 2.54 * SCALE_FACTOR;          // do not change this!
    TARGET_SIZE    = 1.5 * PPCM;                         // set the target size in cm; do not change this!
    TARGET_PADDING = 1.5 * PPCM;                         // set the padding around the targets in cm; do not change this!
    MARGIN         = 1.5 * PPCM;                         // set the margin around the targets in cm; do not change this!
    LEFT_PADDING   = width/2 - TARGET_SIZE - 1.5*TARGET_PADDING - 1.5*MARGIN;        // set the margin of the grid of targets to the left of the canvas; do not change this!
    TOP_PADDING    = height/2 - TARGET_SIZE - 1.5*TARGET_PADDING - 1.5*MARGIN;       // set the margin of the grid of targets to the top of the canvas; do not change this!
  
    noStroke();        // draw shapes without outlines
    frameRate(60);     // set frame rate

    // Text and font setup
    textFont(createFont("Arial", 16));    // sets the font to Arial size 16
    textAlign(CENTER);                    // align text
  
    randomizeTrials();    // randomize the trial order for each participant

    Target target = getTargetBounds(trials.get(trialNum));
    bullsEye = new BullsEye(target);
    
    time = millis();//store the current time
}

// Updates UI - this method is constantly being called and drawing targets
void draw() {
    if (hasEnded()) return; // nothing else to do; study is over

    background(0);       // set background to black

    // Print trial count
    fill(255);          // set text fill color to white
    text("Trial " + (trialNum + 1) + " of " + trials.size(), 60, 20);    // display what trial the participant is on (the top-left corner)
    
    // Draw BullsEye
    if (trialNum != 0) {
        Target current = getTargetBounds(trials.get(trialNum));
        Target previous = getTargetBounds(trials.get(trialNum - 1));
        if (current.x == previous.x && current.y == previous.y)
            bullsEye.smoothDisplay();
        /*
        
        if (current.x == next.x && current.y == next.y && millis() - time >= wait) {
            time = millis();//also update the stored time  
        }
        else bullsEye.display();*/
        else bullsEye.display();
    }
    else bullsEye.display();

    // Move BullsEye
    if (bullsEye.x != bullsEye.nx || bullsEye.y != bullsEye.ny)
        bullsEye.move();

    // Draw targets
    for (int i = 0; i < 16; i++) drawTarget(i);

    // Draw Arrow pointing to next target
    if (trialNum != trials.size()-1) {
        Target current = getTargetBounds(trials.get(trialNum));
        Target next = getTargetBounds(trials.get(trialNum + 1));
        if (current.x != next.x || current.y != next.y)
            arrow(current.x, current.y, next.x, next.y, current.w);
    }
}

boolean hasEnded() {
    if (ended) return true;    // returns if test has ended before

    // Check if the study is over
    if (trialNum >= trials.size()) {
        float timeTaken = (finishTime-startTime) / 1000f;     // convert to seconds - DO NOT CHANGE!
        float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f), 0, 100);    // calculate penalty - DO NOT CHANGE!

        printResults(timeTaken, penalty);    // prints study results on-screen
        ended = true;
    }
    
    return ended;
}

// Randomize the order in the targets to be selected
// DO NOT CHANGE THIS METHOD!
void randomizeTrials() {
    for (int i = 0; i < 16; i++)             // 4 rows times 4 columns = 16 target
        for (int k = 0; k < NUM_REPEATS; k++)  // each target will repeat 'NUM_REPEATS' times
            trials.add(i);
    Collections.shuffle(trials);             // randomize the trial order

    System.out.println("trial order: " + trials);    // prints trial order - for debug purposes
}

// Print results at the end of the study
void printResults(float timeTaken, float penalty) {
    background(0);       // clears screen
    float y = height / 8;
    fill(255);    //set text fill color to white
    text(day() + "/" + month() + "/" + year() + "  " + hour() + ":" + minute() + ":" + second(), 100, 20);   // display time on screen

    text("Finished!", width / 2, y); y += 20;
    text("Hits: " + hits, width / 2, y); y += 20;
    text("Misses: " + misses, width / 2, y); y+= 20;
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, y); y += 20;
    text("Total time taken: " + timeTaken + " sec", width / 2, y); y += 20;
    text("Average time for each target: " + nf((timeTaken)/(float)(hits+misses), 0, 3) + " sec", width / 2, y); y += 20;
    text("Average time for each target + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty), 0, 3) + " sec", width / 2, y); y += 40;
    text("Fitts Index of Performance", width / 2, y); y += 40;
    float w = width / 2 - 100;
    float h = y;
    for (int i = 0; i < 48; i++) {
        if (i == 0)
            text("Target " + (i+1) + ": " + "---", w, y);
        else if (fitts[i] != -1)
            text("Target " + (i+1) + ": " + fitts[i], w, y);
        else
            text("Target " + (i+1) + ": MISSED", w, y);
        y += 20;
        if (i == 23) {
            y = h;
            w = width / 2 + 100;
        }
    }
    saveFrame("results-######.png");    // saves screenshot in current folder
}

// Mouse button was released - lets test to see if hit was in the correct target
void mouseReleased() {
    time = millis();//also update the stored time
    
    if (trialNum >= trials.size()) return;      // if study is over, just return
    if (trialNum == 0) startTime = millis();    // check if first click, if so, start timer
    if (trialNum == trials.size() - 1) {        // check if final click
        finishTime = millis();    // save final timestamp
        println("We're done!");
    }
    
    float hit = 0;
    Target target = getTargetBounds(trials.get(trialNum));    // get the location and size for the target in the current trial

    if (trialNum > 0) {
        Target target2 = getTargetBounds(trials.get(trialNum-1));
        hit = log((dist(target2.x, target2.y, target.x, target.y)/TARGET_SIZE)+1)/log(2);
    }

    // Check to see if mouse cursor is inside the target bounds
    if (dist(target.x, target.y, mouseX, mouseY) < target.w/2) {
        System.out.println("HIT! " + trialNum + " " + (millis() - startTime));     // success - hit!
        fitts[trialNum] = hit;
        hits++; // increases hits counter
    } else {
        System.out.println("MISSED! " + trialNum + " " + (millis() - startTime));  // fail
        fitts[trialNum] = -1;
        misses++;   // increases misses counter
    }

    trialNum++;   // move on to the next trial; UI will be updated on the next draw() cycle

    // set the corrdenates for the next target's bullsEye
    if (trialNum < 48)
        bullsEye.setNext(getTargetBounds(trials.get(trialNum)));
}

// For a given target ID, returns its location and size
Target getTargetBounds(int i) {
    int x = (int)LEFT_PADDING + (int)((i % 4) * (TARGET_SIZE + TARGET_PADDING) + MARGIN);
    int y = (int)TOP_PADDING + (int)((i / 4) * (TARGET_SIZE + TARGET_PADDING) + MARGIN);
    return new Target(x, y, TARGET_SIZE);
}

// Draw target on-screen
// This method is called in every draw cycle; you can update the target's UI here
void drawTarget(int i) {
    Target target = getTargetBounds(i);   // get the location and size for the circle with ID:i

    if (trialNum != trials.size()-1 && trials.get(trialNum+1) == i && trials.get(trialNum) != i) {
        stroke(255, 255, 0);
        strokeWeight(5);
    }

    fill(60);
    circle(target.x, target.y, target.w);

    if (trials.get(trialNum) == i) { // check whether current circle is the intended target
        fill(255, 255, 255);
        stroke(255,0,0);
        strokeWeight(3);
        circle(target.x, target.y, target.w);
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(20);
        if (trialNum != 0 && trials.get(trialNum-1) == i)
            text("HIT\nAGAIN", target.x, target.y-0.5);
        else
            text("HIT\nME", target.x, target.y-0.5);
        
    }
    
    noStroke();    // next targets won't have stroke (unless it is the intended target)
}
