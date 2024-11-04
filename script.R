library(dplyr)
library(gapminder)
library(aws.s3)

# Statistics of Europe countries for 2007
eu_stats <- gapminder %>%
  filter(
    continent == "Europe",
    year == 2007
  ) %>%
  group_by(country) %>%
  summarise(
    AvgLifeExp = mean(lifeExp),
    AvgGdpPercap = mean(gdpPercap)
  )

# Save the file as CSV
write.csv(eu_stats, "home/r-environment/eu_stats.csv", row.names = FALSE)

# Set up AWS credentials (make sure to replace with your actual credentials)
Sys.setenv("AWS_ACCESS_KEY_ID" = "AKIA2MNVLVYL5LXUW27A",
           "AWS_SECRET_ACCESS_KEY" = "earT7lpH8U2EKkLVjaNnXtPCE35M5hnvBauDYYa/",
           "AWS_DEFAULT_REGION" = "us-east-1")  # Adjust region if necessary

# Upload to S3
s3_bucket_name <- "pei-test-bucket"  # Replace with your S3 bucket name
put_object(file = local_file_path, 
            object = "eu_stats.csv",  # Name of the file in S3
            bucket = s3_bucket_name)

# Optional: Check if the file was uploaded successfully
bucket_objects <- get_bucket(s3_bucket_name)

if ("eu_stats.csv" %in% sapply(bucket_objects, `[[`, "Key")) {
  print("File has been uploaded to S3 successfully.")
} else {
  print("File was not uploaded to S3.")
}
