
cap log close

** Check daily log file path
local log_date : di %tcCCYY-NN-DD `=clock("$S_DATE", "DMY")'
local log_path "log/`log_date'/"
capture qui dir "`log_path'"
if _rc {
	mkdir "`log_path'"
}

** Generate full log file path
local log_prefix "`log_path'$file_name"
local log_time : di %tcCCYY.NN.DD!-HH.MM.SS `=clock("$S_DATE $S_TIME", "DMYhms")'
local log_file "`log_prefix'_`log_time'.log"

log using  "`log_file'", text
