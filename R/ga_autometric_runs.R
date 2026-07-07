#' Summarize an `autometric` log into one record per process run
#'
#' Internal helper shared by \code{\link{ga_autometric_lastrun}()} and
#' \code{\link{ga_autometric_history}()}. It reads an \code{autometric} log,
#' drops the pipeline bookkeeping phases (`prepare:`, `conclude:`,
#' `__DEFAULT__`) and collapses each `(pid, phase)` group into a single row
#' describing that one execution: its duration, mean CPU usage and start/end
#' time. Because a target rebuilt several times gets a new `pid` on every run,
#' each rerun becomes its own record.
#'
#' @param log Either a path to an \code{autometric} log file or a data frame
#'   returned by \code{autometric::log_read()}.
#' @param units_time,units_memory Passed to \code{autometric::log_read()} when
#'   `log` is a file path.
#' @param ... Additional arguments forwarded to \code{autometric::log_read()}.
#'
#' @return A data frame with columns `pid`, `phase`, `duration`, `cpu`,
#'   `start_time` and `end_time`, one row per `(pid, phase)`.
#' @keywords internal
#' @noRd
ga_autometric_runs <- function(
  log,
  units_time = "hours",
  units_memory = "gigabytes",
  ...
) {
  if (!requireNamespace("autometric", quietly = TRUE)) {
    cli::cli_abort(c(
      "Package {.pkg autometric} is required to read the log.",
      "i" = "Install it with {.code install.packages(\"autometric\")}."
    ))
  }

  d <- if (is.character(log)) {
    autometric::log_read(
      log,
      units_time = units_time,
      units_memory = units_memory,
      ...
    )
  } else {
    as.data.frame(log)
  }

  needed <- c("pid", "phase", "time", "cpu")
  missing_cols <- setdiff(needed, colnames(d))
  if (length(missing_cols) > 0) {
    cli::cli_abort(c(
      "The autometric log is missing required column{?s} {.val {missing_cols}}.",
      "i" = "Available columns: {.val {colnames(d)}}."
    ))
  }

  d |>
    dplyr::filter(
      !grepl("prepare:", .data$phase),
      !grepl("conclude:", .data$phase),
      !grepl("__DEFAULT__", .data$phase)
    ) |>
    dplyr::group_by(.data$pid, .data$phase) |>
    dplyr::summarise(
      duration = max(.data$time) - min(.data$time),
      cpu = mean(.data$cpu),
      start_time = min(.data$time),
      end_time = max(.data$time),
      .groups = "drop"
    )
}

#' Plot the last-run duration of every stored target from an `autometric` log
#'
#' @description
#'
#' <a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
#' <img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
#'
#' Reconstruct the resource impact of the **last** pipeline run from an
#' \code{autometric} log. Each `(pid, phase)` execution is collapsed to its
#' duration and mean CPU usage, the log is restricted to phases that are still
#' present in the \code{targets} store (\code{targets::tar_objects()}), and for
#' each target only the single longest run is kept. The result is one bar per
#' stored target, mapping duration to bar length and mean CPU usage to fill.
#'
#' This is the log-based companion of \code{\link{ga_targets_meta_plot}()}: the
#' former reads the metadata, the latter re-derives the same "last run" picture
#' from the finer-grained resource samples. To visualize *every* run instead of
#' only the last, use \code{\link{ga_autometric_history}()}.
#'
#' @param log Either a path to an \code{autometric} log file (read with
#'   \code{autometric::log_read()}) or a data frame already returned by
#'   \code{autometric::log_read()} (with at least the columns `pid`, `phase`,
#'   `time`, `cpu`).
#' @param store (character, default `targets::tar_config_get("store")`) Path to
#'   the targets data store, used to list the objects still present via
#'   \code{targets::tar_objects()}.
#' @param object_names (optional character) Vector of target names to keep. When
#'   supplied, `store` is not queried. Useful for tests or to focus on a subset.
#' @param units_time,units_memory Passed to \code{autometric::log_read()} when
#'   `log` is a file path (defaults `"hours"` and `"gigabytes"`).
#' @param ... Additional arguments forwarded to \code{autometric::log_read()}.
#'
#' @return A \code{\link[ggplot2]{ggplot}} object with one bar per stored target.
#' @export
#' @author Adrien Taudière
#' @seealso \code{\link{ga_targets_meta_plot}()},
#'   \code{\link{ga_autometric_history}()}, \code{\link{ga_autometric_plot}()}
#' @examples
#' if (requireNamespace("autometric", quietly = TRUE)) {
#'   log_df <- data.frame(
#'     version = "0.1.2",
#'     phase = rep(c("raw", "scaled"), each = 4),
#'     pid = rep(c(1L, 2L), each = 4),
#'     name = "local",
#'     status = 0L,
#'     time = c(0, 0.1, 0.2, 0.3, 0.3, 0.35, 0.4, 0.45),
#'     core = runif(8, 0, 40),
#'     cpu = runif(8, 0, 90),
#'     resident = runif(8, 70, 90),
#'     virtual = runif(8, 900, 1000)
#'   )
#'   ga_autometric_lastrun(log_df, object_names = c("raw", "scaled"))
#' }
ga_autometric_lastrun <- function(
  log,
  store = targets::tar_config_get("store"),
  object_names = NULL,
  units_time = "hours",
  units_memory = "gigabytes",
  ...
) {
  runs <- ga_autometric_runs(
    log,
    units_time = units_time,
    units_memory = units_memory,
    ...
  )

  keep <- if (is.null(object_names)) {
    targets::tar_objects(store = store)
  } else {
    object_names
  }

  last_runs <- runs |>
    dplyr::filter(.data$phase %in% keep) |>
    dplyr::group_by(.data$phase) |>
    dplyr::slice_max(.data$duration, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()

  if (nrow(last_runs) == 0) {
    cli::cli_abort(c(
      "No logged phase matches a target in the store.",
      "i" = "Check that {.arg log} and {.arg store} come from the same pipeline."
    ))
  }

  ggplot2::ggplot(
    last_runs,
    ggplot2::aes(
      x = .data$duration,
      y = stats::reorder(.data$phase, .data$duration),
      fill = .data$cpu
    )
  ) +
    ggplot2::geom_col() +
    ggplot2::scale_fill_viridis_c("CPU usage", end = 0.9, direction = -1) +
    ggplot2::labs(x = paste0("Duration (", units_time, ")"), y = NULL) +
    ggplot2::theme_bw()
}

#' Plot the full history of every logged run, including reruns
#'
#' @description
#'
#' <a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
#' <img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
#'
#' Draw a Gantt-style timeline of **every** process run recorded in an
#' \code{autometric} log, faceted by pipeline session. Each `(pid, phase)`
#' execution becomes a horizontal segment from its start to its end time,
#' colored by mean CPU usage.
#'
#' A log usually accumulates several pipeline executions that can be days or
#' weeks apart, so plotting them on one absolute time axis would squeeze every
#' run into an invisible sliver. Runs are therefore grouped into **sessions**
#' (consecutive runs separated by a gap larger than `session_gap`) and drawn in
#' their own facet with a session-relative time axis. A target rebuilt in
#' several sessions appears in several facets, which exposes the trial-and-error
#' and re-run cost that the "last run only" views
#' (\code{\link{ga_targets_meta_plot}()}, \code{\link{ga_autometric_lastrun}()})
#' hide by design. This full-history view is the closest to \code{greenAlgoR}'s
#' original motivation of accounting for the *whole* development cost of a
#' pipeline, not just its final build.
#'
#' @param log Either a path to an \code{autometric} log file (read with
#'   \code{autometric::log_read()}) or a data frame already returned by
#'   \code{autometric::log_read()} (with at least the columns `pid`, `phase`,
#'   `time`, `cpu`).
#' @param units_time,units_memory Passed to \code{autometric::log_read()} when
#'   `log` is a file path (defaults `"hours"` and `"gigabytes"`).
#' @param session_gap (numeric, default `1`) Gap, expressed in `units_time`,
#'   above which two consecutive runs are considered to belong to different
#'   pipeline sessions (facets). Increase it to merge runs into fewer sessions,
#'   decrease it to split more finely. Set to `Inf` to force a single session.
#' @param min_duration (numeric, default `0`) Drop runs shorter than this
#'   duration (in `units_time`). Useful to hide near-instant phases and keep the
#'   figure legible.
#' @param ... Additional arguments forwarded to \code{autometric::log_read()}.
#'
#' @return A \code{\link[ggplot2]{ggplot}} object: one facet per session, each
#'   with one segment per logged run.
#' @export
#' @author Adrien Taudière
#' @seealso \code{\link{ga_autometric_lastrun}()},
#'   \code{\link{ga_targets_meta_plot}()}, \code{\link{ga_autometric_plot}()}
#' @examples
#' if (requireNamespace("autometric", quietly = TRUE)) {
#'   log_df <- data.frame(
#'     version = "0.1.2",
#'     phase = c(rep("raw", 4), rep("scaled", 4), rep("raw", 4)),
#'     pid = c(rep(1L, 4), rep(2L, 4), rep(3L, 4)),
#'     name = "local",
#'     status = 0L,
#'     # Two sessions: the first at t ~ 0 h, a "raw" rerun ~ 5 h later.
#'     time = c(0, 0.1, 0.2, 0.3, 0.3, 0.35, 0.4, 0.45, 5.0, 5.1, 5.2, 5.3),
#'     core = runif(12, 0, 40),
#'     cpu = runif(12, 0, 90),
#'     resident = runif(12, 70, 90),
#'     virtual = runif(12, 900, 1000)
#'   )
#'   ga_autometric_history(log_df)
#' }
ga_autometric_history <- function(
  log,
  units_time = "hours",
  units_memory = "gigabytes",
  session_gap = 1,
  min_duration = 0,
  ...
) {
  runs <- ga_autometric_runs(
    log,
    units_time = units_time,
    units_memory = units_memory,
    ...
  )

  runs <- runs[runs$duration >= min_duration, , drop = FALSE]
  if (nrow(runs) == 0) {
    cli::cli_abort(c(
      "No run left to plot.",
      "i" = "Lower {.arg min_duration} (currently {.val {min_duration}})."
    ))
  }
  runs <- as.data.frame(runs)

  # Group runs into sessions: a gap between consecutive start times larger than
  # `session_gap` starts a new session. Facet on the session with a
  # session-relative time axis so short runs stay visible despite the long,
  # empty gaps between separate pipeline executions.
  runs <- runs[order(runs$start_time), , drop = FALSE]
  gap <- c(Inf, diff(runs$start_time))
  runs$session <- cumsum(gap > session_gap)

  sess_start <- tapply(runs$start_time, runs$session, min)
  runs$rel_start <- runs$start_time - sess_start[as.character(runs$session)]
  runs$rel_end <- runs$end_time - sess_start[as.character(runs$session)]
  runs$session <- factor(
    runs$session,
    levels = names(sort(sess_start)),
    labels = paste("session", seq_along(sess_start))
  )

  # Order phases by their overall first appearance so the pipeline reads
  # top (earliest) to bottom (latest).
  phase_first <- tapply(runs$start_time, runs$phase, min)
  runs$phase <- factor(
    runs$phase,
    levels = names(sort(phase_first, decreasing = TRUE))
  )

  ggplot2::ggplot(runs) +
    ggplot2::geom_segment(
      ggplot2::aes(
        x = .data$rel_start,
        xend = .data$rel_end,
        y = .data$phase,
        yend = .data$phase,
        colour = .data$cpu
      ),
      linewidth = 4
    ) +
    ggplot2::facet_grid(
      cols = ggplot2::vars(.data$session),
      scales = "free_x",
      space = "free_x"
    ) +
    ggplot2::scale_colour_viridis_c("CPU usage", end = 0.9, direction = -1) +
    ggplot2::labs(
      x = paste0("Time within session (", units_time, ")"),
      y = NULL
    ) +
    ggplot2::theme_bw()
}
