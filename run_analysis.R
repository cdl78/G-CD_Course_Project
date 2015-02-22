#### Getting and Cleaning Data: Course Project
#### Author: Christopher Loental
#### Email: christopher.loental@gmail.com

# Usage Notes
#------------------------------------------------------------------
# this R script requires the library "plyr"

# place script inside unzipped data-directory "UCI HAR Dataset"

# set workig directory to dataset directory
# > setwd("~/whatever/UCI HAR Dataset")
# > source('tidy.R')

# Scripts writes "TIDY.txt" to working directory
# to open this dataset in R:
# > test <- read.table("TIDY.txt", header=TRUE)
# > View(test)


library(plyr)

# read features and activity labels in tables
features <- read.table("features.txt")
labels <- read.table("activity_labels.txt")

# read "test" data sets, apply activity labels to column names
xtest <- read.table("test//X_test.txt", col.names=features[, 2])
ytest <- read.table("test/y_test.txt")
sub_test <- read.table("test/subject_test.txt")

# read "train" data sets, apply activity labels to column names
xtrain <- read.table("train//X_train.txt", col.names=features[, 2])
ytrain <- read.table("train//y_train.txt")
sub_train <- read.table("train//subject_train.txt")

# create frames for test and train
df_test <- cbind(sub_test, ytest, xtest)
df_train <- cbind(sub_train, ytrain, xtrain)

# manually assign subject/activity names to each dataframe before merging
colnames(df_test)[1] = "subject"
colnames(df_test)[2] = "activity"
colnames(df_train)[1] = "subject"
colnames(df_train)[2] = "activity"

# concatenate test and train dataframes
df_merge <- rbind(df_test, df_train)

# apply activity names to merged dataframe
labels[, "V2"] <- sapply(labels[, "V2"], as.character)
temp <- labels[["V2"]]
for (i in seq(1:length(temp))) {
  df_merge$activity[df_merge$activity == i] <- temp[i]
}

# extract column numbers which match substring searches for "mean" and "std"
z <- sort(c(1,2,grep("mean", colnames(df_merge)),grep("std", colnames(df_merge))))

# subset the dataframe to only include the above columns
tidy_1 <- df_merge[, z]

# use plyr to split the dataframe by subject/acitivy and apply mean to each column
tidy_2 <- ddply(tidy_1, .(subject, activity), numcolwise(mean))

# write tidy_2 as table to text file
write.table(tidy_2, "TIDY.txt", row.names=FALSE)
