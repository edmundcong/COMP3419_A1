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
int K = 23; // K
PImage temp_image; // current video frame
int total_movie_frames = 752;
int total_movie_frames_counter = 0;
int blocks_per_frame = 832; // blocks per frame when ceil'ing dimensions
int block_width = 32;
int block_height = 26;
// array of blocks for all frames
PImage frames_blocks[][][] = new PImage[total_movie_frames][block_width][block_height];
int displacement_vector[][][][] = new int[total_movie_frames][block_width][block_height][2]; // x -> 0, y -> 1
int movie_frame_height = 0;
int movie_frame_width = 0;
boolean play_movie = false;

void setup() {
  size(720, 576); //Just large enough to see what is happening
  frameRate(120); // Make your draw function run faster
  //create a Movie object. 
  m = new Movie(this, sketchPath("monkey.avi"));
  m.play();
}

// will continuously call draw after set up
void draw() {
  // we've analysed our entire video -- time to start macroblock'ing
  if (total_movie_frames_counter >= 752) {
    System.out.println("total_movie_frames_counter >= " + total_movie_frames_counter);
      if (play_movie) {
        for (int i = 0; i < total_movie_frames; i++ ) {
          int x_iterator = 0;
          int y_iterator = 0;
          float magnitude = 0; // will be 1/(x+y) 
          // merge images
          PGraphics output = createGraphics(720, 576, JAVA2D);
          output.beginDraw();
          for (int x = 0; x < movie_frame_width; x+=K) {
            for (int y = 0; y < movie_frame_height; y+=K) {
            /* Visualise the displacement fields with a 2D image with the same size as frame Fi. The same
               magnitude value is assigned to all the pixels within the region covered by a single grid block. */
                //if (displacement_vector[i][x_iterator][y_iterator][0] == 0 && displacement_vector[i][x_iterator][y_iterator][1] == 0) {
                  // our 2D image is our frame_blocks at i. At i the sum of our x and y arrays = a full image frame
                  //frames_blocks[i][x_iterator][y_iterator].filter(POSTERIZE, 2+(abs(displacement_vector[i][x_iterator][y_iterator][0])
                  //+ abs(displacement_vector[i][x_iterator][y_iterator][0])));
                  //magnitude = 1 + (abs(displacement_vector[i][x_iterator][y_iterator][0]) + abs(displacement_vector[i][x_iterator][y_iterator][0]));
                  
                  //output.image(frames_blocks[i][x_iterator][y_iterator], x, y);
                //} //else
                frames_blocks[i][x_iterator][y_iterator].filter(GRAY);
                output.image(frames_blocks[i][x_iterator][y_iterator], x, y);
              y_iterator++;
            }
            y_iterator = 0;
            x_iterator++;
          }
          output.endDraw();
          // output images
          output.save(sketchPath("") + "BG/i"+nf(i,4)+".tif"); // They say tiff is faster to save, but larger in     disks
          System.out.println((float) i / (float) total_movie_frames + "% complete for frame output");
        }
        System.out.println("Done!");
        System.exit(0); 
      }
      // perform SSD
      // for each grid block Bi in frame Fi
      PImage current_frame;
      PImage reference_frame;
      float SSD = 0;
      float diff = 0;
      float min_SSD = 0;
      int min_ssd_x = 0;
      int min_ssd_y = 0;
      // current and displacement coordinates
      int curr_x = 0;
      int curr_y = 0;
      int disp_x = 0;
      int disp_y = 0;
      
      boolean first = true; // flag for min_ssd initialisation on first iteration
      
      for (int i = 0; i < total_movie_frames - 1; i++) {
        for (int x = 0; x < block_width; x++) {
          curr_x = x*block_width;
          for (int y = 0; y < block_height; y++) {
            current_frame = frames_blocks[i][x][y];
            curr_y = y*block_height;
            min_ssd_x = 0;
            min_ssd_y = 0;
            disp_x = 0;
            disp_y = 0;
            first = true;
            min_SSD = 0;
            // search 1 grid block radius
            for (int x_x = x - 1; x_x <= x + 1; x_x++) { // x +- 1
              if (x_x < 0) x_x = 0;
              for (int y_y = y - 1; y_y <= y + 1; y_y++) { // y +- 1
                // edge cases
                if (y_y < 0) y_y = 0;
                reference_frame = frames_blocks[i+1][x_x][y_y];
                SSD = 0;
                diff = 0;
                for (int j = 0; j < reference_frame.width; j++) {
                  for (int k = 0; k < reference_frame.height; k++) {
                    color temp_i = current_frame.pixels[k * reference_frame.width + j];
                    color temp_j = reference_frame.pixels[k * reference_frame.width + j];
                    diff = (blue(temp_i) - blue(temp_j)) + (red(temp_i) - red(temp_j)) + (green(temp_i) - green(temp_j));
                    SSD += (diff * diff);
                  }  
                }
                SSD = sqrt(SSD);
                if (first == true) {
                  min_SSD = SSD;
                  min_ssd_x = x_x;
                  min_ssd_y = y_y;
                  disp_x = x_x*block_width;
                  disp_y = y_y*block_height;
                }
                first = false;
                //if (min_SSD > 4000) { // theshhold value
                  if (SSD < min_SSD) {
                     min_SSD = SSD;
                     min_ssd_x = x_x;
                     min_ssd_y = y_y;
                     disp_x = x_x*block_width;
                     disp_y = y_y*block_height;
                   }
                //}
                if (y_y == block_height - 1) break; // edge case since block height and width is out of bounds for array
              }
              if (x_x == block_width - 1) break;
            }
            displacement_vector[i+1][min_ssd_x][min_ssd_y][0] = disp_x - curr_x;
            displacement_vector[i+1][min_ssd_x][min_ssd_y][1] = disp_y - curr_y;
            
            //System.out.println("X,Y: ("+min_ssd_x+", "+min_ssd_y+")");
            //System.out.println("X: = ("+disp_x+", "+curr_x+") -> " + (disp_x-curr_x));
            //System.out.println("Y: = ("+disp_y+", "+curr_y+") -> " + (disp_y-curr_y));
            //frames_blocks[i+1][min_ssd_x][min_ssd_y].filter(GRAY);
          }
        }
        System.out.println((float) i/ (float) total_movie_frames + "% complete");
      }
      play_movie = true;
  } else { // otherwise we haven't finished analysing
    image(m, 0,0);
    System.out.println("The movie is " + total_movie_frames_counter + " frames in");
  }
}
// Called every time a new frame is available to read 
void movieEvent(Movie m) {
  m.read();
  // get current video frame asdsad
  temp_image = m.get(0,0,m.width,m.height);
  movie_frame_width =  (int) Math.ceil(temp_image.width); // ceil these dimensions
  movie_frame_height = (int) Math.ceil(temp_image.height);
  int x_iterator = 0;
  int y_iterator = 0;
  for (int x = 0; x < movie_frame_width; x+=K) {
   for (int y = 0; y < movie_frame_height; y+=K) {
     frames_blocks[total_movie_frames_counter][x_iterator][y_iterator] = temp_image.get(x, y, block_width, block_height);
     y_iterator++;
   }
   y_iterator = 0;
   x_iterator++;
  }
  total_movie_frames_counter++;
}