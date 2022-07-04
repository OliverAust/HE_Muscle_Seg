# Fully automatic HE Muscle Slide Segmentation and Analysis - A Fiji Toolset for Muscle Fibers and Connective Tissue
This toolset for FIJI allows for fully automatic muscle fibers and connective tissue analysis. Additionally, heat maps, bounding boxes and local thickness for connective tissue images can be generated to visualize the obtained results. This FIJI toolset used and developed for the following paper:

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
          |______ toolsets -> put file here
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
4. Prediction Map Threshold: Set the AI certainty threshold for the prediction maps. Note: the possible numbers range from 0-255. Higher numbers improve segmentation results but can increase area errors, while lower numbers do the opposite. Crucial parameter to adjust to your dataset as the confidence of any model will vary with the images given to it. 
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

# 2. Feature: Automated Cell Overlays:
Creates images, using the original image and the results. Gives every cell a different color for easy segmentation visualization. This is intended to facilitate verification of the results obtained from feature #1. Example:

![grafik](https://user-images.githubusercontent.com/90180771/176909363-09861888-346d-4590-927a-d89ab875c20e.png)

Executing this will first ask for three folders. First, select the directory that contains the original images, then select the folder with the images you would like to overlay (results) and the desired output folder. Then the main dialog will open:

![grafik](https://user-images.githubusercontent.com/90180771/176911456-00cc9e70-a41e-46d5-9d14-b0d6881b1bcf.png)

Important: The macro language in Fiji is file ending sensitive meaning if your original jpg image is called KOMouseMuscleSlice01_Image001 then it means that there is also a “.jpg” at the end of the image name! Depending on your Windows settings (Folder Options → View → Hide extensions for known file types) this file ending will either be visible or invisible. However, in both cases, Fiji does require the “raw” name and the file ending as a full complete name of the file. This is crucial for finding the corresponding image in the overlay image folder as they might be called either: 
```
KOMouseMuscleSlice01_Image001.jpg prediction.png

or

KOMouseMuscleSlice01_Image001 prediction.png
``` 
In other words  “.jpg” either needs to be kept or be removed. This macro will help you in doing so, but correct user input is required as no images will be found when the wrong input is entered. If you use this macro only in combination with the main macro, you can ignore this information by simply always keeping 8. + 9. untouched, as the input and output of the main macro is always “.png” and will always be required to be removed.

1. Select the file format of your original files (e.g. tif, png, jpg, ...). 
2. Hides the images while overlays are being generated.
3. Can be used to make the result image binary, so that you can overlay all cells in white over the original image. Makes it easier to visualize which cells were taken for evaluation, but less easy to visualize segmentation. Note that 6. allows you to take a different image than white. 
4. Instead choosing to give each cell a different color for easy segmentation visualization.
5. If you used the "indicate muscle border" in feature #1, this can help you remove it.
7. Choose the difference in the naming between the original files and the images you wish to overlay. For example if you original image is called "Image_001" and your overlay image is called "Image_001 Minimal Threshold", enter " Minimal Threshold" here (careful! space sensitive!).
8. You can choose to replace a part in the naming of your files by entering the desired part in 8 and entering the new part in 9.
10. Choose the opacity that you wish to use.
11. Choose how you would like your output to be named.

# Feature 3: Automated Post Analysis Heat-Maps
This macro is essentially an extracted version of the post analysis uniform heat-map feature of the main macro (Chapter 3, XV. + following). However, this macro also has some additional features that are not build in the main macro and also adds the comfort of being able to decide the heat-map parameters after a first impression of the results. Please note, this macro only works with (almost) unaltered results of the main macro.

First, choose the folder of the main macro output (containing the Result Summary.csv, Chosen Parameters.txt, …). The following dialog is then opened:

![grafik](https://user-images.githubusercontent.com/90180771/176912534-5e733294-de42-4bf0-9529-c8ab2f4f8543.png)

Everything that can be seen in the main dialog is explained in the explanation of feature #1 with one exception: this macro also allows you to save all the data in a seperate folder using the 2nd checkbox. Once the parameters are set, the result summary table is read and based on the average and stdevs that are read out and based on the parameters that were chosen, an adaptive new dialog is created:

![grafik](https://user-images.githubusercontent.com/90180771/176913027-cf11f595-4e17-4ab3-9199-4510c0274f59.png)

By default, this shows the average +- stddev values. However, here you can also set individual values. Uniform heat-maps will be generated after pressing "OK".

# Feature 4: Muscle Size Identifier:
Again a macro that is an extracted version of feature #1. Its intended use is to find the optimal "muscle size" parameter for feature #1 in a fast manner. First, choose the input (the prediction maps also used for the main macro) directory, then choose the parameters in the following dialog exactly as intended for the main macro later. This is crucial, since shape filters will alter the muscle slice size. The output will always be a table (.csv) and optionally muscle masks can be saved as well using the appripriate checkboxes. Explanation for the checkboxes and parameters, see the explanation in Feature 1.

# Feature 5: Count Mask to Binary Converter:
Very simple macro. Changes the count mask output of feature #1 to a binary image (with 0 being the background, and 65535 being cells). Intended as a QoL feature for easier visualization of masks obtained as an output from feature #1. Example (count mask left, output of this macro right):

![grafik](https://user-images.githubusercontent.com/90180771/176914953-7555fa76-f4a0-433b-9c03-e08d906722ff.png)
