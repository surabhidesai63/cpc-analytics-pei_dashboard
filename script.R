library(dplyr)
library(gapminder)
library(aws.s3)

# Create sample data
eu_stats <- gapminder %>%
  filter(continent == "Europe", year == 2007) %>%
  group_by(country) %>%
  summarise(
    AvgLifeExp = mean(lifeExp),
    AvgGdpPercap = mean(gdpPercap)
  )

# Check the data (optional)
print(head(eu_stats))

# Save to a temporary local file
temp_file <- tempfile(fileext = ".csv")
write.csv(eu_stats, temp_file, row.names = FALSE)

# Read the file content to verify it is written correctly
cat("CSV File Content:\n")
print(read.csv(temp_file))

# Define S3 bucket and object path
bucket_name <- "pei-test-bucket"
object_key <- "eu_stats.csv"

# S3 upload without specifying credentials manually
put_object(
  file = temp_file,
  object = object_key,
  bucket = bucket_name
)

# Optional: Check if the upload was successful
if (object_exists(object_key, bucket_name)) {
  message("File successfully uploaded to S3!")
} else {
  message("Failed to upload the file.")
}

# Clean up
unlink(temp_file)  # Deletes the temporary file
