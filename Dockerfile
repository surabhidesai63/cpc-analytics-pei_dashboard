FROM rocker/r-ver:4.3.0

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    git \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    && apt-get clean

# Install tidyverse with verbose output
RUN Rscript -e "install.packages('tidyverse', repos='https://cran.rstudio.com/', dependencies = TRUE)"

# Install additional R packages
RUN Rscript -e "install.packages(c('rentrez','here','aws.s3'), repos='https://cran.rstudio.com/')"

# Clone the GitHub repository
RUN git clone https://github.com/surabhidesai63/cpc-analytics-pei_dashboard.git /usr/src/app

# Set the working directory
WORKDIR /usr/src/app

# Copy the R script
COPY code/1_querying_api.R /usr/src/app/1_querying_api.R

# Command to run the script
CMD ["Rscript", "code/1_querying_api.R"]
