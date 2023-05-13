
##############################################################
# Programmer: Lu Winter
# Date Created: 2022-08-30
# Task: Merge preprocessed data
##############################################################


# 0. Initial Setup -------------------------------------------------------------

## 加载R包
library(dplyr)
library(RStata)
library(purrr)
library(DBI)
library(lubridate)
library(stringr)

## 预定义输入输出路径
data_path <- "data"
output_path <- "output"
db_path <- "data/GGF_project_store.sqlite"

## 建立数据库连接
con_sqlite <- dbConnect(RSQLite::SQLite(), db_path)
dbListTables(con_sqlite)


# 1. 预处理数据 --------------------------------------------------------------

merged_Big10SH_GGF_nodupl <- readRDS(file.path(output_path, "merged_Big10SH_GGF_nodupl.rds"))
accounting_conservatism <- rio::import(file = file.path(output_path, "accounting-conservatism_2022-12-11.dta"))
control_variables <- readRDS(file = file.path(output_path, "control-variables_2022-10-07.rds"))
identifier <- dbReadTable(con_sqlite, "identifier")

# accounting_conservatism <- accounting_conservatism %>%
#   select(-Ret, -DR) %>%
#   rename(Ret = adjRet, DR = adjDR)

control_variables %>% 
  apply(MARGIN = 2, FUN = \(x) sum(is.na(x)))
control_variables <- control_variables %>% 
  filter(if_all(!matches("StrategyScore|RDRatio"), ~ !is.na(.x)))
### 除了StrategyScore外的缺失样本删去

accounting_conservatism <- accounting_conservatism %>% 
  mutate(
    Year = Year - 1,
    Stkcd = str_pad(Stkcd, 6, "left", "0")
  )
### 所有的解释变量都要滞后一期
### 例如：16年的解释变量匹配17年的会计稳健性

merged_for_reg <- identifier %>% 
  left_join(
    y = accounting_conservatism, 
    by = c("Stkcd", "Year")
  ) %>% 
  select(
    Stkcd, Year, G_Score, C_Score, EPS, 
    YearOpen, YearClose, Ret, DR, Size, MB, Lev
  ) %>% 
  left_join(
    y = merged_Big10SH_GGF_nodupl, 
    by = c("Stkcd", "Year")
  ) %>% 
  mutate(GGF = ifelse(is.na(GGF), 0, 1)) %>% 
  filter(Year >= 2012) %>% 
  left_join(control_variables, by = c("Stkcd", "Year")) %>% 
  mutate(Age = Year - lubridate::year(EstablishDate))

### 检查变量缺失情况
merged_for_reg %>%   
  apply(MARGIN = 2, FUN = \(x) sum(is.na(x)))
merged_for_reg <- merged_for_reg %>% 
  filter(!is.na(CG), !is.na(YearOpen)) 
merged_for_reg %>%   
  apply(MARGIN = 2, FUN = \(x) sum(is.na(x)))

## 变量总计：32
## 标识（2）：Stkcd Year
## 会计稳健性（7）：G_Score C_Score EPS YearOpen YearClose DR Ret
## 引导基金（6）：GovFund GGFLevel GGFProvince HoldNum HoldRatio HoldRank
## 控制变量（14）：Size MB Lev RegionFin SOE Big4 INS SuperINS MHRatio 
## ListingYear GDP_p StrategyScore CG RDRatio 
## 固定效应（3）：IndustryCode Province City
merged_for_reg <- merged_for_reg[, 
  c("Stkcd", "Year", "G_Score", "C_Score", "EPS", 
    "YearOpen", "YearClose", "DR", "Ret","GGF", 
    "GGFLevel", "GGFProvince", "HoldNum", "HoldRatio", 
    "HoldRank", "Size", "MB", "Lev", "RegionFin", 
    "SOE", "Big4", "INS", "SuperINS", "MHRatio", 
    "ListingYear", "GDP_p", "StrategyScore", "CG", "Age", 
    "RDRatio",  "IndustryCode", "Province", "City")
]
### 数据集中也应该包括所有的常见变量，如基础财务数据
### 否则后续的研究将会无穷无尽地陷入到补充数据的麻烦中

# 2. 增补的数据 ----------------------------------------------------------------

### 董监高派遣
GGF_related <- readRDS(
  file = "../Data-for-Accounting-Research/data/gov-guide-fund/GGF_related.rds"
)
GGF_related_processed <- GGF_related %>% 
  mutate(
    Related = Director + JianShi
  ) %>% 
  group_by(Stkcd, Year) %>% 
  summarise(Related = sum(Related)) %>% 
  ungroup()
merged_for_reg <- merged_for_reg %>% 
  left_join(
    x = .,
    y = GGF_related_processed,
    by = c("Stkcd", "Year")
  )

### 风险规避
return_volatility <- readRDS(
  file = "../Data-for-Accounting-Research/data/2022-11-21_return-volatility.rds"
)
return_volatility <- return_volatility %>% 
  select(
    Stkcd,
    Year,
    contains("sd")
  )
merged_for_reg <- merged_for_reg %>% 
  left_join(
    x = .,
    y = return_volatility,
    by = c("Stkcd", "Year") 
  )

### 公司战略得分（重新制作）
corp_strategy <- readRDS(
  file = "../Data-for-Accounting-Research/temp/strategy_score.rds"
)
merged_for_reg <- merged_for_reg %>% 
  select(-StrategyScore) %>% 
  left_join(
    x = .,
    y = corp_strategy[c("Stkcd", "Year", "StrategyScore")],
    by = c("Stkcd", "Year")
  )
merged_for_reg <- merged_for_reg %>% 
  mutate(
    GDP_p = GDP_p / 10000
  )

### 过度投资数据
over_invest <- readRDS(
  file = "../Data-for-Accounting-Research/temp/over_invest.rds"
) %>% 
  ungroup()
merged_for_reg <- merged_for_reg %>% 
  left_join(
    y = select(over_invest, -Industry),
    by = c("Stkcd", "Year")
  )


# 3. 存储 -------------------------------------------------------------------

merged_for_reg_reduced <- merged_for_reg %>% 
  group_by(Stkcd) %>% 
  filter(n() > 2) %>% 
  ungroup()

saveRDS(
  object = merged_for_reg, 
  file = file.path(output_path, paste0("merged-for-reg_", today(), ".rds"))
)
saveRDS(
  object = merged_for_reg_reduced, 
  file = file.path(output_path, paste0("merged-for-reg-reduced_", today(), ".rds"))
)

dbDisconnect(con_sqlite)

