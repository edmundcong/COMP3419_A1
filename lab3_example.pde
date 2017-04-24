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

List < PImage[] > frames = new ArrayList < PImage[] > (); // array list of frames
int frameCounter = 0;
int K = 197;
int totalGridBlocks;
boolean playImages = false;
int currFrame = 0;
int globalWidth = (720 + K - 1) / K; // rounds up
int globalHeight = (576 + K - 1) / K; // rounds up
// displacement vector
//int displacement_vector[][][] = new int[globalWidth][globalHeight][2]; // 0 -> x, 1 -> y
//int coords[][] = new int[(globalWidth*globalWidth)+globalHeight][2]; // 0 -> x, 1 -> y

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
            //System.out.println("here at 51");
            PImage currFrameArray[] = frames.get(currFrame);
            int chunkHeight = globalHeight / totalGridBlocks;
            int chunkWidth = globalWidth / totalGridBlocks;
            //m.read(); 
            //image(m, 0, 0);
            int frameWidth, frameHeight = 0;
            for (int i = 0; i < totalGridBlocks; i++) {
                //System.out.println("chunkWidth: " + chunkWidth + "*" + i + " = " + chunkWidth * i + " chunkHeight: " + chunkHeight + "*" + i + " = " + chunkHeight * i);
                frameWidth = currFrameArray[i].width;
                frameHeight = currFrameArray[i].height;
                int counter_t = 0;
                for (int x = 0; x < globalWidth; x += K) {
                    for (int y = 0; y < globalHeight; y += K) {
                        //System.out.println("x, y: " + x + " " + y);
                        // fw/(fw/k/) and fh/(fh/k) will yield values for accurately displaying our image
                        //image(temp, 0, 0);
                        if (counter_t >= 2) {
                            image(currFrameArray[counter_t - 2], x, 0);
                            image(currFrameArray[counter_t - 1], x, 197);
                            image(currFrameArray[counter_t], x, 394);
                        } else if (counter_t >= 1) {
                            image(currFrameArray[counter_t - 1], x, 0);
                            image(currFrameArray[counter_t], x, 197);
                        }
                        counter_t++;
                        //System.out.println("x: " + x + " y: " + y);
                    }
                }
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
            if (time >= duration) {
                if (phase == 1) {
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
                }
            } else {
                if (phase == 2) {
                    // step 2 of the meta-algorithm
                    System.out.println("frameCounter is: " + frameCounter);
                    for (int i = 0; i < frameCounter; i++) {
                        // find the block with the minimum SSD
                        if (i + 1 < frameCounter) {
                            PImage B_i[] = frames.get(i); // array of blocks for frame i
                            PImage B_j[] = frames.get(i + 1); // array of blocks for frame i+1
                            int displacement_vector[][][] = new int[globalWidth/K][globalHeight/K][2]; // 0 -> x, 1 -> y
                            int min_ssd_index = 0;
                            // for each frame we will look at the 12 grid blocks within it and the next frame
                            for (int j = 0; j < totalGridBlocks; j++) {
                                int width = B_i[j].width; // get j'th frame width
                                int height = B_i[j].height; // and height
                                float min_ssd = 0;
                                int curr_x = (width/totalGridBlocks) * j;
                                int curr_y = (height/totalGridBlocks) * j;
                                int min_x = 0;
                                int min_y = 0;
                                int displacement_x, displacement_y = 0;
                                for (int k = 0; k < totalGridBlocks; k++) {  
                                    // (x,y) and (x',y')
                                    float diff = 0;
                                    float ssd = 0;
                                    int next_frame_width = B_j[k].width;
                                    // compare difference of pixels of our current frame's ith block against all the blocks in our i+1 frame
                                    for (int x = 0; x < width; x++) {
                                        for (int y = 0; y < height; y++) {
                                            color temp_i = B_i[j].pixels[y * width + x];
                                            color temp_j = B_j[k].pixels[y * next_frame_width + x];
                                            diff = (blue(temp_i) - blue(temp_j)) + (red(temp_i) - red(temp_j)) + (green(temp_i) - green(temp_j));
                                            ssd += sqrt(diff * diff);
                                        }
                                    }
                                    if (k == 0) {
                                        min_ssd = ssd;
                                        min_ssd_index = k;
                                        min_x = (width/totalGridBlocks) * k;
                                        min_y = (height/totalGridBlocks) * k;
                                    } else if (ssd < min_ssd) {
                                        min_ssd = ssd;
                                        min_ssd_index = k;
                                        min_x = (width/totalGridBlocks) * k;
                                        min_y = (height/totalGridBlocks) * k;
                                    }
                                }
                                // step 3 of the meta-algorithm
                                // we've got the i+1 block that has the lowest ssd to our ith block. time to get the displacement vector
                                // time to save each displacement vector of frame F_i to a data structure
                                //displacement_x = min_x - curr_x;
                                //displacement_y = min_y - curr_y;
                                //displacement_vector[j][min_ssd_index][0] = displacement_x;
                                //displacement_vector[j][min_ssd_index][1] = displacement_y;
                                if (min_ssd_index != j) {
                                  System.out.println("for block " + j + " the matching block is " + min_ssd_index);
                                  B_j[min_ssd_index].filter(GRAY);
                                }
                            }
                            // min_ssd_index is the block in our next frame (j aka i+1) that has the smallest ssd
                            //B_j[min_ssd_index].filter(INVERT);

                            // get the displacement vector of B_i -> B_i+1
                            System.out.println((float) i / frameCounter + "% done");
                            frames.set(i + 1, B_j);
                        }
                    }
                    playImages = true;
                }
            }

            textSize(20);
            text(String.format("Analysing Phase - %d - %.2f%%", phase, 100 * time / duration), 100, 80); // Display the text to show where you are in the pipeline

            System.out.printf("Phase: %d - Frame %d\n", phase, framenumber);
            framenumber++;
        }
    }
    // Called every time a new frame is available to read 
void movieEvent(Movie m) {

  }

PImage block(PImage frame) {
    //image(frame,0,0);
    // uses 3 step search see https://en.wikipedia.org/wiki/Block-matching_algorithm#Three_Step_Search
    // https://au.mathworks.com/help/vision/ref/blockmatching.html
    // step 1 of the meta-algorithm: dividing the frame into K blocks
    int frameWidth = globalWidth = frame.width;
    int frameHeight = globalHeight = frame.height;
    totalGridBlocks = ceil((float)(frameWidth * frameHeight) / (K * K)) + 1;
    PImage frameBlocks[] = new PImage[totalGridBlocks];
    int counter = 0;
    PImage temp;
    //System.out.println("totalGridBlocks: "+totalGridBlocks);
    //System.out.println(((float) frameWidth/(float) K)*((float) frameHeight/(float) K));
    for (int x = 0; x < frameWidth; x += K) {
        for (int y = 0; y < frameHeight; y += K) {
            // fw/(fw/k/) and fh/(fh/k) will yield values for accurately displaying our image
            temp = frame.get(x, y, (int) frameWidth / (frameWidth / K), (int) frameHeight / (frameHeight / K));
            frameBlocks[counter] = temp;
            counter++;
        }
    }
    frames.add(frameCounter, frameBlocks);
    System.out.println("frame size is: " + frameCounter);
    return frame;
}

PImage removeBackground(PImage frame) {
    for (int x = 0; x < frame.width; x++)
        for (int y = 0; y < frame.height; y++) {
            int loc = x + y * frame.width;
            color c = frame.pixels[loc];
            if (blue(c) > BLUE) {
                frame.pixels[loc] = -1;
            }
        }

    frame.updatePixels();

    return frame;
}