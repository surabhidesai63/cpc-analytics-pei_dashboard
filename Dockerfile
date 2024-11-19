# Use an official R image as the base image
FROM rocker/r-ver:4.3.0

# # Install system dependencies
# RUN apt-get update -qq && apt-get install -y \
#     libcurl4-openssl-dev \
#     libssl-dev \
#     libxml2-dev \
#     && apt-get clean

# Install R packages one by one
RUN R -e "install.packages('XML', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('here', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rentrez', repos='http://cran.rstudio.com/')"

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the R script to the container
COPY code/1_querying_api.R /usr/src/app/1_querying_api.R

# # Set environment variables for AWS (if using S3 access)
# ENV AWS_ACCESS_KEY_ID=your_access_key
# ENV AWS_SECRET_ACCESS_KEY=your_secret_key
# ENV AWS_DEFAULT_REGION=your_region

# Run the R script
CMD ["Rscript", "/usr/src/app/1_querying_api.R"]
