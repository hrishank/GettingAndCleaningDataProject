Note that the script can be run correctly if it is placed in the same folder containing "UCI HAR Dataset", i.e. the unzipped folder. 
For example, if you have the "UCI HAR Dataset" folder in Documents, then place this script in the Documents folder as well for it to run 
properly. You will also need to set the working directory to Documents (following the example) for this to work.

I have 4 main modules that I utilize to write my script for the project. I am going to describe that in detail here: 

Module 1: Download Module
I use this module to download the zip file and to unzip this file and and unlink it




Module 2: Read Files module 
Here, I read the activity_labels.txt, features.txt, subject_test.txt, subject_train.txt, x_train.txt, y_train.txt, x_test.txt, and y_test.txt 
files. I use read.table to read in these text files into 8 separate data frames. I do not read any of the data from the Inertial Signals 
folders. 




Module 3: Create clean dataset module
First, I extract all the feature names, and make them unique (using make.names()), since some names were dupliacated. 
This should not matter later as these duplicates are not related to the mean or std variables that I shall isolate for later. 

Second, I assign the six activity names randomly to dataframes that have the same number of rows as the test and train data sets. 

Third, I create the test data frame by first binding the subject and activity columns together, followed by binding the activity name (from the second step), 
and finally the feature columns (all 561). I then repeat this for train data set to create a train data frame. 

Fourth, I row bind the test and train data sets. 

Fifth, I update the activity names in the activity name column to the accurate names by using the activity number column. I do this this way 
because it helps to set up the levels beforehand. 

Sixth, I remove the activity column (not the activity names column) because we don't need that column with the activity IDs. 

Seventh, I use the grep function to find the column names with "mean" and "std" in them to isolate for mean() and std() measurements.
Note that since grep uses case-sensitive arguments, the variable names with "Mean" in them (related to angle) are not included. 

Eighth, I restructure the data set to contain the subject ID, activity name, and the mean and std features along with the column names. 

Now we have our pre-processed data set. 




Module 4: Create tidy data set

Here I have created a tall skinny data set using the melt function from the reshape package. 
Then, I use dcast (from reshape2 package) to get the means of each variable across subject and activity name. This creates a wide tidy data set. 

Finally, I write this wide tidy data set containing means of each mean() and std() variables grouped over each subject-activity combination 
to tidy_data_set.txt

