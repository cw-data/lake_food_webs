rm(list=ls())
graphics.off()
set.seed(1)
library(dplyr)
library(writexl)
library(readxl)
source("data/lake_baselines.R")
source("data/data_cleaner.R")
source("data/secchi.R")

# readme
# this script is a data pipeline that prepares all of the field and lab data collected for the 2017-2020 "food web study" into one analysis-ready data product
# the script reads in two modules which contain functions for this data pipeline
    # 1. "data/data_cleaner.R" holds functions that clean, parse, and flatten data sources
    # 2. "data/lake_baselines.R" holds a function that calculates lake-specific isotope baselines, baseline-corrects raw d13c and d15n, and adds those values to the flat dataset
# the script reads source data
    # 1. a_data. All of the data sample data, excluding isotope data, regardless of whether those samples became isotope samples.
    # 2. i_data. The subset of samples in `a_data.` that was sent to the lab for stable isotope analysis.
    # 3. p_data. The subset of `i_data` that was analyzed for the 2021 paper; same as `i_data` but excludes Lower Quartz lake and Grace lake. 
# then it parses, cleans, and standardizes data sources
# then it joins source data into a flattened dataframe
# then it calculates lake-specific isotopic baselines
# then it calculates baseline-corrected d13c and d15n for each sample
# next, the script reads in a spreadsheet of secchi readings
# finally, it combines the wrangled sources into a two-sheet xlsx

# sources
a_data <- read.csv("data/source/a_data.csv", header = TRUE)
i_data <- read.csv("data/source/i_data.csv", header = TRUE)
p_data <- read.csv("data/source/p_data.csv", header = TRUE)

# clean
clean_a_data <- a_data_cleaner(a_data)
clean_i_data <- i_data_cleaner(i_data)
clean_p_data <- p_data_cleaner(p_data)
f_data <- flatten(clean_a_data, clean_i_data, clean_p_data)

# calculate isotope baselines and baseline-correct isotope values
f_data <- generate_baselines(f_data)

# read in secchi data
secchi <- secchi()

# write output file
sheets <- list("food_web_data" = f_data, "secchi" = secchi)
writexl::write_xlsx(sheets, "data/food_web_2020.xlsx")
