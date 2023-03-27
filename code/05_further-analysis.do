
/*********************************************************
* SCRIPT: 05_further-analysis.do
* TASK: This script generates the table of the further regression
* CONTENT: 1. Financial Environment Analysis
           2. Government Level Analysis
           3. Big5 Shareholder Analysis
           4. Same Province Analysis
*********************************************************/

// PREPROCESS ----------------------------------------------------------------
// Read main data
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


// Financial Envirnement Analysis --------------------------------------------
// Group-High Common Regression
#delimit ;
eststo fe_high_common:
	quietly reghdfe EPS_P $base_reg $GGF_reg   	
    if RegionFin == 1, 					
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
eststo fe_high_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg 	
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg  
    if RegionFin == 1, 					
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
eststo fe_low_common:	
	quietly reghdfe EPS_P $base_reg $GGF_reg   	
    if RegionFin == 0, 					
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
eststo fe_low_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg 	
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg  
    if RegionFin == 0, 					
	absorb($common_fe $high_fe)   		
    ;
#delimit cr
quietly estadd local control "YES", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "YES", replace
quietly estadd local fe_prov_year "YES", replace


// Government Level Analysis -------------------------------------------------
// Group-Yes Common Regression
#delimit ;
eststo gl_yes_common:
	quietly reghdfe EPS_P $base_reg $GGF_reg  
    if GGFLevel == "国家级" | GGF == 0, 
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
eststo gl_yes_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg 
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg
    if GGFLevel == "国家级" | GGF == 0, 
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
eststo gl_no_common:
	quietly reghdfe EPS_P $base_reg $GGF_reg   
    if GGFLevel != "国家级" | GGF == 0, 
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
eststo gl_no_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg 
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg
    if GGFLevel != "国家级" | GGF == 0, 
	absorb($common_fe $high_fe)   
    ;
#delimit cr
quietly estadd local control "YES", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "YES", replace
quietly estadd local fe_prov_year "YES", replace


// Big5 Shareholder Analysis -------------------------------------------------
// Group-Yes Robust Regression
#delimit ;
eststo big5_yes_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg 
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg
    if (HoldRank <= 5 | HoldRank == .),   
    absorb($common_fe $high_fe)   
    ;
#delimit cr
quietly estadd local control "YES", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "YES", replace
quietly estadd local fe_prov_year "YES", replace

// Group-No Robust Regression
#delimit ;
eststo big5_no_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg 
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg
    if (HoldRank > 5 | HoldRank == .),        
    absorb($common_fe $high_fe)  
    ;
#delimit cr
quietly estadd local control "YES", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "YES", replace
quietly estadd local fe_prov_year "YES", replace


// Same Province Analysis ----------------------------------------------------
// Generate Groups
gen same_province = strmatch(GGFProvince, Province_str)

// Group-Yes Robust Regression
#delimit ;
eststo sp_yes_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg 
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg
    if (same_province == 1 | GGF == 0),        
    absorb($common_fe $high_fe)   
    ;
#delimit cr
quietly estadd local control "YES", replace
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "YES", replace
quietly estadd local fe_prov_year "YES", replace

// Group-No Robust Regression
#delimit ;
eststo sp_no_robust:
	quietly reghdfe EPS_P $base_reg $GGF_reg 
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg
    if same_province != 1,     
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

// Save Financial Environment Regression
#delimit ;         
esttab fe_high_common fe_high_robust fe_low_common fe_low_robust	
    using "$table_path/07_financial-environment-regression.rtf",      
    replace label nogap star(* 0.10 ** 0.05 *** 0.01) 
	keep($var_list) varwidth(15) b t(4) ar2(4) 
	s(control fe_industry fe_year fe_province fe_indu_year fe_prov_year N r2_a, 
	  label("Control Variables" "Industry FE" "Year FE" "Province FE" 
			"Industry ✖ Year FE" "Province ✖ Year FE" "Obs" "adjusted-R2"))			
    mtitle("Group-High" "Group-High Robust" "Group-Low" "Group-Low Robust");
#delimit cr

// Save Government Level Regression
#delimit ;           
esttab gl_no_common gl_no_robust gl_yes_common gl_yes_robust               
    using "$table_path/08_government-level-regression.rtf", 
	replace label nogap star(* 0.10 ** 0.05 *** 0.01) 
    keep($var_list) varwidth(15) b t(4) ar2(4) 
	s(control fe_industry fe_year fe_province fe_indu_year fe_prov_year N r2_a, 
	  label("Control Variables" "Industry FE" "Year FE" "Province FE" 
			"Industry ✖ Year FE" "Province ✖ Year FE" "Obs" "adjusted-R2"))	
    mtitle("Group-NO" "Group-No Robust" "Group-Yes" "Group-Yes Robust");
#delimit cr

// Save Big5 Shareholder Regression
#delimit ;
esttab big5_yes_robust big5_no_robust       
    using "$table_path/09_big5-shareholder-regression.rtf", 
	replace label nogap star(* 0.10 ** 0.05 *** 0.01) 
    keep($var_list) varwidth(15) b t(4) ar2(4) 
	s(control fe_industry fe_year fe_province fe_indu_year fe_prov_year N r2_a, 
	  label("Control Variables" "Industry FE" "Year FE" "Province FE" 
			"Industry ✖ Year FE" "Province ✖ Year FE" "Obs" "adjusted-R2"))	
    mtitle("Group-Yes Robust" "Group-No Robust");
#delimit cr

// Save Same Province Regression
#delimit ;
esttab sp_yes_robust sp_no_robust       
    using "$table_path/10_same-province-regression.rtf", 
	replace label nogap star(* 0.10 ** 0.05 *** 0.01) 
    keep($var_list) varwidth(15) b t(4) ar2(4) 
	s(control fe_industry fe_year fe_province fe_indu_year fe_prov_year N r2_a, 
	  label("Control Variables" "Industry FE" "Year FE" "Province FE" 
			"Industry ✖ Year FE" "Province ✖ Year FE" "Obs" "adjusted-R2"))	
    mtitle("Group-Yes Robust" "Group-No Robust");
#delimit cr


*** EOF
