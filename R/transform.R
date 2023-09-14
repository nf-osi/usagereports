#' Transform to deidentified data
#'
#' This processes the data warehouse outputs so that data is deidentified and can be stored
#' in a private Synapse project. All downstream wrangling/plotting rely on this intermediate.
#' Storing this data is important because of the limits on availability (i.e. data only available for six months prior),
#' so make sure to store data if there's any chance of later additional analysis or comparison later.
#'
#' For the recoding itself, DCC Sage users use negative integers and have to be hard-coded before using this function;
#' this allows easy filtering of DCC users later on with simple `userId > 0` clause.
#'
#' @param data_dir Output files from data warehouse query that contains real synapse user ids.
#' @param code_file A csv mapping the random ids (`code` column) to real synapse user ids (`userId` column).
#' This is expected to be encrypted.
#' @param key_rds Key file for decrypting `code_file`.
#' @import data.table
#' @export
to_deidentified_export <- function(data_dir,
                                   code_file = "codes.csv",
                                   key_rds = "usage_report_key.rds") {

  # Read in files
  files <- list.files(data_dir, recursive = TRUE, full.names = TRUE)
  data <- lapply(files, function(x) fread(x, colClasses = c("integer", "integer", "character", "integer64", "character", "character", "character", "character", "character", "character")))
  names(data) <- tools::file_path_sans_ext(basename(files))
  no_data <- sapply(data, nrow)
  message(sum(no_data == 0), " files had no download records")
  message("Creating a single data.table...")
  data <- rbindlist(data, idcol = "project")

  lookup <- read_code_file(code_file, key_rds)

  # Identify new vs. seen users in current data
  seen_users <- lookup$userId
  seen_users_codes <- lookup$code

  all_users <- unique(data$userId)
  new_users <- setdiff(all_users, seen_users)
  message("Found ", length(new_users), " new users in this dataset")
  if(length(new_users)) {
    new_users_codes <- generate_code(new_users, exclude = seen_users_codes)
    new_rows <- data.frame(userId = new_users, code = new_users_codes)
    lookup <- rbind(lookup, new_rows)
    encrypt_code_file(lookup, code_file = code_file, key_rds = key_rds)
    message("New codes saved to encrypted file ", code_file)
  }

  # Update data
  data$userId <- lookup$code[match(data$userId, lookup$userId)]
  message("Replaced userIds with codes")
  return(data)
}


#' Internal helper to return a vector of random codes of size needed
#'
#' @param x Vector of ids that need coding.
#' @param exclude Vector of codes already in use.
generate_code <- function(x, exclude) {
  size <- length(x) + length(exclude)
  drawable <- 2 * size
  drawable <- setdiff(drawable, exclude)
  new_codes <- sample(drawable, size = length(x),  replace = F)
  return(new_codes)
}


#' Encrypt and save code file
#'
#' See also inverse helper `read_code_file`.
#' 
#' @param code_df A `data.frame` with cols `userId` and `code` to encrypt.
#' @param code_file Name of file to encrypt to, should have `csv` extension.
#' @param key_rds Encryption key.
#' 
#' @export
encrypt_code_file <- function(code_df,
                              code_file = "codes.csv",
                              key_rds = "usage_report_key.rds") {

  key <- readRDS(key_rds)
  cyphr_key <- cyphr::key_sodium(key)
  cyphr::encrypt(
    utils::write.csv(code_df, file = code_file, row.names = F),
    key = cyphr_key)
}


#' Decrypt and read code file
#' 
#' See also inverse helper `encrypt_code_file`.
#' 
#' @param code_file Name of file to read from, should have `csv` extension.
#' @param key_rds Encryption key.
#' @export
read_code_file <- function(code_file = "codes.csv",
                           key_rds = "usage_report_key.rds") {
  key <- readRDS(key_rds)
  cyphr_key <- cyphr::key_sodium(key)
  codes <- cyphr::decrypt(utils::read.csv(code_file), key = cyphr_key)
  codes
}
