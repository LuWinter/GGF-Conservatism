
#########################################################
# OVERVIEW
#   This script generates the folder structure and run the specified code for the paper:
#     "Reverse Mixed Reform and Accounting Conservatism: Evidence from Government Guidance Funds(GGF)" 
#
# PROJECT STRUCTURE
#     |--Clout-Chasing.Rproj 
#     |--code               # store code files
#     |--data               # store raw data
#     |--doc                # store relevant documents
#     |--log                # store log files
#     |--processed          # store processed data
#     |   |--intermediate   # store processed temp data
#     |--results            
#     |   |--figures        # store result figures
#     |   |--tables         # store result tables
#     |--run.R              # project runner
#
# SOFTWARE REQUIREMENTS
#   Analyses run on MacOS using Stata version 17 and R-4.2.0
#     with tidyverse package installed
#
# TO PERFORM A CLEAN RUN, DELETE THE FOLLOWING TWO FOLDERS:
#   /processed/intermediate
#   /results
#########################################################


## Use pacman rather than baser to manage packages
if (system.file(package='pacman') == "") {
  install.packages("pacman")
}

## Load necessary packages (auto install if not exist)
pacman::p_load(tidyverse)
pacman::p_load(here)
pacman::p_load(RStata)
pacman::p_load(rio)
pacman::p_load(fs)

## Load user defined functions
source("code/_utils.R")

## Project root
i_am(path = "run.R")

## Stata options
options("RStata.StataPath" = "/Applications/Stata/StataSE.app/Contents/MacOS/stata-se")
options("RStata.StataVersion" = 17)


# 1. Clean Previous Output (if exist) -------------------------------------
if (dir_exists(here("processed", "intermediate"))) {
  dir_delete(here("processed", "intermediate"))
}
if (dir_exists(here("results"))) {
  dir_delete(here("results"))
}


# 2. Create Output Directories --------------------------------------------
dir_create(here("processed", "intermediate"))
dir_create(here("results"))
dir_create(here("results", "figures"))
dir_create(here("results", "tables"))


# 3. Generate Main Data ---------------------------------------------------
full_data <- readRDS(here("processed", "final-sample-reduced_20221211.rds"))
main_data <- filter(full_data, Year >= 2016, SOE == 0)
saveRDS(object = main_data, file = here("processed", "intermediate", "main_data.rds"))
rio::export(x = main_data, file = here("processed", "intermediate", "main_data.dta"))


# 4. Run Analysis ---------------------------------------------------------
# source(here("code", "01_GGF-statistics.R"), local = new.env())
# stata(here("code", "02_description-statistics.do"))
# stata(here("code", "03_basic-analysis.do"))
# stata(here("code", "04_mechanism-analysis.do"))
# stata(here("code", "05_further-analysis.do"))
run_script(path = "code/01_GGF-statistics.R")
run_script(path = "code/02_description-statistics.do")
run_script(path = "code/03_basic-analysis.do")
run_script(path = "code/04_mechanism-analysis.do")
run_script(path = "code/05_further-analysis.do")


### EOF
