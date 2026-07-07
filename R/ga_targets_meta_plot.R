#' Plot per-target runtime and output size from `targets` metadata
#'
#' @description
#'
#' <a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
#' <img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
#'
#' Draw one horizontal bar per target from \code{targets::tar_meta()}, with bar
#' length mapped to the target runtime (`seconds`) and fill mapped to the output
#' size (`Gb`). Because \code{tar_meta()} only stores the metadata of the
#' **latest** build of each target, this figure summarizes the resource impact
#' of the *last* pipeline run. Targets that emitted a warning during that run are
#' flagged with a red star.
#'
#' This is the metadata-based companion of \code{\link{ga_autometric_lastrun}()}
#' (which reconstructs the same "last run" picture from an \code{autometric}
#' log) and of \code{\link{ga_targets_network}()} (which shows the dependency
#' structure).
#'
#' @param names_targets (character, default `NULL`) Optional vector of target
#'   names to restrict the plot to. When `NULL`, every target is shown. Passed
#'   to \code{targets::tar_meta()}.
#' @param targets_only (logical, default `TRUE`) Whether to show only actual
#'   targets (not functions or other global objects). Passed to
#'   \code{targets::tar_meta()}.
#' @param store (character, default `targets::tar_config_get("store")`) Path to
#'   the targets data store. See \code{?targets::tar_meta()}.
#' @param tar_meta_raw (optional data.frame) A precomputed
#'   \code{targets::tar_meta()} result. When supplied, `store`, `names_targets`
#'   and `targets_only` are ignored. Useful for tests or pre-loaded metadata.
#' @param transform (character, default "pseudo_log") Transformation applied to
#'   the x (runtime) axis via \code{ggplot2::scale_x_continuous()}. Runtimes
#'   often span several orders of magnitude, so a compressing transform such as
#'   "pseudo_log" or "log1p" keeps short targets visible. Use "identity" for a
#'   linear axis.
#' @param mark_warnings (logical, default `TRUE`) Whether to overlay a red star
#'   on targets that recorded a warning in their metadata.
#'
#' @return A \code{\link[ggplot2]{ggplot}} object with one bar per target.
#' @export
#' @author Adrien Taudière
#' @seealso \code{\link{ga_autometric_lastrun}()},
#'   \code{\link{ga_autometric_history}()}, \code{\link{ga_targets_network}()}
#' @examples
#' targets::tar_dir({ # tar_dir() runs code from a temp dir for CRAN.
#'   targets::tar_script(
#'     {
#'       list(
#'         targets::tar_target(raw, rnorm(1e5)),
#'         targets::tar_target(scaled, raw * 2),
#'         targets::tar_target(summ, mean(scaled))
#'       )
#'     },
#'     ask = FALSE
#'   )
#'   targets::tar_make(reporter = "silent")
#'   ga_targets_meta_plot(tar_meta_raw = targets::tar_meta(targets_only = TRUE))
#' })
ga_targets_meta_plot <- function(
  names_targets = NULL,
  targets_only = TRUE,
  store = targets::tar_config_get("store"),
  tar_meta_raw = NULL,
  transform = "pseudo_log",
  mark_warnings = TRUE
) {
  df_meta <- if (is.null(tar_meta_raw)) {
    # `tar_meta(names = ...)` uses tidyselect NSE: passing the `names_targets`
    # variable (rather than a literal) makes an external NULL select nothing.
    # Fetch every target's metadata, then subset by name with base R.
    targets::tar_meta(targets_only = targets_only, store = store)
  } else {
    as.data.frame(tar_meta_raw)
  }

  if (!is.null(names_targets)) {
    df_meta <- df_meta[df_meta$name %in% names_targets, , drop = FALSE]
  }

  needed <- c("name", "seconds", "bytes")
  missing_cols <- setdiff(needed, colnames(df_meta))
  if (length(missing_cols) > 0) {
    cli::cli_abort(c(
      "The targets metadata is missing required column{?s} {.val {missing_cols}}.",
      "i" = "Was it produced by {.fn targets::tar_meta}?"
    ))
  }

  df <- df_meta[!is.na(df_meta$seconds), , drop = FALSE]
  if (nrow(df) == 0) {
    cli::cli_abort(c(
      "No target has a recorded runtime ({.field seconds} all {.val NA}).",
      "i" = "Has {.fn targets::tar_make} been run on this store?"
    ))
  }

  df$seconds <- as.numeric(df$seconds)
  df$Gb <- round(as.numeric(df$bytes) / 10^9, 2)
  df$name <- stats::reorder(df$name, df$seconds)

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(x = .data$seconds, y = .data$name, fill = .data$Gb)
  ) +
    ggplot2::geom_col() +
    ggplot2::scale_fill_viridis_c(
      "Output size (Gb)",
      end = 0.9,
      direction = -1
    ) +
    ggplot2::scale_x_continuous(transform = transform) +
    ggplot2::labs(x = "Runtime (seconds)", y = NULL) +
    ggplot2::theme_bw()

  if (mark_warnings && "warnings" %in% colnames(df)) {
    warned <- df[!is.na(df$warnings), , drop = FALSE]
    if (nrow(warned) > 0) {
      p <- p +
        ggplot2::geom_point(
          data = warned,
          shape = "*",
          colour = "red",
          size = 5
        )
    }
  }

  p
}
