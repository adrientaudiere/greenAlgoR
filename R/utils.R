#' Load csv files from green algo github repositories
#'
#' @description
#'
#' <a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
#' <img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
#'
#' Mainly for internal use
#'
#' @param url url to a raw csv file
#' @param remove_first_line (logical, default TRUE): Do we remove the first line
#'   from the csv file.
#'
#' @return a data.frame
#' @export
#' @importFrom utils read.csv
#' @author Adrien Taudière
#' @examples
#' carbon_intensity_internal <-
#'   csv_from_url_ga("https://raw.githubusercontent.com/GreenAlgorithms/green-algorithms-tool/refs/heads/master/data/v2.2/CI_aggregated.csv")
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


#' Compute session run time and mass storage use (based on `gc()`)
#'
#' @description
#'
#' <a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
#' <img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
#'
#' Compute cpu times using `base::proc.time()` and mass storage using
#' `base::gc()`
#'
#' @param compute_mass_storage (logical, default TRUE) Do the mass storage is
#'   computed from `base::gc()` function
#' @return A list of values
#' @export
#'
#' @author Adrien Taudière
#' @examples
#' session_runtime()
#' session_runtime(compute_mass_storage = FALSE)
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



#' Round numeric vector conditionaly
#'
#' @param vec a numeric vector
#' @param cond : a matrix of 2 row an n column with the first row defining the
#'   condition and the second row defining the number to round. cond is order
#'   in decreasing order of the 1 row internally. Thus the order in cond rows
#'   is not important
#' @return a numeric vector of the same length as vec
#' @export
#' @author Adrien Taudière
#' @examples
#' round_conditionaly(vec = c(1000.27890, 10.87988, 1.769869, 0.99796, 0.000179))
#' round_conditionaly(
#'   vec = c(1000.27890, 0.000179, 10e-11),
#'   cond = cbind(c(10e-5, 5), c(10, 2))
#' )
round_conditionaly <- function(vec, cond = cbind(c(1.e-5, 5), c(0.001, 3), c(0.01, 3), c(1, 2), c(10, 1), c(100, 0))) {
  cond <- cond[, order(cond[1, ], decreasing = TRUE)]

  res <- vec

  for (j in 1:ncol(cond)) {
    cond_local <- vec > cond[1, j]
    res[cond_local] <- round(vec[cond_local], cond[2, j])
  }

  return(res)
}
