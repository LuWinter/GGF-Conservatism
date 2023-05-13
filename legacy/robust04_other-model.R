
##############################################################
# Programmer: Lu Winter
# Date Created: 2022-10-20
# Task: Check other conservatism models
##############################################################


# 0. Initial Setup -------------------------------------------------------------

library(dplyr)
library(RStata)
library(DBI)
library(lubridate)
library(stringr)
library(RStata)
source("code/func_tools.R")

## 预定义输入输出路径
data_path <- "data"
output_path <- "output"
db_path <- "data/GGF_project_store.sqlite"

## 建立数据库连接
con_sqlite <- dbConnect(RSQLite::SQLite(), db_path)
dbListTables(con_sqlite)

# Stata设置
options("RStata.StataPath" = "/Applications/Stata/StataSE.app/Contents/MacOS/stata-se")
options("RStata.StataVersion" = 17)


# 1. Prepare Data ---------------------------------------------------------

identifier <- dbReadTable(
  conn = con_sqlite,
  name = "identifier"
)
merged_for_reg <- readRDS(
  file = file.path(output_path, "merged-for-reg_2022-10-07.rds")
)
merged_for_reg_reduced <- readRDS(
  file = file.path(output_path, "merged-for-reg-reduced_2022-12-11.rds")
)

con_fin <- dbConnect(
  drv = RSQLite::SQLite(), 
  "../Data-for-Accounting-Research/accounting_data.sqlite"
)
dbListTables(con_fin)

financial_sheet_db <- tbl(con_fin, "financial_sheet")
robust_data <- financial_sheet_db %>% 
  select(
    Stkcd, 
    Year,
    TotalProfit,
    TotalAsset,
    NetProfit,
    NetOperatingCF
  ) %>% 
  collect()

robust_data <- identifier %>% 
  left_join(
    y = robust_data,
    by = c("Stkcd", "Year")
  ) %>% 
  lag_n_year(
    n = 1, 
    key = "Stkcd", 
    value = c("TotalProfit", "TotalAsset"), 
    by = "Year"
  ) %>% 
  mutate(
    NI = (TotalProfit - TotalProfit_lag1) / TotalAsset_lag1,
    DNI = ifelse(NI < 0, 1, 0),
    Accrual = (NetProfit - NetOperatingCF) / TotalAsset_lag1,
    CFO = NetOperatingCF / TotalAsset_lag1,
    DCFO = ifelse(CFO < 0, 1, 0)
  ) %>% 
  select(
    Stkcd,
    Year,
    NI,
    Accrual,
    CFO,
    DNI,
    DCFO
  )


# 2. Perform Test ---------------------------------------------------------

merged_for_reg_reduced %>% 
  left_join(
    y = robust_data,
    by = c("Stkcd", "Year")
  ) %>% 
  lag_n_year(
    n = 1, 
    key = "Stkcd", 
    value = c("NI", "DNI"), 
    by = "Year"
  ) %>% 
  mutate(
    HoldRatio = ifelse(is.na(HoldRatio), 0, HoldRatio)
  ) %>% 
  filter(Year >= 2016, SOE == 0) %>% 
  stata(
    src = "code/robust04_other-model.do",
    data.in = .
  )

temp_data <- merged_for_reg_reduced %>%
  filter(Year >= 2016, SOE == 0) %>%
  stata(
    src = '
      gen EPS_P = EPS / YearOpen
      gen IndustryCode2 = cond(substr(IndustryCode, 1, 1) != "C", substr(IndustryCode, 1, 1), substr(IndustryCode, 1, 2))
      egen Industry = group(IndustryCode2)

      egen Province2 = group(Province)
      rename Province Province_str
      rename Province2 Province
      gen same_province = strmatch(GGFProvince, Province_str)

      winsor2 Size Lev MHRatio RDRatio GDP_p INS Age SuperINS, cuts(1 99) by(Year) trim replace
    ',
    data.in = .,
    data.out = TRUE
  )

temp_data %>% 
  mutate(
    HoldRatio = ifelse(is.na(HoldRatio), 0, HoldRatio)
  ) %>% 
  fixest::feols(
    fml = C_Score ~
     HoldRatio + Size + Lev + MHRatio + Age + GDP_p |
      Year + Industry + Province + Year^Industry + Year^Province,
    vcov = "iid",
    panel.id = c("Stkcd", "Year"),
    data = .
  ) %>% summary()


dbDisconnect(con_sqlite)
dbDisconnect(con_fin)
