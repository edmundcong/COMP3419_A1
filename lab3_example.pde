// Example for COMP3615 WEEK06 TASK 1
// @Author : Siqi
// For your assignment option 1, 
// it is cozy to play the video in the 'draw()'
// and draw your objects at each frame
// After drawing all the objects just call 'saveFrame()'
// Use 'Tools->Movie Maker' to combine all the saved frames

import processing.video.*;
import java.util.*;
import java.lang.*;
Movie m; 

List<PImage[]> frames = new ArrayList<PImage[]>(); // array list of frames
int frameCounter = 0;
int K = 197;
int totalGridBlocks;
boolean playImages = false;
int currFrame = 0;
int globalWidth = (720 + K - 1) / K; // rounds up
int globalHeight = (576 + K - 1) / K; // rounds up
// displacement vector
int displacement_vector[][][] = new int[globalWidth][globalHeight][2]; // 0 -> x, 1 -> y
int coords[][] = new int[(globalWidth*globalWidth)+globalHeight][2]; // 0 -> x, 1 -> y

int framenumber = 1; 
int phase = 1; // The phase for precessing pipeline : 1, saving frames of background; 2. overwrite the background frames with 
int bgctr = 1; // The total number of background frames
int BLUE = 120; // I did not tune this much, keep tunning
// Also try to include Red and Green in your 
// criteria to achieve better segmentation 
PImage bg;
PImage monkeyframe;

void setup() { 
  size(720, 576); //Just large enough to see what is happening
  frameRate(120); // Make your draw function run faster
  //create a Movie object. 
  m = new Movie(this, sketchPath("monkey.avi")); 
  m.frameRate(120); // Play your movie faster

  framenumber = 0; 
  fill(255, 255, 0); // Make the drawing colour yellow

  //play the movie one time, no looping
  m.play();
} 

void draw() { 
  if (playImages) {
    PImage currFrameArray[] = frames.get(currFrame);
    int chunkHeight = globalHeight/totalGridBlocks;
    int chunkWidth = globalWidth/totalGridBlocks;
    m.read(); 
    image(m, 0, 0);
    for (int i = 0; i < totalGridBlocks; i++) {
      System.out.println("chunkWidth: " + chunkWidth + "*" + i + " = " + chunkWidth*i + " chunkHeight: " + chunkHeight + "*" + i + " = " + chunkHeight*i);
      image(currFrameArray[i], chunkWidth*i, chunkHeight*i); 
    }
    currFrame++;
    //System.out.println("currFrame: " + currFrame + " frameCounter: " + frameCounter);
    if (currFrame >= frameCounter) {
     exit(); 
    }
  } else {
  
  // Clear the background with black colour
  float time = m.time();
  float duration = m.duration();
  float whereweare = time / duration;
  //System.out.println("here");
  //block(m);
  if ( time >= duration ) { 
    if (phase == 1) {
      m = new Movie(this, sketchPath("monkey.avi"));
      m.frameRate(120); // Play your movie faster
      m.play();
      phase = 2;
      bgctr = framenumber;
      framenumber = 1;
    } else if (phase == 2) {
      exit(); // End the program when the second movie finishes
    }
  }

  if (m.available()) {
    background(0, 0, 0);
    m.read(); 
    if (phase == 1) {
      block(m);
      frameCounter++;  
      //image(m, 0, 0);
      //m.save(sketchPath("") + "BG/"+nf(framenumber, 4) + ".tif"); // They say tiff is faster to save, but larger in disks
    } else if (phase == 2) {
      // step 2 of the meta-algorithm
      for (int i = 0; i < frameCounter; i++){
        // find the block with the minimum SSD
        if (i+1 < frameCounter) {
         PImage B_i[] = frames.get(i); // frame i
         PImage B_j[] = frames.get(i+1); // frame i+1
         int min_ssd_index = 0;
         for (int j = 0; j <  totalGridBlocks; j++){
           int width = B_i[j].width;
           int height = B_i[j].height;
           float min_ssd = 0;
           int new_x, new_y = 0;
           for (int k = 0; k < totalGridBlocks; k++) {
             // (x,y) and (x',y')
             float diff = 0;
             float ssd = 0;
             for (int x = 0; x < width; x++) {
               for (int y = 0; y < height; y++) {
                 // gotta get absolute difference
                 color temp_i = B_i[j].pixels[y*width+x];
                 color temp_j = B_j[k].pixels[y*width+x];
                 diff = (blue(temp_i) - blue(temp_j)) + (red(temp_i) - red(temp_j)) + (green(temp_i) - green(temp_j));
                 ssd += sqrt(diff*diff);
               }  
             }
             if (k == 0) {
               min_ssd = ssd;
               min_ssd_index = k;
             } else if (ssd < min_ssd) {
               min_ssd = ssd;
               min_ssd_index = k;
             }
           }
           //displacement_vector[i][j][0]
           //if (min_ssd > 0) System.out.println(min_ssd_index);
           }
           B_j[min_ssd_index].filter(INVERT);
           frames.set(i+1, B_j);
         }
        }
        playImages = true;
        //for (int i = 0; i < frameCounter; i++) {
        //  System.out.println("frameCounter: " + i);
        //  PImage temp[] = frames.get(i);
        //  drawImage(temp);
          //for (int j = 0; j < totalGridBlocks; i++) {
             //PImage temp_img = temp[j];
              //temp_img.save(sketchPath("") + "BG/"+nf(i, 4) + nf(j, 4) + ".jpg"); // They say tiff is faster to save, but larger in disks
             //image(temp[0], totalGridBlocks*3*i, totalGridBlocks*6*i); 
          //}
        //}
          //for (int i = 0; i < counter; i++) {
          //   image(frameBlocks[i], totalGridBlocks*3*i, totalGridBlocks*3*i); 
          //}
         //exit();
      }
      //monkeyframe = removeBackground(m);
      //bg = loadImage(sketchPath("") + "BG/"+nf(framenumber % bgctr, 4) + ".tif");

      //// Overwrite the background 
      //for (int x = 0; x < monkeyframe.width; x++)
      //  for (int y = 0; y < monkeyframe.height; y++) {
      //    int mloc = x + y * monkeyframe.width;
      //    color mc = monkeyframe.pixels[mloc];

      //    if (mc != -1) {
      //      // To control where you draw the monkey
      //      // You can tweak the destination position of the monkey like
      //      int bgx = constrain(x + 500, 0, bg.width);
      //      int bgy = constrain(y + 60, 0, bg.height);
      //      int bgloc = bgx + bgy * bg.width;
      //      bg.pixels[bgloc] = mc;
      //    }
      //  }

      //bg.updatePixels();
      //image(bg, 0, 0);
      //float ex = whereweare * bg.width;
      //float ey = whereweare * bg.height;
      //ellipse( ex, ey, 10, 10);

      //textSize(10);
      //text(String.format("I am at : (%.1f, %.1f)", ex, ey), ex + 10, ey + 5);

      //// In the second phase, we just saveframe, since we would like to include the objects we drew
      //// I am drawing some thing at the same time.
      //saveFrame(sketchPath("") + "/composite/" + nf(framenumber, 4) + ".tif");
    }

    textSize(20);
    text(String.format("Phase - %d - %.2f%%", phase, 100 * time / duration), 100, 80); // Display the text to show where you are in the pipeline

    System.out.printf("Phase: %d - Frame %d\n", phase, framenumber);
    framenumber++;
  }
}
// Called every time a new frame is available to read 
void movieEvent(Movie m) {
} 

void drawImage(PImage frameBlocks[]) {
    for (int i = 0; i < totalGridBlocks; i++) {
     System.out.println("totalGridBlocks: " + i);
     //image(frameBlocks[i], totalGridBlocks*3*i, totalGridBlocks*3*i); 
    }
}

PImage block(PImage frame) {
  //image(frame,0,0);
  // uses 3 step search see https://en.wikipedia.org/wiki/Block-matching_algorithm#Three_Step_Search
  // https://au.mathworks.com/help/vision/ref/blockmatching.html
  // step 1 of the meta-algorithm: dividing the frame into K blocks
  int frameWidth = globalWidth = frame.width;
  int frameHeight = globalHeight = frame.height;
  totalGridBlocks = round( (float) (frameWidth*frameHeight)/(K*K)) + 1;
  PImage frameBlocks[] = new PImage[totalGridBlocks];
  int counter = 0;
    //System.out.println("totalGridBlocks: "+totalGridBlocks);
    for (int x = 0; x < frameWidth; x+=K) {
     for (int y = 0; y < frameHeight; y+=K) {
        //System.out.println("x, y: " + x + " " + y);
        PImage temp = frame.get(x,y,(int) frameWidth/totalGridBlocks, (int) frameHeight/totalGridBlocks);
        image(temp, 0, 0);
        System.out.println(counter + " : " + totalGridBlocks);
        //coords[y*width+x][0] = x;
        //coords[y*width+x][1] = y;
        frameBlocks[counter] = temp;
        counter++;
        System.out.println("counter: " + counter + " tgb: " + totalGridBlocks);
    }
  }
  //System.out.println("counter: " + counter + " other one: " + totalGridBlocks);
  //for (int i = 0; i < counter; i++) {
  //   image(frameBlocks[i], totalGridBlocks*3*i, totalGridBlocks*3*i); 
  //}
  
  //System.out.println("counter: " + counter);
  frames.add(frameCounter, frameBlocks);
  // this will produce an error on the last frame so ill need to counteract this
  return frame;
}

PImage removeBackground(PImage frame) {
  for (int x = 0; x < frame.width; x ++)
    for (int y = 0; y < frame.height; y ++) {
      int loc = x + y * frame.width;
      color c = frame.pixels[loc];
      if ( blue(c) > BLUE) { 
        frame.pixels[loc] = -1;
      }
    }

  frame.updatePixels();

  return frame;
}