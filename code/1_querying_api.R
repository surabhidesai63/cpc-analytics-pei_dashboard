# packages, directory -------------------------------------------------------
# libraries
library(tidyverse) # tools for data manipulation
library(here) # easily manage directories
library(rentrez) # direct access to NCBI/ PubMed database
library(aws.s3) # for S3 operations

# set working parameters --------------------------------------------------------

# directory setting
here::i_am("code/1_querying_api.R")

# communicating key to API
api_key <- "4e7696f07a04e00b907d0f55a80aaa100808"
set_entrez_key(api_key)

# AWS S3 configuration ---------------------------------------------------------
# Replace with your S3 bucket details
s3_bucket <- "your-s3-bucket-name"
s3_folder <- "data/raw/1_pubmed_xml_responses/"

# Define query terms -----------------------------------------------------------
query_terms <- '("health emergency"[Title/Abstract] 
  OR "health emergencies"[Title/Abstract] 
  OR "outbreak"[Title/Abstract] 
  OR "epidemic"[Title/Abstract]) 
  AND ("public health intelligence"[Title/Abstract] 
  OR "epidemic intelligence"[Title/Abstract] 
  OR "participatory surveillance"[Title/Abstract] 
  OR "syndromic surveillance"[Title/Abstract] 
  OR "event based surveillance"[Title/Abstract] 
  OR "integrated disease surveillance"[Title/Abstract] 
  OR "community based surveillance"[Title/Abstract]
  OR "behavioural surveillance"[Title/Abstract] 
  OR "behavioral surveillance"[Title/Abstract]
  OR "wastewater surveillance"[Title/Abstract] 
  OR "vector surveillance"[Title/Abstract] 
  OR "sentinel surveillance"[Title/Abstract] 
  OR "wildlife surveillance"[Title/Abstract] 
  OR "early warning system"[Title/Abstract] 
  OR "environmental monitoring"[Title/Abstract] 
  OR "modeling"[Title/Abstract] 
  OR "modelling"[Title/Abstract] 
  OR "mathematical epidemiology"[Title/Abstract] 
  OR "big data"[Title/Abstract] 
  OR "Artificial intelligence"[Title/Abstract] 
  OR "machine learning"[Title/Abstract] 
  OR "Genomic surveillance"[Title/Abstract] 
  OR "bioinformatics"[Title/Abstract] 
  OR "Simulator"[Title/Abstract] 
  OR "Simulation"[Title/Abstract] 
  OR "Decision support system"[Title/Abstract] 
  OR "digital twin"[Title/Abstract] 
  OR "natural language processing"[Title/Abstract] 
  OR "forecast*"[Title/Abstract] 
  OR "open source"[Title/Abstract] 
  OR "geospatial"[Title/Abstract] 
  OR "GIS"[Title/Abstract] 
  OR "internet search"[Title/Abstract])'

# FUNCTION: Concatenate date range with flexibility for iteration ---------------
format_year_for_query <- function(year) {
  paste0('(" ', year, '/01/01"[Date - Publication] : " ', year, '/12/30"[Date - Publication])')
}

# FUNCTION: Fetch records and save to S3 ---------------------------------------
fetch_pubmed_records <- function(year, query_terms) {
  print(paste("Processing year:", year))
  
  # Concatenate date range to slot into query
  query_date_range <- format_year_for_query(year)
  
  # Join query terms and date range
  query <- paste0(query_terms, ' AND ', query_date_range)
  
  # Search to the API + posting history
  query_search <- entrez_search(db = "pubmed", term = query, use_history = TRUE)
  
  print(query_search) # Check the number of records
  
  # Fetch records
  records <- entrez_fetch(db = "pubmed",
                          web_history = query_search$web_history,
                          retmax = 20000,
                          rettype = "xml",
                          parsed = TRUE)

  # Define file name for S3
  s3_file_name <- paste0(s3_folder, "query_results_", year, ".xml")
  
  # Save XML data to a temporary file
  temp_file <- tempfile(fileext = ".xml")
  XML::saveXML(records, temp_file)
  
  # Upload to S3
  put_object(file = temp_file, 
             object = s3_file_name, 
             bucket = s3_bucket)
  
  message(paste("Records for year", year, "saved successfully to S3...sleeping 10 seconds..."))
  Sys.sleep(10)
}

# USAGE ------------------------------------------------------------------------
years_list <- as.character(2009:2024)

# Loop over the function and fetch all records for all years
for (year in years_list) {
  fetch_pubmed_records(year, query_terms)
}
