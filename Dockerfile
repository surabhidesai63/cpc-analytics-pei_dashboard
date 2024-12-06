# Use an official R image as the base
FROM rocker/r-ver:4.3.0

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && apt-get clean

# Install tidyverse
RUN Rscript -e "install.packages('tidyverse', repos='https://cloud.r-project.org/')"

RUN Rscript -e "install.packages(c('rentrez','here','aws.s3'), repos='https://cloud.r-project.org/')"


# Set the working directory
WORKDIR /usr/src/app

# Copy the R script
COPY code/1_querying_api.R /usr/src/app/1_querying_api.R

# Command to run the script
CMD ["Rscript", "code/1_querying_api.R"]
