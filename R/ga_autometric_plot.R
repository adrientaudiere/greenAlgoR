#' Plot resource-usage logs recorded by the `autometric` package
#'
#' @description
#'
#' <a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
#' <img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
#'
#' Render a \code{\link[ggplot2]{ggplot}} of the CPU and memory usage recorded
#' by \code{autometric::log_start()} / \code{autometric::log_stop()}. Each
#' selected metric is drawn as a line over time, faceted so that percentage
#' metrics (CPU) and megabyte metrics (memory) keep their own y-axis scale.
#' This turns an \code{autometric} log into a publication-ready resource-usage
#' figure and pairs naturally with the carbon-footprint estimates of
#' \code{\link{ga_footprint}()}.
#'
#' @param log Either a path to an \code{autometric} log file (read with
#'   \code{autometric::log_read()}) or a data frame already returned by
#'   \code{autometric::log_read()} (with at least the columns `time`, `cpu`,
#'   `core`, `resident`, `virtual`).
#' @param metrics (character, default `c("cpu", "resident")`) Which columns to
#'   plot. Any subset of "cpu" (\% of a core), "core" (\% of all cores),
#'   "resident" (resident memory, MB) and "virtual" (virtual memory, MB).
#' @param color_by (character, default "phase") Column used to color the lines,
#'   typically "phase", "name" or "pid" so several logged phases or processes
#'   can be compared on one plot.
#' @param ... Additional arguments passed on to
#'   \code{autometric::log_read()} when `log` is a file path.
#'
#' @return A \code{\link[ggplot2]{ggplot}} object with one facet per metric.
#' @export
#' @author Adrien Taudière
#' @seealso \code{\link{ga_targets_network}()}, \code{\link{ga_footprint}()}
#' @examples
#' if (requireNamespace("autometric", quietly = TRUE)) {
#'   log_file <- tempfile()
#'   autometric::log_start(path = log_file, seconds = 0.05)
#'   x <- numeric(0)
#'   for (i in 1:5) {
#'     x <- c(x, rnorm(2e5))
#'     Sys.sleep(0.1)
#'   }
#'   autometric::log_stop()
#'   ga_autometric_plot(log_file)
#' }

ga_autometric_plot <- function(
  log,
  metrics = c("cpu", "resident"),
  color_by = "phase",
  ...
) {
  if (!requireNamespace("autometric", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package {.pkg autometric} is required for {.fn ga_autometric_plot}.",
      "i" = "Install it with {.code install.packages(\"autometric\")}."
    ))
  }

  metrics <- match.arg(
    metrics,
    c("cpu", "core", "resident", "virtual"),
    several.ok = TRUE
  )

  d <- if (is.character(log)) {
    autometric::log_read(log, ...)
  } else {
    as.data.frame(log)
  }

  needed <- c("time", metrics, color_by)
  missing_cols <- setdiff(needed, colnames(d))
  if (length(missing_cols) > 0) {
    cli::cli_abort(c(
      "The autometric log is missing required column{?s} {.val {missing_cols}}.",
      "i" = "Available columns: {.val {colnames(d)}}."
    ))
  }

  if (nrow(d) == 0) {
    cli::cli_abort(
      "The autometric log is empty; nothing to plot."
    )
  }

  metric_labels <- c(
    cpu = "CPU (% of one core)",
    core = "CPU (% of all cores)",
    resident = "Resident memory (MB)",
    virtual = "Virtual memory (MB)"
  )

  long <- do.call(
    rbind,
    lapply(metrics, function(m) {
      data.frame(
        time = d$time,
        series = as.factor(d[[color_by]]),
        metric = factor(metric_labels[[m]], levels = metric_labels[metrics]),
        value = d[[m]],
        stringsAsFactors = FALSE
      )
    })
  )

  ggplot2::ggplot(
    long,
    ggplot2::aes(x = .data$time, y = .data$value, colour = .data$series)
  ) +
    ggplot2::geom_line(linewidth = 0.7) +
    ggplot2::facet_wrap(~metric, scales = "free_y", ncol = 1) +
    ggplot2::labs(
      x = "Time (seconds since logging start)",
      y = NULL,
      colour = color_by
    ) +
    ggplot2::theme_bw()
}
