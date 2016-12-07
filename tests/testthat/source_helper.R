

source_kitchen_schema <- function(file) {


  file_path <- file.path("kitchen_schema", paste("tks_", file, ".R", sep = ""))

  env <- new.env()
  sys.source(file_path, envir = env)
  obj <- get(paste("tks_", file, sep = ""), envir = env)
  
  obj
}
