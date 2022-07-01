# Fully automatic HE Muscle Slide Segmentation and Analysis - A Fiji Toolset for Fibre Cells and Connective Tissue
This toolset for FIJI allows for fully automatic muscle fibre and connective tissue analysis. Additionally, heat maps, bounding boxes and local thickness for connective tissue images can be generated to visualize the obtained results. This FIJI toolset used and developed for the following paper:

# Requirements and Installation
## Requirements:
Fiji (https://imagej.net/software/fiji/). Version we used is v1.53f51.
You will need predicitions of your HE Muscle Slides in 8 bit format. The size, type and scale of your data can all be adjusted in the toolbox so as long as you have 8 bit predictions, this toolbox should work. You can obtain them using our model, use your own model or run other easy to use tools like Cellpose (https://www.cellpose.org/). 
You require 3 plugins for this toolset to work: 
```
BAR                     (Update Site: https://sites.imagej.net/Tiago/)
Biovoxxel Toolbox       (Update Site: https://sites.imagej.net/BioVoxxel/) 
IJPB-plugins            (Update Site: https://sites.imagej.net/IJPB-plugins/)
```
You can easily add them to your Fiji by pressing Help -> Update -> Manage Update Sites. Mark the checkboxes, let them install and then restart Fiji.

## Installation:
Add the "HE Muscle Segmentation Toolset.ijm" file from this repository to the following folder:
```
FIJI
  |______ macros
          |_____ toolsets -> put file here
```
To activate the toolset: press on the red arrow at the very right (red box), select HE Segmentation Toolset and then press on the icon that just appeared (yellow box).

![grafik](https://user-images.githubusercontent.com/90180771/176881747-65d73f4a-a88f-4a65-b2a9-a2a43d23ca5c.png)

Then, just select the command you wish to carry out. Detailed Explanation of the features can be found below.

# 1. Feature: Automated Muscle Analysis:
The main macro enables automated batch processing of 8 bit prediction images. First the input (ideally only containing the prediction maps) and output directory (ideally empty) have to be defined, then the following main dialog will open:

![grafik](https://user-images.githubusercontent.com/90180771/176905873-dc27bf0e-7500-49c2-969f-d1c117fc190a.png)

1. Set Scale: define the image scale[pixels per micrometer]. If a scale was set via “Analyze → Set Scale”, you can enter a 0 to keep the current scale.
2. Enter the suffix: Define the suffix (.png, .tif, etc.). of the input images (prediction maps). This is used to identify the images and also allows filtering from other files in the input folder.
3. Post Processing Algorithm: Choose one of three algorithms for watershed-based optimization of image segmentation.
    - None, recommended for very good prediction images
    - Watershed Irregular Features 10 Pixels (WIF10), recommended for good prediction images
Utilizes BioVoxxel’s Toolbox: 									       https://imagej.net/BioVoxxel_Toolbox.html#Watershed_Irregular_Features
    - Distance Transform Watershed 20 (DTW 20), recommended for poor prediction maps
Utilizes MorphoLibJ Plugin: https://imagej.net/Distance_Transform_Watershed
    - DTW 20-8, recommended for poor prediction maps including very large or small cells
    Note: If you obtain good prediction maps from the AI, little post processing will be required so WIF10 or no post processing is recommended. If suboptimal prediction maps were obtained use DTW20 and DTW20-8 and compare the results.
4. Prediction Map Threshold: Set the AI certainty threshold for the prediction maps. Note: the possible numbers range from 0-255. Higher numbers improve segmentation results but increase area errors, while lower numbers do the opposite. We recommend staying at 140.
5. Apply shape filters to filter out undesired cells. Most parameters should be self explanatory except for "Maximum AR" which stands for maximum aspect ratio and for further information on Feret visit: https://imagej.nih.gov/ij/docs/guide/146-30.html . The cell size threshold is in the given scale, not in pixels. Use aspect ratio, minFeret and cell size to get rid of large cells and cross sections. Use a stronger circularity filter to get rid of artifacts like bubbles.
6. Select this if you want holes inside cells to count towards their area and morphology.
7. If you made images containing whole muscle slices / slides, mark this checkbox. This changes some functions in this tool to produce better results and allows for:
8. an algorithm that clears potentially undesired smaller tissues around the main slice. Only works with whole slide images. Enter the size of the slices that you want to keep in the field. You can use feature #4 (Muscle Size Finder) to help you find correct values for this field. Example:

![grafik](https://user-images.githubusercontent.com/90180771/176902818-04c04c1a-bcae-498d-a1c5-e2b31fa63082.png)

9. Check if you want to analyse the connective tissue in the raw (non shape filtered images)
10. Analyses the connective tissue for the images with shape filtered cells.
11. The "Number of Dilate-Erode Loops" decides how many dilate operations are carried out before the object is eroded to its original size. In other words, if you have large holes in your sample, that are still supposed to be counted towards connective tissue, you need a relatively high amount of loops (10-15). If your cells are fairly close together and connective tissue is thin, lower values (5-10) will produce a lower error. You can use "Area Opening Value" (IN PIXELS!) to remove small remaining holes. We found 3500 worked well across the board, but this field allows the user to adjust the value if desired.
12. Two options here: it is possible to fully automatically generate local thickness maps of the connective tissue images, however this will greatly increase the computing time of this toolset. Select the other checkbox if the Muscle Border that was used for %area (CT / whole muslce) calculations should be visualized. Example:

![grafik](https://user-images.githubusercontent.com/90180771/176897927-2b010a0a-cbfc-49cb-aef9-5f5ac8845d6f.png)

13. Activates Fijis "Batch mode". As indicated, does not work with heat-maps. Limited function as tables are somtimes accessed that can interrupt your work.
14. Runs BioVoxxels 2D Particle Distribution (https://imagej.net/plugins/biovoxxel-toolbox#2d-particle-distribution) for the image.
15. Creates images with oriented bounding boxes for each object. Set the Options in 
16. width = the pixel size of the bounding box
17. Check which parameters you would like to use for heat-map generation. If none are selected, heat-map generation is skipped. Use the LUT selector to choose a color scheme. Example:

![grafik](https://user-images.githubusercontent.com/90180771/176905595-fbe374d6-5df2-417e-b5ed-0e057e94086a.png)

18. This generates small numbers in the middle of a cell in the heat-maps. Useful for finding outlier cells.
19. Instead of using Min - Max scaling for the heat-maps, instead takes mean +- std dev. Usually makes heat-maps much more informative.
20. instead of creating a individual, different scaling for each image, this creates a uniform scaling for all images. Uses the average+-stddev over ALL images.
21. If you want uniform heat-maps, but no individual ones, select this checkbox.

## Output:
Depending on the input during the main the following output is generated:
1. A folder for each original file containing all generated images of the respective file:

		- Minimal Threshold Image (Always)
		- Minimal Threshold Results (Always)
		- Raw Muscle Mask and / or Filtered Muscle Mask 
		- Raw Connective Tissue and / or Filtered Connective Tissue 
		- Shape Filtered Image
		- Results of Filtered, Cleared Outside, Connective Tissue Images
		- Additional Optional Images: Oriented Bounding Boxes and Heat Maps
    
2. Results Summary.csv containing the min, max, mean and stdDev values of all parameters in all images and the min, max, mean and stdDev over all images.
3. Results Summary Post Processed Only.csv is the same as (2.) except it uses the minimal post processing images.
4. Chosen Parameters.txt containing all the chosen parameters during the main dialog.
