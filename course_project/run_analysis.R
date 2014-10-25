library(plyr)

# Step 1: Merges the training and the test sets to create one data set.

# read the test dataset
test<-read.table("UCI HAR Dataset\\test\\X_test.txt")
# read the activity label of the test dataset
test_act<-read.table("UCI HAR Dataset\\test\\y_test.txt")
# read the subject of the test dataset
test_sbj<-read.table("UCI HAR Dataset\\test\\subject_test.txt")

# read the training dataset
train<-read.table("UCI HAR Dataset\\train\\X_train.txt")
# read the activity label of the training dataset
train_act<-read.table("UCI HAR Dataset\\train\\y_train.txt")
# read the subject of the training dataset
train_sbj<-read.table("UCI HAR Dataset\\train\\subject_train.txt")

# combine the test and training datasets
data<-rbind(cbind(test_sbj,test_act,test),cbind(train_sbj,train_act,train))
# Assign labels to the 1st two columns.
colnames(data)[1]<-"Subject"
colnames(data)[2]<-"Activity"

# Step 2: Extracts only the measurements on the mean and standard deviation for each measurement.

#read the features
features<-read.table("UCI HAR Dataset\\features.txt")

# extracting the the mean and standard deviation measurements 
reqFeatures<-grepl("-mean()",features$V2,fixed=TRUE)|grepl("-std()",features$V2,fixed=TRUE)
reqColumns<-c(TRUE,TRUE,reqFeatures) # keep the 1st two columns (i.e. Subject and Activity)
reqData<-data[,reqFeatures]


# Step 3: Uses descriptive activity names to name the activities in the data set
# read the activity name mapping data
act_names<-read.table("UCI HAR Dataset\\activity_labels.txt")
# replace the activity label with corresponding activity name.
reqData<-mutate(reqData,Activity=act_names$V2[reqData$Activity])

# Step 4: Appropriately labels the data set with descriptive variable names.  
# extracting the required features' names as variable names
variableNames<-features$V2[reqFeatures]

# remove the brackets from the variable names and assign to the measurement columns.
colnames(reqData)[-c(1:2)]<-as.character(gsub("()","",variableNames,fixed=TRUE))


# Step 5: From the data set in step 4, 
# creates a second, independent tidy data set with the average of each variable 
# for each activity and each subject.

library(reshape2)
# melt the result dataset in step 4 and reshape it to means displayed by activity by subject.
meltedData<-melt(reqData,id=c("Subject","Activity"),measure.vars=-c(1:2))
featureMean<-dcast(meltedData,Subject+Activity~variable,mean)
#output the new dataset to a file
write.table(featureMean,"featureMean.txt",append=FALSE,row.names=FALSE,quote=FALSE,sep=",")