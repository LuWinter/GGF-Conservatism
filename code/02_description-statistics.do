
/*********************************************************
* SCRIPT: 02_description-statistics.do
* TASK: This script generates the table of the description statistics
*********************************************************/

// PREPROCESS ----------------------------------------------------------------
// Use Log File
global file_name "02_description-statistics"
do "code/_stata-log.do"

// Read main-data
use "processed/intermediate/main_data.dta", clear

// Winsorize Sample
#delimit ;
winsor2 EPS_P Size Lev GDP_p Age MHRatio CG INS SuperINS RegionFin OverInvest StrategyScore, 
    cuts(1 99) by(Year) replace;
#delimit cr


// Description Statistics ----------------------------------------------------
// Filepath for tables
global table_path "results/tables"

// Variables Summary
#delimit ;
logout, save("$table_path/01_varis-summary.doc") word replace:
    tabstat EPS_P DR Ret GGF 
    Size Lev MHRatio Age GDP_p 
    CG INS SuperINS RegionFin OverInvest StrategyScore,
    s(N mean sd min p25 p50 p75 max) c(s)
    ;
#delimit cr

// Variables Correlation
gen DR_Ret = DR * Ret
gen GGF_DR_Ret = GGF * DR * Ret

#delimit ;
logout, save ("$table_path/02_varis-correlation") excel replace:
    pwcorr EPS_P GGF_DR_Ret Size Lev MHRatio Age GDP_p
    CG INS SuperINS RegionFin OverInvest StrategyScore,
    star(.1)
    ;
#delimit cr


*** EOF
