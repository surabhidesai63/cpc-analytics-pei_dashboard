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

# Save to a temporary local file
temp_file <- tempfile(fileext = ".csv")
write.csv(eu_stats, temp_file, row.names = FALSE)

# Define S3 bucket and object path
bucket_name <- "pei-test-bucket"
object_key <- "eu_stats.csv"  # or specify a folder, e.g., "data/eu_stats.csv"

# # Set up AWS credentials (make sure to replace with your actual credentials)
# Sys.setenv("AWS_ACCESS_KEY_ID" = "AKIA2MNVLVYL5LXUW27A",
#            "AWS_SECRET_ACCESS_KEY" = "earT7lpH8U2EKkLVjaNnXtPCE35M5hnvBauDYYa/",
#            "AWS_DEFAULT_REGION" = "us-east-1")  # Adjust region if necessary

# Upload the file to S3
# put_object(file = temp_file, bucket = bucket_name, object = object_key,verbose= TRUE)

# S3 upload without specifying credentials manually
put_object(
  file = temp_file,
  object = object_key,
  bucket = bucket_name
)
# cat("AWS Access Key:", Sys.getenv("AWS_ACCESS_KEY_ID"), "\n")
# cat("AWS Session Token:", Sys.getenv("AWS_SESSION_TOKEN"), "\n")
# Optional: Check if the upload was successful
if (object_exists(object_key, bucket_name)) {
  message("File successfully uploaded to S3!")
} else {
  message("Failed to upload the file.")
}
q("no") 
