
# packages, directory -------------------------------------------------------
# libraries
library(tidyverse) # tools for data manipulation
library(here) # easily manage directories
library(rentrez) # direct access to NCBI/ PubMed database
library(aws.s3) 
library(XML) 

# set working parameters --------------------------------------------------------

# directory setting
here::i_am("code/1_querying_api.R")

# communicating key to api
api_key <- "4e7696f07a04e00b907d0f55a80aaa100808"
set_entrez_key(api_key)

# AWS S3 configuration ---------------------------------------------------------
# Replace with your S3 bucket details
s3_bucket <- "peitestbucket"
s3_folder <- "1_pubmed_xml_responses/"


# define query terms -------------------------------------------------------


# define medical terms of interest
# only terms, no date ranges! date range comes later
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

format_year_for_query <- function(year){
  paste0('(" ',
         year,
         '/01/01"[Date - Publication] : " ',
         year,
         '/12/30"[Date - Publication])')
}



# FUNCTION: Find number of query hits and download them to xml-------------------
fetch_pubmed_records <- function(year, query_terms) {
  print(year)
  
  # concatenating date range to slot into query
  query_date_range <- format_year_for_query(year)
  
  # joining our query terms and date range into a regular expression
  query <- paste0(query_terms,
                  'AND',
                  query_date_range)
  
  # outlining our search to the api + posting history to access later
  query_search <- entrez_search(db = "pubmed", 
                                term = query, 
                                use_history = TRUE) # this history term is key
  
  
  print(query_search)  # checking the number of records that match the query


  # fetching the actual records
  records <- entrez_fetch(
    db = "pubmed",
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








# USAGE  ------------------------------------------------------------------------

# set the years you want to receive records for
years_list <- c("2009",
                "2010", 
                "2011",
                "2012",
                "2013",
                "2014",
                "2015",
                "2016",
                "2017",
                "2018",
                "2019",
                "2020",
                "2021",
                "2022",
                "2023",
                "2024")



# loop over the function and fetch all records all years
for (period in years_list) {
  fetch_pubmed_records(period, query_terms)
  
}
  # Clean up
unlink(temp_file)  # Deletes the temporary file


