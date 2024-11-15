# Base image
FROM rocker/r-ver:4.3.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev

# Install R packages
RUN R -e "install.packages(c('tidyverse', 'here', 'rentrez', 'aws.s3', 'XML'), repos='https://cloud.r-project.org/')"

# Set the working directory
WORKDIR /usr/src/app

# Copy the R script to the container
COPY code/1_querying_api.R /usr/src/app/1_querying_api.R

# Set environment variables for AWS
ENV AWS_ACCESS_KEY_ID=<your_access_key>
ENV AWS_SECRET_ACCESS_KEY=<your_secret_key>
ENV AWS_DEFAULT_REGION=<your_region>

# Run the R script
CMD ["Rscript", "/usr/src/app/1_querying_api.R"]
