# packages, directory -------------------------------------------------------
# libraries
library(here) # easily manage directories
library(rentrez) # direct access to NCBI/ PubMed database
library(aws.s3) # for S3 operations
library(XML) # parsing XML

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
query_terms <- '("health emergency"[Title/Abstract])' ###

# FUNCTION: Concatenate date range with flexibility for iteration ---------------
format_year_for_query <- function(year) {
  paste0('(" ', year, '/01/01"[Date - Publication] : " ', year, '/01/01"[Date - Publication])') ###
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
                          retmax = 20, ###
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
years_list <- as.character(2021) ###

# Loop over the function and fetch all records for all years
for (year in years_list) {
  fetch_pubmed_records(year, query_terms)
}
