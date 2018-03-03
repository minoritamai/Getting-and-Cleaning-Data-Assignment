#make a directory and download data
if(!file.exists("./data")){dir.create("./data")}
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(Url, destfile = "./data/Dataset.zip")

#unzip data into the directory
unzip(zipfile = "./data/Dataset.zip", exdir = "./data")

#read training tables
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

#read test tables
X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

#read feature vector:
features <- read.table('./data/UCI HAR Dataset/features.txt')

#read activity labels:
activity_labels = read.table('./data/UCI HAR Dataset/activity_labels.txt')

#assign colum names on the train data
colnames(X_train) <- features[,2] 
colnames(y_train) <-"activityId"
colnames(subject_train) <- "subjectId"

#assign colum names on the test data
colnames(X_test) <- features[,2] 
colnames(y_test) <- "activityId"
colnames(subject_test) <- "subjectId"

#make activity label values
colnames(activity_labels) <- c('activityId','activityType')

#merges the training and the test sets to create merged data set
mg_train <- cbind(y_train, subject_train, X_train)
mg_test <- cbind(y_test, subject_test, X_test)
mg_dataset <- rbind(mg_train, mg_test)

#extracts only the measurements on the mean and standard deviation for each measurement
mean_and_std <- (grepl("activityId", colnames(mg_dataset)) | 
                        grepl("subjectId", colnames(mg_dataset)) | 
                        grepl("mean..", colnames(mg_dataset)) | 
                        grepl("std..", colnames(mg_dataset))
                 )

#make nessesary dataset
mean_and_std_dataset <- mg_dataset[ , mean_and_std == TRUE]

#uses descriptive activity names to name the activities in the data set
activitynames_set <- merge(mean_and_std_dataset, activity_labels, by='activityId', all.x=TRUE)

#appropriate labels are already created
#from the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidy_dataset_sec <- aggregate(. ~subjectId + activityId, activitynames_set, mean)
tidy_dataset_sec <- tidy_dataset_sec[order(tidy_dataset_sec$subjectId, tidy_dataset_sec$activityId), ]

#save the tidy data
write.table(tidy_dataset_sec, "tidy_dataset_sec.txt", row.name=FALSE)
