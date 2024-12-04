# Use an official R image as the base
FROM rocker/r-ver

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && apt-get clean

# Install tidyverse
RUN Rscript -e "install.packages('tidyverse', repos='https://cloud.r-project.org/')"

# Set the working directory
WORKDIR /usr/src/app

# Copy the R script
COPY code/1_querying_api.R /usr/src/app/1_querying_api.R

# Command to run the script
CMD ["Rscript", "/usr/src/app/1_querying_api.R"]
