---
title: "run_analysis.Rmd"
author: "MS"
date: "2024-12-20"
output: pdf_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## R Markdown

This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:

```{r}
library(dplyr)
```

```{r}
file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(file_url, "Dataset.zip")
unzip("Dataset.zip")
```

```{r}
# Read training data
x_train <- read.table("C:/Users/sumim/OneDrive/ドキュメント/Coursera datascience/Getting and Cleaning Data/Getting and Cleaning Data module 4/UCI HAR Dataset/train/X_train.txt", col.names = features[, 2])

y_train <- read.table("C:/Users/sumim/OneDrive/ドキュメント/Coursera datascience/Getting and Cleaning Data/Getting and Cleaning Data module 4/UCI HAR Dataset/train/y_train.txt", col.names = "activity_id")

subject_train <- read.table("C:/Users/sumim/OneDrive/ドキュメント/Coursera datascience/Getting and Cleaning Data/Getting and Cleaning Data module 4/UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
```

```{r}
str(y_train)
```

```{r}
# Read test data
x_test <- read.table("C:/Users/sumim/OneDrive/ドキュメント/Coursera datascience/Getting and Cleaning Data/Getting and Cleaning Data module 4/UCI HAR Dataset/test/X_test.txt", col.names = features[, 2])

y_test <- read.table("C:/Users/sumim/OneDrive/ドキュメント/Coursera datascience/Getting and Cleaning Data/Getting and Cleaning Data module 4/UCI HAR Dataset/test/y_test.txt", col.names = "activity_id")

subject_test <- read.table("C:/Users/sumim/OneDrive/ドキュメント/Coursera datascience/Getting and Cleaning Data/Getting and Cleaning Data module 4/UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
```

```{r}
# combine X training and test datasets
x_data <- rbind(x_train, x_test)

# combine Y training and test datasets
y_data <- rbind(y_train, y_test)

# Combine subject training and test datasets
subject_data <- rbind(subject_train, subject_test)
```

```{r}
# Read activity labels and features

activity_labels <- read.table("C:/Users/sumim/OneDrive/ドキュメント/Coursera datascience/Getting and Cleaning Data/Getting and Cleaning Data module 4/UCI HAR Dataset/activity_labels.txt", col.names = c("id", "activity"))

features <- read.table("C:/Users/sumim/OneDrive/ドキュメント/Coursera datascience/Getting and Cleaning Data/Getting and Cleaning Data module 4/UCI HAR Dataset/features.txt", col.names = c("index", "feature"))
```

```{r}
str(activity_labels)
```

```{r}
# Step 1: merge data
harus_data <- merge(merge(subject_data, y_data, by = 0, all = TRUE), x_data, by = 0, all = TRUE)
harus_data <- harus_data[, -c(1, 2)] # remove columns of Row.names
```

```{r}
# Step 2: Extract only the measurements on the mean and standard deviation for each measurement.

# Identify mean and standard deviation columns
mean_std_columns <- grep("-(mean|std)\\(\\)", features[, 2])
harus_data_v2 <- harus_data[, c(1, 2, mean_std_columns + 2)]
harus_data_v2
```

```{r}
# Step 3: Use descriptive activity names to name the activities in the data set.

harus_data_v2$activity_id <- factor(harus_data_v2$activity_id, levels = activity_labels[, 1], labels = activity_labels[, 2])
```

```{r}
# Step 4: Appropriately label the data set with descriptive variable names.

# Clean up variable names
clean_names <- gsub("[-()]", "", features[mean_std_columns, 2])
clean_names <- gsub("^t", "Time", clean_names)
clean_names <- gsub("^f", "Frequency", clean_names)
clean_names <- gsub("Acc", "Accelerometer", clean_names)
clean_names <- gsub("Gyro", "Gyroscope", clean_names)
clean_names <- gsub("Mag", "Magnitude", clean_names)
clean_names <- gsub("BodyBody", "Body", clean_names)

colnames(harus_data_v2)[3:ncol(harus_data_v2)] <- clean_names
harus_data_v2
```

```{r}
str(harus_data_v2)
```


```{r}
colnames(harus_data_v2)
```

```{r}
# Step 5: Create a second, independent tidy data set with the average of each variable for each activity and each subject.

harus_data_v2 <- harus_data_v2[, !duplicated(names(harus_data_v2))]

harus_tidy_data <- harus_data_v2 %>%
  group_by(subject, activity_id) %>% 
  summarise(across(everything(), mean), na.rm = TRUE)

harus_tidy_data
```

```{r}
write.table(harus_tidy_data, "harus_tidy_data.txt", sep = "\t", row.names = FALSE)
```

