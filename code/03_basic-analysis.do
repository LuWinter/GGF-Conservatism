
/*********************************************************
* SCRIPT: 03_basic-analysis.do
* TASK: This script generates the table of the basic analysis
*********************************************************/

// PREPROCESS ----------------------------------------------------------------
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


// Basic Analysis ------------------------------------------------------------
// Simple OLS Regression
#delimit ;
eststo simple_ols:
	quietly reg EPS_P $base_reg $GGF_reg
	;
#delimit cr
quietly estadd local fe_industry "NO", replace
quietly estadd local fe_year "NO", replace
quietly estadd local fe_province "NO", replace
quietly estadd local fe_indu_year "NO", replace
quietly estadd local fe_prov_year "NO", replace

// Regression with Common FE
#delimit ;
eststo simple_fe:
	quietly reghdfe EPS_P $base_reg $GGF_reg, 
	absorb($common_fe)
	;
#delimit cr
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "NO", replace
quietly estadd local fe_prov_year "NO", replace

// Regression with Control Varis
#delimit ;
eststo control_ols:
    quietly reg EPS_P $base_reg $GGF_reg 
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg
	;
#delimit cr
quietly estadd local fe_industry "NO", replace
quietly estadd local fe_year "NO", replace
quietly estadd local fe_province "NO", replace
quietly estadd local fe_indu_year "NO", replace
quietly estadd local fe_prov_year "NO", replace
    
// Regression with High FE
#delimit ;
eststo simple_high_fe:
	quietly reghdfe EPS_P $base_reg $GGF_reg, 
	absorb($common_fe $high_fe)
    ;
#delimit cr
quietly estadd local fe_industry "YES", replace
quietly estadd local fe_year "YES", replace
quietly estadd local fe_province "YES", replace
quietly estadd local fe_indu_year "YES", replace
quietly estadd local fe_prov_year "YES", replace

// Regression with Control Varis & High FE
#delimit ;
eststo control_high_fe:
	quietly reghdfe EPS_P $base_reg $GGF_reg
	$Size_reg $Lev_reg $MHRatio_reg $Age_reg $GDP_reg, 
	absorb($common_fe $high_fe)
	;
#delimit cr
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
global var_list2 "_cons DR Ret 1.DR#c.Ret Risk 1.DR#c.Risk c.Risk#c.Ret 1.DR#c.Risk#c.Ret"

// Save Basic Regression
#delimit ;                               
esttab simple_ols simple_fe simple_high_fe control_ols control_high_fe           
    using "$table_path/03_basic-regression.rtf", 
	replace baselevel label nogap star(* 0.10 ** 0.05 *** 0.01) 
    varwidth(15) b t(4) ar2(4) 
	s(fe_industry fe_year fe_province fe_indu_year fe_prov_year N r2_a, 
	  label("Industry FE" "Year FE" "Province FE" 
			"Industry ✖ Year FE" "Province ✖ Year FE" "Obs" "adjusted-R2"))	
    mtitle("Simple OLS" "Simple FE" "Simple High FE" "Control OLS" "Control High FE");
#delimit cr


*** EOF
