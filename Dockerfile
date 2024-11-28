# Use the official R base image
FROM rocker/r-ver:4.3.1

# Install necessary packages
RUN R -e "install.packages(c('tidyverse', 'aws.s3'), repos='http://cran.r-project.org')"

# Copy the R script into the container
COPY tidyverse_script.R /app/tidyverse_script.R

# Set the working directory
WORKDIR /app

# Set environment variables for AWS credentials
ENV AWS_ACCESS_KEY_ID=AKIA2MNVLVYL5LXUW27A
ENV AWS_SECRET_ACCESS_KEY=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
ENV AWS_DEFAULT_REGION=us-east-1

# Run the R script
CMD ["Rscript", "tidyverse_script.R"]
