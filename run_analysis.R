#----------------------------------------------------------------------------------------------
#########################Module 1#########################
#Download module (Begin)
#----------------------------------------------------------------------------------------------

temp <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
              temp)
unzip(temp)
unlink(temp)

#----------------------------------------------------------------------------------------------
#Download module (End)
#----------------------------------------------------------------------------------------------



#----------------------------------------------------------------------------------------------
#########################Module 2#########################
#Read Files module (Start)
#----------------------------------------------------------------------------------------------

#activityLabels<-(readLines("./UCI\ HAR\ Dataset/activity_labels.txt"))

activityLabels<-read.table("./UCI\ HAR\ Dataset/activity_labels.txt", sep="")
features<-read.table("./UCI\ HAR\ Dataset/features.txt", sep = "")
subject_test <- read.table("./UCI\ HAR\ Dataset/test/subject_test.txt", sep="")
subject_train <- read.table("./UCI\ HAR\ Dataset/train/subject_train.txt", sep="")
x_train <- read.table("./UCI\ HAR\ Dataset/train/x_train.txt", sep="")
y_train <- read.table("./UCI\ HAR\ Dataset/train/y_train.txt", sep="")
x_test <- read.table("./UCI\ HAR\ Dataset/test/x_test.txt", sep="")
y_test <- read.table("./UCI\ HAR\ Dataset/test/y_test.txt", sep="")

#----------------------------------------------------------------------------------------------
#Read Files module (End)
#----------------------------------------------------------------------------------------------



#----------------------------------------------------------------------------------------------
#########################Module 3#########################
#Create clean dataset module (Start)
#----------------------------------------------------------------------------------------------

#Get all feature names
uniqueFeatureNames <- make.names(features$V2, unique = TRUE)

#Assign levels that will be used for activities 
#Using this to assign walking to the vast majority of user-activities, but will change it 
#to the correct activity afterward
activityTest <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", 
                  "SITTING", "STANDING", "LAYING", 
                  rep("WALKING", nrow(y_test)-6))
activityTrain <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", 
                   "SITTING", "STANDING", "LAYING", 
                   rep("WALKING", nrow(y_train)-6)) #this is done to induce the 6 levels, 
                                                    #otherwise the ActivityName column will not 
                                                    #update

#Creating a test dataframe by first binding the subject and activity columns together, 
#followed by binding the activity Name, and finally with the feature columns
testDF <- cbind(subject_test, y_test)
testDF <- cbind(testDF, activityTest)
testDF <- cbind(testDF, x_test)
testDF_names <- as.list(c("Subject", "Activity", "ActivityName", as.list(uniqueFeatureNames)))
colnames(testDF)<-testDF_names

#Creating a train dataframe by first bidning the subject and activity columns together, 
#followed by binding the activity Name, and finally with the feature columns
trainDF <- cbind(subject_train, y_train)
trainDF <- cbind(trainDF, activityTrain)
trainDF <- cbind(trainDF, x_train)
colnames(trainDF)<-testDF_names #same column name set can be used!

#Row binding the test and train data sets
fullDF <- rbind(testDF, trainDF)

#library("qdap")

#Update the activity names to the appropriate ones using activity index
fullDF$ActivityName[fullDF$Activity==1] <- "WALKING"
fullDF$ActivityName[fullDF$Activity==2] <- "WALKING_UPSTAIRS"
fullDF$ActivityName[fullDF$Activity==3] <- "WALKING_DOWNSTAIRS"
fullDF$ActivityName[fullDF$Activity==4] <- "SITTING"
fullDF$ActivityName[fullDF$Activity==5] <- "STANDING"
fullDF$ActivityName[fullDF$Activity==6] <- "LAYING"

#Remove the Activity column from the data frame... 
fullDF$Activity <- NULL 

#Find mean and std feature subsets. Note that since grep is case sensitive, it excludes 
#Mean, and therefore any of the angle mean features automatically 
#Also getting the subject and activity subsets for naming these columns first
mean_subset <- fullDF[, grep("mean", colnames(fullDF))]
std_subset <- fullDF[, grep("std", colnames(fullDF))]
subject_subset <- fullDF[, 1]
activity_subset <- fullDF[, 2]

#Getting only the subject and activity columns to name them first...
final_set <- cbind(subject_subset, activity_subset)
colnames(final_set) <- c("Subject", "ActivityName")

#Column binding the mean and std subsets to get the final required data frame...
final_set <- cbind(final_set, mean_subset)
final_set <- cbind(final_set, std_subset)
#head(final_set)
#ncol(final_set)



#----------------------------------------------------------------------------------------------
#Create clean dataset module (End)
#----------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------
#########################Module 4#########################
#Create tidy data set (Begin)
#----------------------------------------------------------------------------------------------


library(reshape)
#detach("package:reshape2", unload=TRUE)

#Here I have created a tall skinny data set using the melt function
final_melt <- melt(final_set, id = c("Subject", "ActivityName"), 
                   measure.vars = c(colnames(mean_subset), colnames(std_subset)))
# head(final_melt)
# tail(final_melt)
# nrow(final_melt)

#Using dcast to get the means of each variable across subject and activity name 
#This creates a wide tidy data set
detach("package:reshape", unload=TRUE) # not needed...
library(reshape2)
means_tidy_df <- dcast(final_melt, Subject+ActivityName ~ variable, fun = mean)
# means_tidy_df
# nrow(means_tidy_df) #180 = 30*6
# ncol(means_tidy_df) # 81 = subject(1 col) + activity name (1 col) + 79 mean and std variables
# head(means_tidy_df, 5)
# tail(means_tidy_df, 5)

#Now use write.table to get the text file of the tidy data set for submission
write.table(means_tidy_df, file = "tidy_data_set.txt", row.name = FALSE)

#----------------------------------------------------------------------------------------------
#Create tidy data set (End)
#----------------------------------------------------------------------------------------------



####################For Code Book####################
#write.table(colnames(means_tidy_df), file = "code_book.txt", row.name = FALSE)
