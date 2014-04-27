require(plyr)
require(reshape2)

## HAR - Human Activity Recognition Using Smartphones

har.url <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
har.zip <- "har.zip"
if (!file.exists(har.zip))
    download.file(har.url, destfile = har.zip, method = "curl")

unzip(har.zip)
har.dir <- "UCI HAR Dataset"
setwd(har.dir)

test.dir <- "test/"
train.dir <- "train/"

features.names <- read.table("features.txt", colClasses = rep("character", 2))
colnames(features.names) <- c("id", "name")

activity.lbls <- read.table("activity_labels.txt", colClasses = rep("character", 2))
colnames(activity.lbls) <- c("id", "name")
map.activity <- function(i) activity.lbls[i, ]$name

read.HAR <- function(type) {
    if (!file.exists(paste(type, "/", sep = "")))
        return(NULL)
    
    y.file <- paste(type, "/y_", type, ".txt", sep = "")
    x.file <- paste(type, "/X_", type, ".txt", sep = "")
    subject.file <- paste(type, "/subject_", type, ".txt", sep = "")
    
    y <- read.table(y.file, col.names = "activity", colClasses = "character")
    y <- mutate(y, activity = map.activity(activity))
    
    obj <- read.table(subject.file, col.names = "subject")
    obj <- cbind(obj, y)
    
    x <- read.table(x.file, colClasses = "numeric")
    colnames(x) <- features_names$name
    
    cbind(obj, x)
}

test <- read.HAR("test")
train <- read.HAR("train")

## data.aggr - the aggregate of test and train data frames
data.aggr <- rbind(train, test)

re <- "(-mean\\(\\)|-std\\(\\))"

## data.msd - data frame with measurements of means and standard deviations
data.msd <- data.aggr[, grepl(re, colnames(data.aggr))]
data.msd <- cbind(data.aggr[, c("subject", "activity")], data.msd)

write.table(data.aggr, file = "../har-aggregated.data", row.names = F)
write.table(data.msd, file = "../har-only-mean-std.data", row.names = F)

## data.ind  - independent tidy data set with the average
## of each variable for each activity and each subject
data.melt <- melt(data.aggr, id = c("subject", "activity"))
data.ind <- acast(data.melt, subject + activity ~ variable, mean)

write.table(data.ind, file = "../har-independent.data")


