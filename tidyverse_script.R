# Load necessary libraries
library(tidyverse)
library(aws.s3)

# Step 1: Data Manipulation
# Load the mtcars dataset and create a summary
data <- mtcars
summary_data <- data %>%
  rownames_to_column("car") %>%
  mutate(
    efficiency = mpg / wt
  ) %>%
  select(car, mpg, wt, efficiency) %>%
  arrange(desc(efficiency))

# Print to verify
print("Summary Data:")
print(summary_data)

# Step 2: Save to S3
# Set up AWS credentials using environment variables
# Ensure AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_DEFAULT_REGION are set in your environment.

bucket_name <- "pei-test-bucket"
object_key <- "summary_data.csv"

# Convert the data frame to a CSV
temp_file <- tempfile(fileext = ".csv")
write_csv(summary_data, temp_file)

# Upload the CSV file to S3
put_object(
  file = temp_file,
  object = object_key,
  bucket = bucket_name
)

print(paste("Data successfully uploaded to S3 at", bucket_name, object_key))
