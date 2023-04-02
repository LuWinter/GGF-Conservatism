
#########################################################
# SCRIPT: _utils.R
# TASK: This script provides some useful functions
#########################################################


#' Run R or Stata Scripts
#' 
#' @param path character vector of length 1. File path of the script to run
#' @param stata.echo logical value. If TRUE stata text output will be printed
run_script <- function(path, stata.echo = FALSE) {
  ## Check file format
  ext <- tools::file_ext(path)
  if (!(ext %in% c("do", "R"))) {
    stop("Unknown file format\nNot R or Stata scripts")
  }
  
  ## Check daily log file path
  log_path <- paste0("log/", Sys.Date(), "/")
  if (!dir.exists(log_path)) {
    dir.create(log_path)
  }
  
  ## Run scripts
  if (ext == "R") {
    log_name <- paste0(
      log_path,
      tools::file_path_sans_ext(basename(path)),
      "_`date +%Y.%m.%d-%H.%M.%S`.log"
    )
    cmd <- paste("BATCH", path, log_name)
    tools::Rcmd(cmd)
  }
  
  if (ext == "do") {
    RStata::stata(src = path, stata.echo = stata.echo)
  }
}
