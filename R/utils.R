#' Load CSV files from Green Algorithms GitHub repositories
#'
#' @description
#'
#' <a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
#' <img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
#'
#' Helper function to download and parse CSV data from the Green Algorithms
#' project repositories. This function handles the specific format used by
#' Green Algorithms data files, which often have headers in specific rows.
#'
#' @param url Character string with URL to a raw CSV file from Green Algorithms repository
#' @param remove_first_line Logical (default TRUE). Whether to remove the first line
#'   from the CSV file (often contains metadata rather than column headers).
#'
#' @return A data.frame with properly formatted column names and data
#' @export
#' @importFrom utils read.csv
#' @author Adrien Taudière
#' @examples
#' \dontrun{
#' # Download carbon intensity data
#' carbon_intensity <- csv_from_url_ga(
#'   paste0(
#'     "https://raw.githubusercontent.com/GreenAlgorithms/GA-data",
#'     "/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/CI_aggregated.csv"
#'   )
#' )
#' head(carbon_intensity)
#' }
csv_from_url_ga <- function(url, remove_first_line = TRUE) {
  url <- RCurl::getURL(url)
  df <- read.csv(text = url, header = FALSE)
  if (remove_first_line) {
    df <- df[-1, ]
  }
  res <- as.data.frame(df[-1, ])
  colnames(res) <- as.character(df[1, ])
  return(res)
}


#' Compute session runtime and memory usage statistics
#'
#' @description
#'
#' <a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
#' <img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
#'
#' Analyzes the current R session to extract timing and memory usage information.
#' This function is particularly useful for understanding resource consumption
#' patterns and can be used with \code{ga_footprint(runtime_h = "session")}.
#'
#' The function uses \code{base::proc.time()} to get CPU timing information
#' and \code{base::gc()} to estimate memory usage when requested.
#'
#' @param compute_mass_storage Logical (default TRUE). Whether to compute
#'   memory usage statistics using the \code{base::gc()} function. Set to
#'   FALSE if you only need timing information.
#'
#' @return A list containing:
#'   \itemize{
#'     \item \code{cpu_times_users}: User CPU time in seconds
#'     \item \code{cpu_times_system}: System CPU time in seconds
#'     \item \code{time_elapsed}: Total elapsed time in seconds
#'     \item \code{cpu_times}: Combined user and system CPU time
#'     \item \code{mass_storage_used}: Memory currently used (if requested)
#'     \item \code{mass_storage_max}: Maximum memory used (if requested)
#'   }
#' @export
#'
#' @author Adrien Taudière
#' @examples
#' # Get complete session information
#' session_info <- session_runtime()
#' print(session_info)
#'
#' # Get only timing information (faster)
#' timing_only <- session_runtime(compute_mass_storage = FALSE)
#' cat("Session has been running for", timing_only$time_elapsed, "seconds\n")
session_runtime <- function(compute_mass_storage = TRUE) {
  cpu_times_all <- proc.time()
  cpu_times_users <- cpu_times_all[1] + cpu_times_all[2]
  cpu_times_system <- cpu_times_all[4] + cpu_times_all[5]
  time_elapsed <- cpu_times_all[3]
  cpu_times_users_system <- cpu_times_users + cpu_times_system
  res <- list(
    "cpu_times_users" = cpu_times_users,
    "cpu_times_system" = cpu_times_system,
    "time_elapsed" = time_elapsed,
    "cpu_times" = cpu_times_users_system
  )
  if (compute_mass_storage) {
    mass_storage_used <- sum(gc()[1:2, 2])
    mass_storage_max <- sum(gc()[1:2, 6])

    res[["mass_storage_used"]] <- mass_storage_used
    res[["mass_storage_max"]] <- mass_storage_max
  }

  return(res)
}



#' Conditionally round numeric values based on magnitude
#'
#' @description
#' Applies different rounding rules based on the magnitude of values.
#' Larger values are rounded to fewer decimal places, while smaller values
#' retain more precision. This is useful for presenting results with
#' appropriate precision across different scales.
#'
#' @param vec A numeric vector to be rounded
#' @param cond A matrix with 2 rows and n columns where:
#'   \itemize{
#'     \item First row: threshold values for applying rounding rules
#'     \item Second row: number of decimal places to round to
#'   }
#'   The function automatically sorts conditions in decreasing order of thresholds.
#'   Default provides reasonable rounding for most carbon footprint values.
#'
#' @return A numeric vector of the same length as \code{vec} with values rounded
#'   according to the conditional rules
#' @export
#' @author Adrien Taudière
#' @examples
#' # Default rounding behavior
#' values <- c(1000.27890, 10.87988, 1.769869, 0.99796, 0.000179)
#' round_conditionaly(values)
#'
#' # Custom rounding rules
#' custom_rules <- cbind(c(10e-5, 5), c(10, 2)) # 5 decimals for tiny values, 2 for others
#' round_conditionaly(c(1000.27890, 0.000179, 10e-11), cond = custom_rules)
#'
#' # Useful for carbon footprint reporting
#' footprint_values <- c(0.001234, 1.23456, 123.456, 12345.6)
#' round_conditionaly(footprint_values)
round_conditionaly <- function(
    vec,
    cond = cbind(c(1.e-5, 5), c(0.001, 3), c(0.01, 3), c(1, 2), c(10, 1), c(100, 0))) {
  cond <- cond[, order(cond[1, ], decreasing = TRUE)]

  res <- vec

  for (j in 1:ncol(cond)) {
    cond_local <- vec > cond[1, j]
    res[cond_local] <- round(vec[cond_local], cond[2, j])
  }

  return(res)
}
