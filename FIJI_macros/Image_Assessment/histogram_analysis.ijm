#@ File (label = "Image directory with ROI image sizes", style = "directory") input
//This line prompts the user to select an input directory containing images.
#@ String (label = "Image file suffix", value = ".png") suffix
//This line prompts the user to specify the file extension of the images (default is ".png").

list_input = getFileList(input);
//Get the list of all files in the input directory.
File.makeDirectory(input + File.separator + "Histogram_results");
//Create a new directory named "Histogram_results" inside the input directory to store the output results.
list_input = Array.sort(list_input);
//Sort the list of files alphabetically.
Table.create("Histo_Results");
//Create a new results table to store histogram data.

i = 0;
for (j = 0; j < list_input.length; j++) {
    //Loop over each file in the input directory.

    if (endsWith(list_input[j], suffix)) {
        //Check if the current file ends with the specified file suffix (e.g., ".png"
        open(input + File.separator + list_input[j]); 
        //Open the image file.
//        roisize_name = substring(getTitle(), 0, 11);
        //Extract the first 11 characters from the image title (assuming this represents the ROI size).
        getHistogram(values, counts, 256);
        //Generate the histogram for the current image. The 'values' array holds intensity values, and 'counts' holds the frequency of each intensity in 256 bins.
        getStatistics(area, mean, min, max, std, histogram);
        //Retrieve image statistics such as area, mean intensity, minimum intensity, maximum intensity, standard deviation, and the histogram.
        print(mean);
        //Print the mean intensity of the image (useful for debugging or checking output).
        // Count non-empty histogram bins (bins with a count greater than 0).
        non_empty_bins = 0;
        for (t = 0; t < 256; t++) {
            if (counts[t] > 0) {
                non_empty_bins++;
            }
        }

        // Initialize variables to store the minimum and maximum non-zero bins.
        min_bin = -1;
        max_bin = -1;

        // Loop through all bins to find the first and last non-zero bin (representing the range of intensity values present in the image).
        for (t = 0; t < 256; t++) {
            if (counts[t] > 0) {
                if (min_bin == -1) {
                    min_bin = t; //Set the first non-zero bin as the minimum intensity bin.
                }
                max_bin = t;//Continuously update the maximum intensity bin as you find non-zero bins.
            }
        }

        // Populate the table with the results for the current image.
        Table.set("Image Name", i, list_input[j]);
        //Store the image name in the table.
        Table.set("Mean Intensity", i, mean);
        //Store the mean intensity of the image.
        Table.set("Standard Deviation", i, std);
        //Store the standard deviation of intensity values.
        Table.set("Non-Empty Bins", i, non_empty_bins);
        //Store the number of non-empty bins in the histogram.
        Table.set("Min Intens Val", i, min_bin);
        //Store the minimum non-zero intensity value (smallest non-empty bin).
        Table.set("Max Intens Val", i, max_bin);
        //Store the maximum non-zero intensity value (largest non-empty bin).
        close("*");
        //Close the image after processing.
        i++;
        //Increment the table row index for the next image.
    }
}

//Save the table as a CSV file in the Histogram_results directory.
resultsFile = input + File.separator + "Histogram_results" + File.separator + "Histo_Results.csv";
Table.save(resultsFile);
//Save the results table as a CSV file with the filename "Histo_Results.csv".
