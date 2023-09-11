#' Write a default config yaml
#' 
#' Create a `config.yml` to store datawarehouse connection parameters if you don't already one.
#' 
dw_config <- function(host = "",
                      port = 3306,
                      username = "",
                      password = "") {
  writeLines(
    c(glue::glue("host: {host}"),
      glue::glue("port: {port}"),
      "db: warehouse", # this is always warehouse
      glue::glue("username: {username}"),
      glue::glue("password: {password}")),
    con = "config.yml")
  message("Saved `config.yml`. If you are in a git repo, please add it to .gitignore.")
}
