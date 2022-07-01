requires("1.53a");

var sCmds = newMenu("HE Muscle Segmentation Menu Tool",  newArray("Automated Muscle Analysis", "Automated Cell Overlays", "Automated Post Analysis Heat-Maps", "Automated Muscle Size Identifier", "Count Masks to Binary Converter", "Create Muscle Mask", "-", "About"));   

macro "HE Muscle Segmentation Menu Tool - C000D68C000D3cC000C111D87C111D42C111D5dC111D28D65C111D34C111D84C111D35DadC222D82C222D51D71C222D69C222D6dC222D83C222D2bC222D61C222C333D78C333D29C333D9dDccDe9C333DbdDd7C333D27DeaC444DdcC444D33C444D36C444D7dC444Dc7C444C555D8dC555Dd8DdbC555D2aC555Da6C555D75C666D4cC666Db6C666D4dC666D96C666C777D66C777D1aD77C777D67C777D74C777D63D97C777D2cC777D64C777C888D56C888D57C888D43C888D55DebC888D81C888D26De8C888D58C888D59Db7C888C999D37DbaC999Da7C999D1bDc6C999DaaDb9DdaC999D41D52DabDbcDd9C999D73D8bC999D53D9bCaaaD8aCaaaD44D9aCaaaD72CaaaD54D7bCaaaD62D7aCaaaD4aD5bD6bCaaaD5aD89D99Da8DbbDc9CaaaDa9CaaaD49D6aD88D98Db8CbbbD3aD47D48D4bDcaCbbbD39D3bD5cD7cD8cCbbbD38D6cDcdCbbbD46D79D85D8eD9cCbbbD45DacDc8DcbCbbbD7eCbbbD19CbbbD32CcccD9eCcccD86CcccCdddD6eCdddD25CdddCeeeD93DaeCeeeD18CeeeD92CeeeD94CfffDe7CfffD3dCfffD5eCfffDf9CfffDecCfffD17DfaCfffD24CfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D15D16D1cD1dD1eD1fD20D21D22D23D2dD2eD2fD30D31D3eD3fD40D4eD4fD50D5fD60D6fD70D76D7fD80D8fD90D91D95D9fDa0Da1Da2Da3Da4Da5DafDb0Db1Db2Db3Db4Db5DbeDbfDc0Dc1Dc2Dc3Dc4Dc5DceDcfDd0Dd1Dd2Dd3Dd4Dd5Dd6DddDdeDdfDe0De1De2De3De4De5De6DedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8DfbDfcDfdDfeDff" {      
	cmd = getArgument();   
	if (cmd=="About") {     
		print ("This is a toolbox designed for muscle images segmented by artifical neural networks."); 
		print ("Requirements: MorphoLibJ, Biovoxxels Toolbox, BAR. Use Help -> Update -> Manage Update Sites if the required plugins are missing. ");
		print ("For more information, read the paper about this tool and the artifical neural network on:");
		print ("Manual of this toolset can be found under:");
		print ("https://github.com/OliverAust/HE_Muscle_Seg");
		print ("If you use this tool for your research, please cite our paper:");
		print ("Paper Information"); 
		print ("Developed by: Oliver Aust and Leonid Mill");   
		exit;       
	}
	else if (cmd=="Automated Muscle Analysis") run("Muscle Analysis");
	else if (cmd=="Automated Cell Overlays") run("Overlay Macro");
	else if (cmd=="Automated Post Analysis Heat-Maps") run("APA Heat-Maps");
	else if (cmd=="Automated Muscle Size Identifier") run("Automated Muscle Size Identifier");
	else if (cmd=="Count Masks to Binary Converter") run("Count Masks to Binary Converter");
	else if (cmd=="Create Muscle Mask") run("Create Muscle Mask");
	else if (cmd=="Create Image") run("Create Image");
	//if (cmd!="-") run(cmd);  
}

/*
 * 
 * 
 * 					OVERLAY MACRO V1.0
 * OVERLAY MACRO TO CREATE IMAGES OF COUNTED CELLS + ORIGINAL IMAGE
 * SHOULD WORK FOR ANY KIND OF MASK + IMAGE COMBINATION
 * FOR A MANUAL VISIT www.ManualHere.com
 * 
 * 
 */
 
macro "Overlay Macro" {

	// Get Input & Output
	InputOriginal = getDirectory("Choose a directory for the original images!");
	InputOverlay = getDirectory("Choose a directory for the overlay images!");
	Output = getDirectory("Choose a directory for the output!");

	// Create Dialog with User Options:
	Dialog.create("Setting Parameters to Create Overlay Images");
	Dialog.addMessage("Note: If your file is called Cellimage01_001 and it is a png file, the name is actually Cellimage01_001.png.");
	Dialog.addMessage("Depending on your Windows setting this is visibile or invisible. It is crucial to choose the correct file ending.");
	Dialog.addString("File ending of the original images: (e.g. .tif, .png, .jpg, ...)", ".png");
	Dialog.addCheckbox("Enable Batch Mode (hides images while processing)", true);
	Dialog.addCheckbox("Make Overlay Image Binary", false);
	Dialog.addCheckbox("When Using Count Masks: Create Color Map", false);
	Dialog.addCheckbox("Remove Yellow Overlay from Connective Tissue Images", false);
	Dialog.addCheckbox("Use a color instead of white", false);
	ColorSelection= newArray("Red", "Green", "Blue", "Cyan", "Magenta", "Yellow");
	Dialog.addChoice("Choose the Color", ColorSelection);
	Dialog.addString("File Name Difference", "_Mask.png");
	Dialog.addMessage("E.g. if original images are named CellImage_01_001.png and masks are named CellImage_01_001.png_Mask.png, enter _Mask.png");
	Dialog.addString("Replace the following part of the file names", ".png");
	Dialog.addString("With the following part:", "");
	Dialog.addMessage("Leave 2nd Field empty to remove a part of the String. Required if you files are named e.g. CellImage_01_001.png and CellImage_01_001_Mask.png");
	Dialog.addMessage("Leave both fields empty to replace nothing.");
	Dialog.addNumber("Choose Opacity: ", 30);
	Dialog.addString("Choose new file name ending: (space sensitive!, will use the original file name without file ending)", " Mask Overlay");
	Dialog.show();

	// Get User Input:
	suffix = Dialog.getString();
	BatchMode = Dialog.getCheckbox();
	Threshold = Dialog.getCheckbox();
	ColorMap = Dialog.getCheckbox();
	RemoveOverlay = Dialog.getCheckbox();
	Color = Dialog.getCheckbox();
	ColorChoice = Dialog.getChoice();
	Difference = Dialog.getString();
	ReplaceThis = Dialog.getString();
	ReplaceWithThis = Dialog.getString();
	Opacity = Dialog.getNumber();
	FileNameEnd = Dialog.getString();

	// Processing:
	if (BatchMode) 
		setBatchMode("hide");
	list = getFileList(InputOriginal);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], suffix)) {
				open(InputOriginal + list[i]);
				NameOriginal = getTitle();
				NameRaw = replace(NameOriginal, suffix, ""); // removes file ending to obtain the imagename only. Used later to avoid names like: "CellImage01_001.png Overlay.png".
				NameOverlayFinder = replace(NameOriginal, ReplaceThis, ReplaceWithThis); // will be identical to NameOriginal if the user left the fields empty. Otherwise helps finding overlay images
				open(InputOverlay + NameOverlayFinder + Difference); // Added Difference 
				if (Threshold){
					setThreshold(1, 65535);
					setOption("BlackBackground", true);
					run("Convert to Mask");
				}
				if (RemoveOverlay)
					run("Split Channels");  // only works this simple since the B channel is opened last, and is the only one not containing yellow information
				if (ColorMap)
					run("Set Label Map", "colormap=[Golden angle] background=Black");
				if (Color)
					run(ColorChoice);		// change LUT foreground color to users choice
				NameOverlay = getTitle();
				selectWindow(NameOriginal);
				run("Add Image...", "image=[" + NameOverlay + "] x=0 y=0 opacity=" + Opacity);
				saveAs("PNG", Output + NameRaw + FileNameEnd);
				run("Close All");
			}
		}
		
}

/*
 * 
 * 
 * 					AUTOMATED MUSCLE ANALYSIS V1.0
 * THIS MACRO REQUIRES PREDICTION MAPS OF A NEURAL NETWORK, OR ANY KIND OF SEGMENTED CELL IMAGE
 * EXCEPT FOR CONNECTIVE TISSUE ANALYSIS, THIS MACRO SHOULD WORK FOR ALL KINDS OF CELL IMAGES
 * BUT THE SEGMENTATION POST PROCESSING ALGORITHMS ARE OPTIMIZED FOR HE MUSCLE CELL + NN IMAGES
 * FOR A MANUAL VISIT: www.ManualHere.com
 * 
 * 
 */

macro "Muscle Analysis" {
	/*
	*  --------------------------------------------------------------------------------------------------------------------
	*  										User Input for Directories:
	*  --------------------------------------------------------------------------------------------------------------------
	*/
	
	input = getDirectory("Choose a Directory for Input");
	output = getDirectory("Choose a Directory for Output");
	
	/*
	*  --------------------------------------------------------------------------------------------------------------------
	*  										Creating Arrays for Dialog options:
	*  --------------------------------------------------------------------------------------------------------------------
	*/
	
	algol = newArray("WIF 10", "DTW 20-8", "DTW 20", "none"); // Users can add their own Algorithms here.
	luts = getList("LUTs");
	run("Set Measurements...", "area centroid perimeter bounding fit shape feret's add redirect=None decimal=3"); // hardcoded to prevent user error. should include all parameters.
	measurements = newArray("Area", "X", "Perim.", "Angle", "Circ.", "Feret", "FeretAngle", "MinFeret", "Round"); // hardcoded as a result of ^
	defaults = newArray(measurements.length);
	for (i=0; i<measurements.length; i++) 
		defaults[i] = false;
	ChosenMeas = newArray(measurements.length);	// initialization for later
	colors = newArray("red", "green", "blue", "pink", "cyan", "magenta");
	
	/*
	* 
	*  --------------------------------------------------------------------------------------------------------------------
	*  											CREATING MAIN DIALOG:
	*  					The default numbers in the dialog are based on the data presented in the paper.
	*  --------------------------------------------------------------------------------------------------------------------
	*  
	*/
	
	Dialog.createNonBlocking("Set Parameters for Evaluation");
	if (is("global scale")) 
		Dialog.addMessage("A global scale was found. If you want to keep it, enter 0.");
	else 
		Dialog.addMessage("No global scale was found. Enter your scale:");
	Dialog.addNumber("Set Scale (Pixels/\µm):", 2.267);
	Dialog.addString("Input Files Suffix", ".png");
	Dialog.addChoice("Segmentation Algorithm", algol); 
	Dialog.addNumber("Prediction Map Threshold", 140);
	Dialog.addMessage("__________________________________________________________");				// Optional Analysis Features
	Dialog.addCheckbox("Apply Shape Filters:", false);
	Dialog.addNumber("Maximum Cell Size Threshold", 200000);
	Dialog.addNumber("Minimum Cell Size Threshold", 150);
	Dialog.addNumber("Maximum Circularity Threshold", 1.0);
	Dialog.addNumber("Minimum Circularity Threshold", 0.10);
	Dialog.addNumber("Maximum minFeret", 50);
	Dialog.addNumber("Maximum AR", 2.5);
	Dialog.addCheckbox("Include Holes in Cells (For Filtered AND non Filtered)", false);
	Dialog.addCheckbox("Whole Slide Images", true);
	Dialog.addCheckbox("Clear Outside Muscle Mask (requires Whole Slides)", false);
	Dialog.addCheckbox("Evaluate Raw Connective Tissue (Non Filtered Cells)", true);
	Dialog.addCheckbox("Evaluate Shape Filtered Connective Tissue (Shape Filtered Cells)", false);
	Dialog.addCheckbox("Create local thickness map of connective tissue (computing intense)", false);
	Dialog.addCheckbox("Indicate Muscle Border (Requires any CT Evaluation", false);	
	Dialog.addNumber("Number of Dilate-Erode Loops", 10);
	Dialog.addNumber("Area Opening Value", 3500);
	Dialog.addNumber("Estimated Sample Size", 1500000);
	Dialog.addMessage("__________________________________________________________");				// Optional Quality of Life Features:
	Dialog.addCheckbox("Hide Images While Processing (Does not work with Heat-Maps)", false);
	Dialog.addCheckbox("2D Particle Distribution Analysis", false);
	Dialog.addCheckbox("Create Oriented Bounding Boxes", false);
	Dialog.addChoice("Set color for OBB's: ", colors);
	Dialog.addNumber("Set width for OBB'S: ", 5);
	Dialog.addMessage("Create heat-maps of the following parameters:");
	Dialog.addCheckboxGroup(2, 5, measurements,defaults);
	Dialog.addMessage("Choose the LUT for the chosen heat maps");
	Dialog.addChoice("LUT: ", luts, "mpl-viridis");
	Dialog.addCheckbox("Show cell number in heat-map: ", true);
	Dialog.addCheckbox("Use standard deviation for legend scaling", true);
	Dialog.addCheckbox("Create uniform heat-maps after full analysis", false);
	Dialog.addCheckbox("Only create uniform heat-maps", false);
	Dialog.addHelp("www.google.com");																 // Link for Manual of this toolset
	Dialog.show();
	
	//Get Parameters from Dialog:
	scale = Dialog.getNumber();
	suffix = Dialog.getString();
	AlgoChoice = Dialog.getChoice();
	Threshold = Dialog.getNumber();
	
	SFilter = Dialog.getCheckbox();
	MaxSizeT = Dialog.getNumber();
	MinSizeT = Dialog.getNumber();
	MaxCircT = Dialog.getNumber();
	MinCircT = Dialog.getNumber();
	MaxFeret = Dialog.getNumber();
	MaxAR = Dialog.getNumber();
	IncludeHoles = Dialog.getCheckbox();
	WholeSlide = Dialog.getCheckbox();
	MuscleMaskAnalysis = Dialog.getCheckbox();
	ConTissue = Dialog.getCheckbox();
	SFConTissue = Dialog.getCheckbox();
	LocalThickness = Dialog.getCheckbox();
	KeepOverlay = Dialog.getCheckbox();
	LoopCount = Dialog.getNumber();
	AreaOpening = Dialog.getNumber();
	MuscleSize = Dialog.getNumber();
	
	BatchMode = Dialog.getCheckbox();	
	Distribution = Dialog.getCheckbox();
	OBoundingBox = Dialog.getCheckbox();
	ChoiceofColor = Dialog.getChoice();
	width = Dialog.getNumber();
	for (i=0; i<9; i++) ChosenMeas[i] = Dialog.getCheckbox();
	LUT = Dialog.getChoice();
	Number = Dialog.getCheckbox();
	StandardDev = Dialog.getCheckbox();
	PAHM = Dialog.getCheckbox();
	OnlyPAHM = Dialog.getCheckbox();
	
	
	
	/*
	*  --------------------------------------------------------------------------------------------------------------------
	*  											Set Up Based on User Input
	*  --------------------------------------------------------------------------------------------------------------------
	*/
	
	if (scale != 0) {																//Apply global scale if user entered anything but 0
		run("Blobs (25K)");
		run("Set Scale...", "distance=" + scale + " known=1 unit=µm global");
		close("blobs.gif");
	}
	
	if (IncludeHoles)																//Simple way to add or not add "inlcude" when running Analyze Particles
		include = "include";
	else 
		include = " ";
	
	CreateHeatMap = false;															//Check if one parameter for a heat-map was chosen, if yes, Heat Maps need to be created
	for (i=0; i<9; i++){
		if (ChosenMeas[i]){
			CreateHeatMap = true;
			break;
		}
	}
	
	if (BatchMode && !CreateHeatMap) {												//Batch Mode should be optional, since viewing the images during processing can help to optimize parameters sooner
		setBatchMode("hide");
	}
	else if (BatchMode && CreateHeatMap)
		showMessage("Error", "Batch Mode cannot be turned on when creating heat maps, as it does not work with Roi Color Coder. Batch Mode has been turned off and the macro will resume.");
	
	//Set up for summary file
	list = getFileList(input);														// File List
	list = Array.sort(list);
	setOption("ExpandableArrays", true);
	ll = list.length;
	list[ll] = "Average for all Files: ";
	NumberIndex = Array.getSequence(list.length);
	Table.create("Data Summary");													// Generate Table for General Results
	Table.setColumn("File Name", list);
	Table.setColumn("Number", NumberIndex);	
	Table.update;
	if (SFilter || MuscleMaskAnalysis) {											// Generate Table for Post Processed Only Results.csv
		Table.create("Data Summary Post Processed Only");
		Table.setColumn("File Name", list);
		Table.setColumn("Number", NumberIndex);
		Table.update;			
	}
	index = 0;
	
	/*
	*  --------------------------------------------------------------------------------------------------------------------
	*  												Main Loop:
	*  --------------------------------------------------------------------------------------------------------------------
	*/
	
	for (p = 0; p < list.length; p++) {
		if(endsWith(list[p], suffix)){
			NameRaw = replace(list[p], suffix, "");
			File.makeDirectory(output + NameRaw);
			postProcessing();
			if (WholeSlide || ConTissue)						// If the User does not want to evaluate the connective tissue and does not use whole slides, the muscle mask isn't required. otherwise it is at least required to enhance Muscle Mask
				createMuscleMask(" post processed", " Raw", false);
			analyzeParticles();
			if (ConTissue)
				analyzeConnectiveTissue(" post processed", " Raw");
			if (SFilter && SFConTissue){
				if (!WholeSlide && !ConTissue)									// a WholeSlide related condition is required, as a MuscleMask is also created if WholeSlide is true, but !ConTissue
					createMuscleMask(" Shape Filtered", " Filtered", false);	// First time the Muscle Mask is created, hence the MuscleSize needs to be applied.
				else 
					createMuscleMask(" Shape Filtered", " Filtered", true);		// Second time the MM is created, hence the MuscleSize filter needs to be skipped to keep filtered and separated cells
				analyzeConnectiveTissue(" Shape Filtered", " Filtered");
			}
			if (!OnlyPAHM && CreateHeatMap)
				createHeatMaps();
			analyzeAdditionalFeatures();					// always required for at least the common feature			
			index = index + 1;								// index for summary table
		}
	}
	
	/*
	*  --------------------------------------------------------------------------------------------------------------------
	*  												Post Analysis:
	*  --------------------------------------------------------------------------------------------------------------------
	*/
	
	createSummaryTable("Data Summary");
	if (SFilter || MuscleMaskAnalysis);
		createSummaryTable("Data Summary Post Processed Only");
	createSummaryTXT();
	
	//Loop for uniform post analysis heat-maps
	if (PAHM || OnlyPAHM){									// || Only Pahm to prevent User Mistake of selecting OnlyPAHM and the heat maps without selecting PAHM
		uni = 0;
		list = getFileList(output);
		list = Array.sort(list);
		for (i = 0; i < list.length; i++) {
			if(File.isDirectory(output + list[i])) {		// since all the images are saved in folders with their NameRaw and there are some Summary files 
				processFilePAHM(output, list[i], uni);
				uni = 1;			
			}			
		}
	}
	
	// End of the Macro
	
	/*
	* 
	*  --------------------------------------------------------------------------------------------------------------------
	*  												FUNCTIONS START HERE
	*  --------------------------------------------------------------------------------------------------------------------
	*  
	*/
	
	function postProcessing(){
		open(input + list[p]);	
		name1 = getTitle();
		setThreshold(Threshold, 255);
		setOption("BlackBackground", true);
		run("Convert to Mask");
		if (AlgoChoice != "none") {
			if (AlgoChoice == "DTW 20" || AlgoChoice == "DTW 20-8"){
				run("Distance Transform Watershed", "distances=[Quasi-Euclidean (1,1.41)] output=[16 bits] normalize dynamic=20 connectivity=8");
				ThresholdValue1();
				name2 = getTitle();
				close(name1);
			}
			else 
				run("Watershed Irregular Features", "erosion=1 convexity_threshold=0 separator_size=0-10");
			if (AlgoChoice == "DTW 20-8"){
				run("Distance Transform Watershed", "distances=[Quasi-Euclidean (1,1.41)] output=[16 bits] normalize dynamic=8 connectivity=8");
				ThresholdValue1();
				name1 = getTitle();
				close(name2);
			}
		}
		run("Analyze Particles...", "size=150-Infinity circularity=0.10-1.00 show=[Count Masks] display exclude clear " + include + ""); // Minimal Threshold to remove artifacts
		saveAs("PNG", output + NameRaw + File.separator + NameRaw + " Post Processed.png");
		rename(NameRaw + " post processed");
		if (SFilter || MuscleMaskAnalysis) {										// Summarizing particle analyzation into a single table for Post Processed Only Results
			addToSummaryTable("Data Summary Post Processed Only");
			selectWindow("Results");
			saveAs("Results", output + NameRaw + File.separator + NameRaw + " Results Post Processed.csv");
		}			
	}
	
	function analyzeParticles(){
		selectWindow(NameRaw + " post processed");
		run("Duplicate...", " ");
		ThresholdValue1();
		if (WholeSlide && MuscleMaskAnalysis){	// only counting inside the Muscle Masks only makes sense for Whole Slides, as this method allows removal of objects outside the slice -> single images / tilescans will aways be inside
			rename("Analyze Mask");
			selectWindow(NameRaw + " Raw Muscle Mask");
			run("Create Selection");
			selectWindow("Analyze Mask");
			run("Restore Selection");
			setBackgroundColor(0, 0, 0);
			run("Clear Outside");				// The "Clear Outside" approach is MUCH less computing intensive than analyzing particles inside a selection
			run("Select None");
			saveAs("PNG", output + NameRaw + File.separator + NameRaw + " Post Processed & Cleared Outside.png");
			rename(NameRaw + " Post Processed & Cleared Outside");
		}
		if (SFilter){
			run("Extended Particle Analyzer", " area=" + MinSizeT + "-" + MaxSizeT + " circularity=" + MinCircT + "-" + MaxCircT + " max_feret=0-" + MaxFeret + " aspect=0.00-" + MaxAR + " show=[Count Masks] redirect=None keep=None display exclude clear " + include + " add");
			saveAs("PNG", output + NameRaw + File.separator + NameRaw + " Shape Filtered.png");
			rename(NameRaw + " Shape Filtered");
		}	
		else // also required if no SFilter applied to reopen the Result table that was lost by generating the Muscle Mask
			run("Analyze Particles...", "size=0-infinity circularity=0.00-1.00 show=[Count Masks] display exclude clear " + include + " add"); 
		
		addToSummaryTable("Data Summary");
		selectWindow("Results");
		saveAs("Results", output + NameRaw + File.separator + NameRaw + " Results.csv");			
	}

	function addToSummaryTable(TableName){
		selectWindow("Results");
		StatA = newArray(nResults);
		for (o = 0; o < measurements.length; o++) {
			for (i = 0; i < nResults(); i++) {
	    		StatA[i] = getResult(measurements[o], i);
			}
			selectWindow(TableName);
			Array.getStatistics(StatA, min, max, mean, stdDev);
			Table.set("Min " + measurements[o], index, min);
			Table.set("Max " + measurements[o], index, max); 	
			Table.set("Mean " + measurements[o], index, mean);
			Table.set("StdDev " + measurements[o], index, stdDev);
		}
		Table.set("Cell Count", index, nResults);
		Table.update;		
	}
	
	function createMuscleMask(MaskName, Denominator, SecondTime){
		selectWindow(NameRaw + MaskName); 
		run("Duplicate...", " ");					
		ThresholdValue1();
		for (i = 0; i < LoopCount; i++){
			run("Dilate");
		}
		for (i = 0; i < LoopCount; i++){
			run("Erode");
		}
		run("Invert");
		run("Area Opening", "pixel=" + AreaOpening); // removing artifacts
		run("Invert");
		if (WholeSlide && !SecondTime) {			// This part also filters CORRECT cells when SFConTissue and ConTissue || Whole Slide is true, since separate cell clusters will be created in analyzeParticles() due to SFilter
			run("Analyze Particles...", "size=" + MuscleSize + "-Infinity show=[Count Masks] clear");	//Thus, there needs to be the option to turn this off, since in that case there is also no longer a point in filtering for the ...
			ThresholdValue1();						// ... MuscleSize a second time. This is carried out via SecondTime		
		}
		else if (!WholeSlide){ 						// Condition required due to SecondTime
			width = getWidth() - LoopCount*2;		// the following is required, since in non WholeSlide images, a border will unintenitonally be created by dilating / eroding cells at the edges - need to be cut off before DifferenceCreate
			height = getHeight() - LoopCount*2;		// Otherwise the shift in pixels will cause incorrect display of the connective Tissue
			makeRectangle(LoopCount, LoopCount, width, height);
			run("Crop");		
		}
		saveAs("PNG", output + NameRaw + File.separator + NameRaw + Denominator + " Muscle Mask.png");
		rename(NameRaw + Denominator + " Muscle Mask");
	}
	
	function analyzeConnectiveTissue(MaskName, Denominator){	// " Shape Filtered", " Filtered"
		selectWindow(NameRaw + MaskName);
		run("Duplicate...", " ");
		ThresholdValue1();
		if (!WholeSlide){
			width = getWidth() - LoopCount*2;
			height = getHeight() - LoopCount*2;
			makeRectangle(LoopCount, LoopCount, width, height);
			run("Crop");		
		}
		rename("CT Mask");
		//if (!MuscleMaskAnalysis || Denominator == " Raw"){	// Due to unwanted cells, there will always be a difference between the Muscle Mask and Post Processed Image, leading to artifacts in the CT images
		selectWindow(NameRaw + Denominator + " Muscle Mask");
		run("Create Selection");
		selectWindow("CT Mask");
		run("Restore Selection");
		setBackgroundColor(0, 0, 0);
		run("Clear Outside");									// ^ clearing the outside of the Post Processed Image, will remove those artifacts										
		//}
		imageCalculator("Difference create", NameRaw + Denominator + " Muscle Mask", "CT Mask");
		rename(NameRaw + Denominator + " Connective Tissue");
		// Local Thickness:
		if (LocalThickness){
			run("Local Thickness (masked, calibrated, silent)");
			saveAs("TIF", output + NameRaw + File.separator + NameRaw + Denominator + " Connective Tissue Local Thickness.png");
			close();
		}
		selectWindow(NameRaw + Denominator + " Muscle Mask");
		run("Create Selection");
		selectWindow(NameRaw + Denominator + " Connective Tissue");
		run("Restore Selection");
		close("Results");
		run("Set Measurements...", "area area_fraction add redirect=None decimal=3");
		run("Measure");
		emarea = getResult("Area", 0);
		fraction = getResult("%Area", 0);
		close("Results");
		selectWindow("Data Summary");							// Tissue values can be saved in only one of the two tables, as its identical. Saving it in the one, that will always be created is more logical.
		Table.set(Denominator + " Muscle Area", index, emarea);
		Table.set(Denominator + " Connective Tissue Fraction", index, fraction);
		Table.set(Denominator + " Connective Tissue Area", index, emarea * (fraction * 0.01));
		selectWindow(NameRaw + Denominator + " Connective Tissue");
		if (KeepOverlay == false)
			run("Remove Overlay");
		saveAs("PNG", output + NameRaw + File.separator + NameRaw + Denominator + " Connective Tissue.png");
		run("Set Measurements...", "area centroid perimeter bounding fit shape feret's add redirect=None decimal=3"); // resetting the measurement types for analyze particles	
	}
	
	function createHeatMaps(){
		selectAnalysisWindow();
		run("Duplicate...", " ");
		ThresholdValue1();
		rename(list[p] + " ");
		run("Analyze Particles...", "size=0-infinity circularity=0.00-1.00 show=[Count Masks] display clear " + include + " add");
		if (Number)	roiManager("Show All with labels"); 							// Cell Numbers in heat-maps decision
		else roiManager("Show All without labels");
		
		for (i = 0; i < measurements.length; i++){
			if (ChosenMeas[i] == 1){												// OnlyPahm == false not required?
				run("Duplicate...", " ");			
				if (measurements[i] == "Angle" || measurements[i] == "FeretAngle") 	// Min-Max Scaling for Angle isn't reasonable. Its usually 0.0X-179.89X or something like that -> 0-180 is cleaner
					run("ROI Color Coder", "measurement=" + measurements[i] + " lut=[" + LUT + "] width=0 opacity=80 label=µm^2 range=0-180 n.=5 decimal=0 ramp=[512 pixels] font=SansSerif font_size=14 draw");
				else if (StandardDev == true && measurements[i] != "X") {
					Mean = Table.get("Mean " + measurements[i], index);
					StdDev = Table.get("StdDev " + measurements[i], index);
					Min = parseFloat(Mean) - parseFloat(StdDev);
					Max = parseFloat(Mean) + parseFloat(StdDev);
					run("ROI Color Coder", "measurement=" + measurements[i] + " lut=[" + LUT + "] width=0 opacity=80 label=µm^2 range=" + Min + "-" + Max + " n.=5 decimal=3 ramp=[512 pixels] font=SansSerif font_size=14 draw");
				}
				else // if StandardDev == true, only X enters here. If == false, everything enters here, except angle and feretangle
					run("ROI Color Coder", "measurement=" + measurements[i] + " lut=[" + LUT + "] width=0 opacity=80 label=µm^2 range=Min-Max n.=5 decimal=3 ramp=[512 pixels] font=SansSerif font_size=14 draw");			
				saveAs("PNG", output + NameRaw + File.separator + NameRaw + " " + measurements[i] + " Ramp.png");
				close();
				run("Flatten");
				saveAs("PNG", output + NameRaw + File.separator + NameRaw + " " + measurements[i] + " Heat-Map.png");
				close();	
			}
		}
		run("Remove Overlay");		
	}
	
	function analyzeAdditionalFeatures(){
		if (Distribution){
			selectAnalysisWindow();
			run("Duplicate...", " ");
			ThresholdValue1();
			if (SFilter)
				run("Particle Distribution (2D)", "min_size=" + MinSizeT + " max_size=" + MaxSizeT + " min_circularity=" + MinCircT + " max_circularity=" + MaxCircT + " " + include + " exclude neighbor=[centroid NND] statistical=median conficence=99%");
			else
				run("Particle Distribution (2D)", "min_size=0 max_size=Infinity min_circularity=0.00 max_circularity=1.00 " + include + " exclude neighbor=[centroid NND] statistical=median conficence=99%");
			saveAs("Text", output + NameRaw + File.separator + NameRaw  + " Distribution.txt");
			LogText = getInfo("Log");
			selectWindow("Data Summary"); 			
			Table.set("Log Text: ", index, LogText);
			close("Log");
		}
		if (OBoundingBox) {
			selectAnalysisWindow();
			run("Duplicate...", " ");
			rename("Bounding Box");
			run("Oriented Bounding Box", "label=[Bounding Box] show image=[Bounding Box]");
			run("Overlay Options...", "stroke=" + ChoiceofColor + " width=" + width + " fill=none set apply");
			selectWindow("Bounding-OBox");
			saveAs("Results", output + NameRaw + File.separator + NameRaw +  " Bounding Box.csv");
			close(NameRaw + " Bounding Box.csv");
			saveAs("PNG", output ++ NameRaw + File.separator + NameRaw + " Bounding Box.png");
			close(NameRaw + " Bounding Box.png");
		}
		close("Results");
		close("ROI Manager");
		run("Close All");
		close("Log");
	}	
	
	function createSummaryTable(TableName){
		//Create a summary table with min, max, mean stdDev averages and save them as a .csv
		selectWindow(TableName);
		MMNS = newArray("Min ", "Max ", "Mean ", "StdDev ");
		StatPAHM = newArray(Table.size-1); 						// -1 since the last row ("Average for all Files: ") is empty and would influence mean, min and stdDev
		for (o = 0; o < measurements.length; o++) { 			// loop for each parameter (Area, Perimeter)
			for (p = 0; p < MMNS.length; p++){					// loop for Min Max Mean SDev -> in combination with o -> Min Area, Max Area, Mean Area, ...
				for (i = 0; i < StatPAHM.length; i++) 			// loop for each row (i.e. each list[p])
	    			StatPAHM[i] = Table.get(MMNS[p]+ measurements[o], i);    		
	    		Array.getStatistics(StatPAHM, min, max, mean, stdDev);
	    		if (p == 0)
					Table.set("Min " + measurements[o], ll, min);
				else if (p == 1)
					Table.set("Max " + measurements[o], ll, max);
				else if (p == 2)
					Table.set("Mean " + measurements[o], ll, mean);
				else
					Table.set("StdDev " + measurements[o], ll, mean);		
			}
		}
		if (TableName != "Data Summary Post Processed Only") { 	// these will never be written in DSPPO.csv so they can be skipped (except for Cell Count).
			if (ConTissue && !SFConTissue)
				SpecialStatArray = newArray("Cell Count", " Raw Muscle Area", " Raw Connective Tissue Fraction", " Raw Connective Tissue Area");
			else if (!ConTissue && SFConTissue)
				SpecialStatArray = newArray("Cell Count", " Filtered Muscle Area", " Filtered Connective Tissue Fraction", " Filtered Connective Tissue Area");
			else if (ConTissue && SFConTissue)
				SpecialStatArray = newArray("Cell Count", " Raw Muscle Area", " Raw Connective Tissue Fraction", " Raw Connective Tissue Area", " Filtered Muscle Area", " Filtered Connective Tissue Fraction", " Filtered Connective Tissue Area");
			else
				SpecialStatArray = newArray("Cell Count");
		}
		else 
			SpecialStatArray = newArray("Cell Count");
		for (x = 0; x < SpecialStatArray.length; x++){
			for (i = 0; i < StatPAHM.length; i++) 
	    		StatPAHM[i] = Table.get(SpecialStatArray[x], i);  
	    	Array.getStatistics(StatPAHM, min, max, mean, stdDev);
	    	Table.set(SpecialStatArray[x], ll, mean);
		}
		Table.update;
		if (TableName == "Data Summary")
			saveAs("Results", output + "Results Summary.csv");
		else
			saveAs("Results", output + "Results Summary Post Processed Only.csv");
	}
	
	function createSummaryTXT(){	
		//Make a summary .txt with the chosen Parameters to increase reproducibility and error finding
		print("Scale: " + scale);
		print("Algorithm: " + AlgoChoice);
		print("Prediction Threshold: " + Threshold);
		print("The following Muscle Mask parameters were chosen:");
		print("Muscle Size (in µm): " + MuscleSize);
		print("Area Opening (in Pixels): " + AreaOpening);
		print("Loop count: " + LoopCount);
		if (WholeSlide && MuscleMaskAnalysis) 
			print("The Cell Analysis was carried out using the Muscle Mask");
		if (SFilter == false)
			print("No Shape Filter was used.");
		else {
			print("The following Shape Filter settings were used:");
			print("Cells were filtered in size from " + MinSizeT + "-" + MaxSizeT);
			print("Cells were filtered in circ from " + MinCircT + "-" + MaxCircT);
			print("Cells were filtered with MaxFeret of " + MaxFeret);
		}
		if (IncludeHoles)
			print("Holes were included.");
		else 
			print("Holes were not included."); 
		saveAs("Text", output + "Chosen Parameters.txt");
	}
	
	function processFilePAHM(output, NameRaw, uni) {
			TrueName = replace(NameRaw, "/", "");
			if (SFilter)
				open(output + NameRaw + TrueName + " Shape Filtered.png");
			else if (WholeSlide && MuscleMaskAnalysis)
				open(output + NameRaw + TrueName + " Post Processed & Cleared Outside.png");
			else 
				open(output + NameRaw + TrueName + " Post Processed.png");	
			ThresholdValue1();
			run("Analyze Particles...", "clear " + include + " add");
			if (Number)	roiManager("Show All with labels"); // Cell Numbers in heat-maps decision
			else roiManager("Show All without labels");
			for (i = 0; i < measurements.length; i++){
				if (ChosenMeas[i] == 1) {				
					run("Duplicate...", " ");						
					if (measurements[i] == "Angle" || measurements[i] == "FeretAngle" && OnlyPAHM == true) // only enter if OnlyPAHM is true. If it is false a uniform heat map was already made
						run("ROI Color Coder", "measurement=" + measurements[i] + " lut=[" + LUT + "] width=0 opacity=80 label=µm^2 range=0-180 n.=5 decimal=0 ramp=[512 pixels] font=SansSerif font_size=14 draw");
					else if (measurements[i] == "X" && OnlyPAHM == true)
						run("ROI Color Coder", "measurement=" + measurements[i] + " lut=[" + LUT + "] width=0 opacity=80 label=µm^2 range=Min-Max n.=5 decimal=0 ramp=[512 pixels] font=SansSerif font_size=14 draw");
					else{
						Mean = Table.get("Mean " + measurements[i], ll);
						StdDev = Table.get("StdDev " + measurements[i], ll);
						Min = parseFloat(Mean) - parseFloat(StdDev);
						Max = parseFloat(Mean) + parseFloat(StdDev);
						run("ROI Color Coder", "measurement=" + measurements[i] + " lut=[" + LUT + "] width=0 opacity=80 label=µm^2 range=" + Min + "-" + Max + " n.=5 decimal=3 ramp=[512 pixels] font=SansSerif font_size=14 draw");
					}
				if (uni == 0)
					saveAs("PNG", output + measurements[i] + " Uniform Ramp.png");
				close();
				run("Flatten");
				saveAs("PNG", output + NameRaw + TrueName + " " + measurements[i] + " Uniform Heat-Map.png");
				close();	
				}
			}	
		run("Close All");
		close("ROI Manager");		
	}
	
	function ThresholdValue1() {
		setThreshold(1, 65535);
		setOption("BlackBackground", true);				
		run("Convert to Mask");		
	}
	
	function selectAnalysisWindow() {
		if (SFilter)
			selectWindow(NameRaw + " Shape Filtered");
		else if (WholeSlide && MuscleMaskAnalysis)
			selectWindow(NameRaw + " Post Processed & Cleared Outside");
		else 
			selectWindow(NameRaw + " Post Processed");
	}
}



/*
 * 
 * 
 * 					AUTOMATED HEAT-MAP GENERATOR
 * USES THE IMAGES + TABLE OBTAINED BY THE AUTOMATED MUSCLE ANALYSIS MACRO
 * 
 * FOR A MANUAL VISIT www.ManualHere.com
 * 
 * 
 */
 
macro "APA Heat-Maps" {
		
	/*
	*  --------------------------------------------------------------------------------------------------------------------
	*  										Create Variables for Dialog:
	*  --------------------------------------------------------------------------------------------------------------------
	*/
	
	luts = getList("LUTs");
	measurements = newArray("Area", "X", "Perim.", "Angle", "Circ.", "Feret", "FeretAngle", "MinFeret", "Round");
	defaults = newArray(measurements.length);
	for (i=0; i<measurements.length; i++) 
		defaults[i] = false;
	ChosenMeas = newArray(measurements.length);
	colors = newArray("red", "green", "blue", "pink", "cyan", "magenta");
	ImageType = newArray(" Shape Filtered.png", " Post Processed & Cleared Outside.png", " Post Processed.png");
	uni = 0;	// variable to generate only one uniform heat map instead of multiple

		
	/*
	*  --------------------------------------------------------------------------------------------------------------------
	*  											Create and Read Dialog 1:
	*  --------------------------------------------------------------------------------------------------------------------
	*/
	
	input = getDirectory("Choose the directory that contains the Result Summary.csv and the folders containing the processed.png's!");
	
	Dialog.create("Set Parameters for Post Analysis Uniform Heat-Map generation:");
	Dialog.create("Set Parameters for Evaluation");
	if (is("global scale")) 
		Dialog.addMessage("A global scale was found. If you want to keep it, enter 0.");
	else 
		Dialog.addMessage("No global scale was found. Enter your Scale:");
	Dialog.addNumber("Set Scale (Pixels for 1µm):", 2.267);
	Dialog.addChoice("What kind of image do you want to process?", ImageType);
	Dialog.addCheckbox("Have you altered the name of the Result Summary.csv?", false);	
	Dialog.addString("If yes, enter the new name with the file ending!", "ThisIsAnExampleName.csv");
	Dialog.addMessage("The folders will be saved in a new folder in separate subfolders based on the parameter.");
	Dialog.addCheckbox("Save them in the old folders instead", false);
	Dialog.addMessage("___________________________________________________________________________");
	Dialog.addMessage("Create heat-maps of the following parameters:");
	Dialog.addCheckboxGroup(5, 2, measurements,defaults);
	Dialog.addMessage("Choose the LUT for the chosen heat maps");
	Dialog.addChoice("LUT: ", luts, "mpl-viridis");
	Dialog.addCheckbox("Show cell number in heat-map: ", true);
	Dialog.show();

	scale = Dialog.getNumber();
	ImageTypeChoice = Dialog.getChoice();
	AlteredName = Dialog.getCheckbox();
	ResultsName = Dialog.getString();
	OldFolders = Dialog.getCheckbox();
	for (i=0; i<9; i++) ChosenMeas[i] = Dialog.getCheckbox();
	LUT = Dialog.getChoice();
	Number = Dialog.getCheckbox();

	if (scale != 0) {																//Apply global scale if user entered anything but 0
		run("Blobs (25K)");
		run("Set Scale...", "distance=" + scale + " known=1 unit=µm global");
		close("blobs.gif");
	}

	if (!AlteredName)
		open(input + "Results Summary.csv");
	else
		open(input + ResultsName);

	/*
	*  --------------------------------------------------------------------------------------------------------------------
	*  											Create and Read Dialog 2:
	*  								This Part of the Macro creates a 2nd Dialog after reading
	*  								the summary .csv and enters the Mean +- StdDev as defaults 
	*  								in the Dialog fields, thus helping the user to choose good
	*  								parameters.
	*  --------------------------------------------------------------------------------------------------------------------
	*/
	
	measurementsUpLimitDefault = newArray(measurements.length);
	measurementsLowLimitDefault = newArray(measurements.length);

	TableLength = Table.size;
	for (i = 0; i < measurements.length; i++) {
		if (measurements[i] == "Angle" || measurements[i] == "FeretAngle"){		// Angle only really makes any sense to go from 0 - 180° 
			measurementsUpLimitDefault[i] = 180;								// but the user will still have to option to choose them
			measurementsLowLimitDefault[i] = 0;
		}
		else if (measurements[i] == "X"){										// since X is a position, only min-max is sensible
			measurementsUpLimitDefault[i] = "max";								// set in imagewidth here
			measurementsLowLimitDefault[i] = "min";
		}
		else {
			Mean = Table.get("Mean " + measurements[i], TableLength-1);			// TableLength, since the last row contains the correct mean and
			StdDev = Table.get("StdDev " + measurements[i], TableLength-1);		// standard deviation. needs to be minus 1 since it doesnt start at 0
			Min = parseFloat(Mean) - parseFloat(StdDev);
			Max = parseFloat(Mean) + parseFloat(StdDev);
			measurementsUpLimitDefault[i] = Max;							
			measurementsLowLimitDefault[i] = Min;
		}
	}
	
	Dialog.create("Set Parameters for Post Analysis Uniform Heat-Map generation:");
	for (i = 0; i < measurements.length; i++) {
		if(ChosenMeas[i] == true && i != 1){								// Only create Dialog fields of the Heat-Maps that are chosen. Also exclude X , see above
			Dialog.addNumber("Upper Limit of " + measurements[i], measurementsUpLimitDefault[i]);
			Dialog.addNumber("Lower Limit of " + measurements[i], measurementsLowLimitDefault[i]);				
		}
	}
	Dialog.show();

	// The reading of the dialog numbers is quite complicated, since the amount of dialog.addnumber fields varies based on user impact. thus a new array needs to be created with only the chosen
	// measurements as their nominators (essentially a trimmed "measurements" array, and a up and low limit based on the size of that array:
	counter = 0;
	for (i = 0; i < ChosenMeas.length; i++) {
		if(ChosenMeas[i])
			counter += 1;													// counts the amount of trues inside ChosenMeas i.e. the amount of chosen parameters for heat map generation
	}
	TrimmedMeasurements = newArray(counter);								// creates a new array with the size of the amounts of trues in Chosen Meas
	measurementsUpLimit = newArray(TrimmedMeasurements.length);
	measurementsLowLimit = newArray(TrimmedMeasurements.length);
	counter = 0;
	for (i = 0; i < ChosenMeas.length; i++) {
		if(ChosenMeas[i]){
			TrimmedMeasurements[counter] = measurements[i];					// writes the nominators of the measuremts inside the new trimmed array (e.g. "area", "FeretAngle") in the correct order (carried out with counter)
			counter += 1;
		}
	}
	 
	for (i = 0; i < TrimmedMeasurements.length; i++) {
		measurementsUpLimit[i] = Dialog.getNumber();
		measurementsLowLimit[i] = Dialog.getNumber();
	}

	if (!OldFolders)
		output = getDirectory("Choose the directory output!");
	
	/*
	*  --------------------------------------------------------------------------------------------------------------------
	*  											Process the Images:
	*  --------------------------------------------------------------------------------------------------------------------
	*/
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i])) {							// loop for each file
			TrueName = replace(list[i], "/", ""); 						// the Name of the file will always be a ImageofExperiment001_01/ i.e. a folder designation. thus the / needs to indicate a file again.
			open(input + list[i] + TrueName + ImageTypeChoice);			// Input Folder -> Image folder (list[i]) -> Name of the Image + " Shape Filtered.png" or any other image type.
			ThresholdValue1();
			run("Analyze Particles...", "clear add");
			if (Number)
				roiManager("Show All with labels"); 					// Cell Numbers in heat-maps decision
			else 
				roiManager("Show All without labels");
			for (x = 0; x < TrimmedMeasurements.length; x++){			// loop for each measurement type	
				run("Duplicate...", " ");				
				run("ROI Color Coder", "measurement=" + TrimmedMeasurements[x] + " lut=[" + LUT + "] width=0 opacity=80 label=µm^2 range=" + parseFloat(measurementsLowLimit[x]) + "-" + parseFloat(measurementsUpLimit[x]) + " n.=5 decimal=3 ramp=[512 pixels] font=SansSerif font_size=14 draw");
				if (uni == 0) {
					if (OldFolders)
						saveAs("PNG", input + TrimmedMeasurements[x] + " Uniform Ramp.png");
					else {
						File.makeDirectory(output + TrimmedMeasurements[x]);						
						saveAs("PNG", output + TrimmedMeasurements[x] + " Uniform Ramp.png");										
					}			
				}
				close();
				run("Flatten");
				if (OldFolders)
					saveAs("PNG", input + list[i] + TrueName + " " + TrimmedMeasurements[x] + " Uniform Heat-Map.png");
				else 
					saveAs("PNG", output + TrimmedMeasurements[x] + File.separator + TrueName + " " + TrimmedMeasurements[x] + " Uniform Heat-Map.png");	
				close();	
			}	
			run("Close All");
			close("ROI Manager");
			uni = 1;			
		}			
	}
}

macro "Automated Muscle Size Identifier" {
	InputMSI = getDirectory("Choose the Directory of the Prediction Maps");
	
	Dialog.create("Set Parameters for Evaluation");
	if (is("global scale")) 
		Dialog.addMessage("A global scale was found. If you want to keep it, enter 0.");
	else 
		Dialog.addMessage("No global scale was found. Enter your Scale:");
	Dialog.addNumber("Set Scale (Pixels/µm):", 2.267);
	// Dialog.addString("Enter the suffix", ".png");	Prediction Maps will always be .png, shouldn't be required here. Can be changed if converted before.
	// Note: Watershedding is also removed. It is one of the most computing intensive processes in the macro and it will be removed entirely by a single Dilate
	// Operation anyway. Thus, for images of the main macro it is crucial, for the muscle mask alone it is not required.
	Dialog.addNumber("Prediction Map Threshold", 140);
	Dialog.addNumber("Area Opening Value", 3500);
	Dialog.addNumber("Number of Dilate-Erode Loops", 10);
	Dialog.addCheckbox("Apply Shape Filters:", false);
	Dialog.addNumber("Maximum Cell Size Threshold", 200000);
	Dialog.addNumber("Minimum Cell Size Threshold", 150);
	Dialog.addNumber("Maximum Circularity Threshold", 1.0);
	Dialog.addNumber("Minimum Circularity Threshold", 0.10);
	Dialog.addNumber("Maximum minFeret", 50);
	Dialog.addCheckbox("Save Muscle Masks", false);
	Dialog.addCheckbox("Save everything in new Folder", false);
	Dialog.addCheckbox("Hide Images While Processing", false);
	Dialog.show();
	
	scale = Dialog.getNumber();
	// suffix = Dialog.getString();  ^ removed, see above
	Threshold = Dialog.getNumber();
	AreaOpening = Dialog.getNumber();
	LoopCount = Dialog.getNumber();
	SFilter = Dialog.getCheckbox();
	MaxSizeT = Dialog.getNumber();
	MinSizeT = Dialog.getNumber();
	MaxCircT = Dialog.getNumber();
	MinCircT = Dialog.getNumber();
	MaxFeret = Dialog.getNumber();
	SaveMMs = Dialog.getCheckbox();
	newFolder = Dialog.getCheckbox();
	BatchMode = Dialog.getCheckbox();

	// Setup:
	if (scale != 0) {																//Apply global scale if user entered anything but 0
		run("Blobs (25K)");
		run("Set Scale...", "distance=" + scale + " known=1 unit=µm global");
		close("blobs.gif");
	}
	if (BatchMode)																	//Batch Mode should be optional, since viewing the images during processing can help to optimize parameters sooner
		setBatchMode("hide");
	if (newFolder)
		OutputMSI = getDirectory("Choose a directory for the output!");
	
	list = getFileList(InputMSI);													// File List
	list = Array.sort(list);
	globalSizeArray = newArray(list.length);
	setOption("ExpandableArrays", true);
	ll = list.length;
	NumberIndex = Array.getSequence(list.length);
	Table.create("Data Summary");													// Generate Table for General Results
	Table.setColumn("File Name", list);
	Table.setColumn("Number", NumberIndex);
	Table.setColumn("Area", NumberIndex);	
	Table.update;
	index = 0;

	for (i = 0; i < list.length; i++) {											//-4 dirty here
		open(InputMSI + list[i]);
		// Post Processing and Muscle Mask Generation
		setThreshold(Threshold, 255);
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Analyze Particles...", "size=150-Infinity circularity=0.10-1.00 show=[Count Masks] display exclude clear"); // Minimal Threshold to remove artifacts
		run("Count Masks to Binary Converter");
		if (SFilter)
			run("Extended Particle Analyzer", " area=" + MinSizeT + "-" + MaxSizeT + " circularity=" + MinCircT + "-" + MaxCircT + " max_feret=0-" + MaxFeret + " show=[Count Masks] redirect=None keep=None display exclude clear add");					
		run("Count Masks to Binary Converter");
		for (a = 0; a < LoopCount; a++){
			run("Dilate");
		}
		for (a = 0; a < LoopCount; a++){
			run("Erode");
		}
		run("Invert");
		run("Area Opening", "pixel=" + AreaOpening); // removing artifacts
		run("Invert");
		// Muscle Mask is ready here, but the Size needs to be evaluated now
		run("Analyze Particles...", "size=0-Infinity show=[Count Masks] display clear"); // opens results table of all objects in the image
		run("Count Masks to Binary Converter");
		name = getTitle();																// not sure if required
		selectWindow("Results");
		sizeArray = Table.getColumn("Area");
		sizeArray = Array.sort(sizeArray);												// sorts the Array on the size
		selectWindow("Data Summary");
		Table.set("Area", index, sizeArray[sizeArray.length-1]);						// prints the last number of sizeArray, which should always be the largest Area in the Table due to Array.sort
		globalSizeArray[i] = sizeArray[sizeArray.length-1];
		//The following is required since the size at this point is a float number. if you analyze with a float number, rounding errors will occur
		//The only way to ensure the largest muscle is selected in the upcoming analyze particles, the float number needs to be rounded and reduced. 
		temp = round(globalSizeArray[i]) - 1;
		selectWindow(name);																// not sure if required	
		run("Analyze Particles...", "size=" + temp + "-Infinity show=[Count Masks] display clear"); // filters image to only show largest object
		run("Count Masks to Binary Converter");											// might also be possible to skip this by not choosing Count masks.
		if (SaveMMs){
			if (newFolder)
				saveAs("PNG", OutputMSI + File.separator + list[i] + " Muscle Mask.png");
			else
				saveAs("PNG", InputMSI + File.separator + list[i] + " Muscle Mask.png");
		}
		run("Close All");
		index += 1;		
	}
	// Create a summary table with min, max, mean stdDev averages and save them as a .csv
	selectWindow("Data Summary");
	Array.getStatistics(globalSizeArray, min, max, mean, stdDev);
	specialStatArray = newArray(min, max, mean, stdDev);
	statNominator = newArray("Min:", "Max:", "Mean:", "StdDev:");
	for (i = 0; i < 4; i++) {
		Table.set("File Name", index, statNominator[i]);
		Table.set("Area", index, specialStatArray[i]);
		index += 1;
	}
	Table.update;
	if (newFolder)
		saveAs("Results", OutputMSI + "Muscle Size Identification.csv");
	else
		saveAs("Results", InputMSI + "Muscle Size Identification.csv");
	
}

macro "Count Masks to Binary Converter" {
	setThreshold(1, 65535);
	setOption("BlackBackground", true);
	run("Convert to Mask");
}

macro "Create Muscle Mask" {
	for (i = 0; i < 10; i++) {
		run("Dilate");
	}
	for (i = 0; i < 10; i++) {
		run("Erode");
	}
	run("Invert");
	run("Area Opening", "pixel=3500");
	run("Invert");
	run("Analyze Particles...", "size=500000-Infinity show=[Count Masks] clear");
	setThreshold(1, 65535);
	setOption("BlackBackground", true);
	run("Convert to Mask");
}