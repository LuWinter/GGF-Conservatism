
/*********************************************************
* SCRIPT: 04_mechanism-analysis.do
* TASK: This script generates the table of the mechanism regression
* CONTENT: 1. Director Dispatch Analysis
           2. Over Investment Analysis
           3. Corporate Strategy Analysis
*********************************************************/

// PREPROCESS ----------------------------------------------------------------
// Use Log File
global file_name "04_mechanism-analysis"
do "code/_stata-log.do"

// Read main-data
use "processed/intermediate/main_data.dta", clear

// Generate Variables
destring Stkcd, replace
xtset Stkcd Year

egen Industry2 = group(Industry)
rename Industry Industry_str
rename Industry2 Industry

egen Province2 = group(Province)
rename Province Province_str
rename Province2 Province

// Winsorize Sample
winsor2 Size Lev MHRatio RDRatio GDP_p INS Age SuperINS, cuts(1 99) by(Year) trim replace

// Control Variable Macros
global base_reg "DR Ret DR#c.Ret"
global GGF_reg "GGF GGF#DR GGF#c.Ret GGF#DR#c.Ret"
global Size_reg "Size c.Size#DR c.Size#c.Ret c.Size#DR#c.Ret"
global MB_reg "MB c.MB#DR c.MB#c.Ret c.MB#DR#c.Ret"
global Lev_reg "Lev c.Lev#DR c.Lev#c.Ret c.Lev#DR#c.Ret"
global Big4_reg "Big4 Big4#DR Big4#c.Ret Big4#DR#c.Ret"
global SOE_reg "SOE SOE#DR SOE#c.Ret SOE#DR#c.Ret"
global GDP_reg "GDP_p c.GDP_p#DR c.GDP_p#c.Ret c.GDP_p#DR#c.Ret"
global SuperINS_reg "SuperINS c.SuperINS#DR c.SuperINS#c.Ret c.SuperINS#DR#c.Ret"
global MHRatio_reg "MHRatio c.MHRatio#DR c.MHRatio#c.Ret c.MHRatio#DR#c.Ret"
global Age_reg "Age c.Age#DR c.Age#c.Ret c.Age#DR#c.Ret"

// Fixed Effect Macros
global common_fe "i.Year i.Industry i.Province"
global high_fe "i.Year#i.Industry i.Year#i.Province"


// Director Dispatch Analysis ------------------------------------------------
// Group-Yes Common Regression
#delimit ;
eststo dd_yes_common:
	quietly reghdfe EPS_P $base_reg $GGF_reg 
    if Related > 0 | GGF == 0, 
	absorb($common_fe)   
    ;
#delimit cr
quietly estadd local control "NO", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "NO", replace
quietly estadd local fe_prov_year "NO", replace

// Group-Yes Robust Regression
#delimit ;
eststo dd_yes_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg 
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg
    if Related > 0 | GGF == 0, 
	absorb($common_fe $high_fe)   
    ;
#delimit cr
quietly estadd local control "YES", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "YES", replace
quietly estadd local fe_prov_year "YES", replace

// Group-No Common Regression
#delimit ;
eststo dd_no_common:
	quietly reghdfe EPS_P $base_reg $GGF_reg 
    if Related == 0 | GGF == 0, 
	absorb($common_fe)   
    ;
#delimit cr
quietly estadd local control "NO", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "NO", replace
quietly estadd local fe_prov_year "NO", replace

// Group-No Robust Regression
#delimit ;
eststo dd_no_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg 
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg
    if Related == 0 | GGF == 0, 
	absorb($common_fe $high_fe)   
    ;
#delimit cr
quietly estadd local control "YES", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "YES", replace
quietly estadd local fe_prov_year "YES", replace


// Over Investment Analysis --------------------------------------------------
// Group-Low Common Regression
#delimit ;
eststo oi_low_common:
	quietly reghdfe EPS_P $base_reg $GGF_reg   
    if OverInvest < 0 & OverInvest != ., 				
	absorb($common_fe)		
    ;
#delimit cr
quietly estadd local control "NO", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "NO", replace
quietly estadd local fe_prov_year "NO", replace

// Group-Low Robust Regression
#delimit ;
eststo oi_low_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg 	
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg 
    if OverInvest < 0 & OverInvest != ., 				
	absorb($common_fe $high_fe) 		
    ;
#delimit cr
quietly estadd local control "YES", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "YES", replace
quietly estadd local fe_prov_year "YES", replace

// Group-High Common Regression
#delimit ;
eststo oi_high_common:
	quietly reghdfe EPS_P $base_reg $GGF_reg 
    if OverInvest > 0 & OverInvest != ., 				
	absorb($common_fe)
    ;
#delimit cr
quietly estadd local control "NO", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "NO", replace
quietly estadd local fe_prov_year "NO", replace

// Group-High Robust Regression
#delimit ;
eststo oi_high_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg	
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg 
    if OverInvest > 0 & OverInvest != ., 				
	absorb($common_fe $high_fe)	
    ;
#delimit cr
quietly estadd local control "YES", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "YES", replace
quietly estadd local fe_prov_year "YES", replace


// Corporate Strategy Analysis -----------------------------------------------
// Generate Groups
egen ss_p50 = pctile(StrategyScore), p(66)
gen ss_d = 1 if StrategyScore > 21 & StrategyScore != .
replace ss_d = 0 if StrategyScore <= 21

// Group-High Common Regression
#delimit ;
eststo cs_high_common:                                
	reghdfe EPS_P $base_reg $GGF_reg   	
    if ss_d == 1, 				
	absorb($common_fe)				   	
    ;
#delimit cr
quietly estadd local control "NO", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "NO", replace
quietly estadd local fe_prov_year "NO", replace

// Group-High Robust Regression
#delimit ;
eststo cs_high_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg	
	$Size_reg $SuperINS_reg $MHRatio_reg $Age_reg $GDP_reg  
    if ss_d == 1, 				
	absorb($common_fe $high_fe)			
    ;
#delimit cr
quietly estadd local control "YES", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "YES", replace
quietly estadd local fe_prov_year "YES", replace

// Group-Low Common Regression
#delimit ;
eststo cs_low_common:   
	reghdfe EPS_P $base_reg $GGF_reg 
    if ss_d == 0, 			   	
	absorb($common_fe) 				  
    ;
#delimit cr
quietly estadd local control "NO", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "NO", replace
quietly estadd local fe_prov_year "NO", replace

// Group-Low Robust Regression
#delimit ;
eststo cs_low_robust:                         
	quietly reghdfe EPS_P $base_reg $GGF_reg  	
	$Size_reg $SuperINS_reg $MHRatio_reg $Age_reg $GDP_reg
    if ss_d == 0, 				
	absorb($common_fe $high_fe)			
    ;
#delimit cr
quietly estadd local control "YES", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "YES", replace
quietly estadd local fe_prov_year "YES", replace


// SAVE RESULTS --------------------------------------------------------------
// Filepath for tables
global table_path "results/tables"

// Varis List Macros
global var_list "_cons DR Ret 1.DR#c.Ret GGF 0.GGF#1.DR 1.GGF#c.Ret 1.GGF#1.DR#c.Ret"

// Save Director Dispatch Regression
#delimit ;           
esttab dd_yes_common dd_yes_robust dd_no_common dd_no_robust              
    using "$table_path/04_director-dispatch-regression.rtf", 
	replace label nogap star(* 0.10 ** 0.05 *** 0.01) 
    keep($var_list) varwidth(15) b t(4) ar2(4) 
	s(control fe_industry fe_year fe_province fe_indu_year fe_prov_year N r2_a, 
	  label("Control Variables" "Industry FE" "Year FE" "Province FE" 
			"Industry ✖ Year FE" "Province ✖ Year FE" "Obs" "adjusted-R2"))	
    mtitle("Group-Yes" "Group-Yes Robust" "Group-No" "Group-No Robust");
#delimit cr

// Save Over Investment Regression
#delimit ;
esttab oi_high_common oi_high_robust oi_low_common oi_low_robust
    using "$table_path/05_over-investment-regression.rtf",                    
    replace label nogap star(* 0.10 ** 0.05 *** 0.01) 
	keep($var_list) varwidth(15) b t(4) ar2(4) 
	s(control fe_industry fe_year fe_province fe_indu_year fe_prov_year N r2_a, 
	  label("Control Variables" "Industry FE" "Year FE" "Province FE" 
			"Industry ✖ Year FE" "Province ✖ Year FE" "Obs" "adjusted-R2"))		
    mtitle("Group-High" "Group-High Robust" "Group-Low" "Group-Low Robust");
#delimit cr

// Save Corporate Strategy Regression
#delimit ;         
esttab cs_high_common cs_high_robust cs_low_common cs_low_robust	
    using "$table_path/06_corporarte-strategy-regression.rtf",                                	
    replace label nogap star(* 0.10 ** 0.05 *** 0.01) 
	keep($var_list) varwidth(15) b t(4) ar2(4) 
	s(control fe_industry fe_year fe_province fe_indu_year fe_prov_year N r2_a, 
	  label("Control Variables" "Industry FE" "Year FE" "Province FE" 
			"Industry ✖ Year FE" "Province ✖ Year FE" "Obs" "adjusted-R2"))
    mtitle("Group-High" "Group-High Robust" "Group-Low" "Group-Low Robust");
#delimit cr	


*** EOF
