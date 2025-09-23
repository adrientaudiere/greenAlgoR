#' Calculate carbon footprint for targets pipelines
#'
#' @description
#'
#' <a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
#' <img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
#'
#' Calculates the total carbon footprint of a \code{targets} pipeline by analyzing
#' the metadata from completed targets. This function is a wrapper around 
#' \code{ga_footprint()} that automatically extracts runtime and storage information
#' from the targets metadata and computes the cumulative environmental impact.
#'
#' The function aggregates:
#' \itemize{
#'   \item Total runtime across all targets
#'   \item Memory usage patterns (when storage estimation is enabled)
#'   \item Hardware specifications you provide
#' }
#'
#' @param names_targets Character vector of target names to include in analysis.
#'   If NULL (default), analyzes all available targets. See \code{?targets::tar_meta()}
#' @param targets_only Logical (default TRUE). Whether to analyze only actual targets
#'   or also include metadata on functions and other global objects.
#' @param complete_only Logical (default FALSE). Whether to return only targets
#'   with complete metadata (no NA values in critical fields).
#' @param store Character string, path to the targets data store. 
#'   See \code{?targets::tar_meta()} for details.
#' @param tar_meta_raw Optional data.frame. If provided, uses this metadata directly
#'   instead of calling \code{targets::tar_meta()}. Useful for custom analyses
#'   or when working with pre-loaded metadata.
#' @param ... Additional arguments passed to \code{ga_footprint()}, such as:
#'   \itemize{
#'     \item \code{location_code}: geographical location for carbon intensity
#'     \item \code{n_cores}: number of CPU cores used
#'     \item \code{TDP_per_core}: thermal design power per core
#'     \item \code{memory_ram}: RAM memory in GB
#'     \item \code{PUE}: power usage effectiveness
#'   }
#'
#' @return A list with the same structure as \code{ga_footprint()}. 
#'   See \code{?ga_footprint} for complete details on return values.
#' @export
#' @author Adrien Taudière
#' @examples
#' \dontrun{
#' # Basic usage in a targets project directory
#' pipeline_footprint <- ga_targets()
#' 
#' # With specific hardware configuration
#' pipeline_footprint <- ga_targets(
#'   location_code = "FR",
#'   n_cores = 4,
#'   memory_ram = 16,
#'   PUE = 1.2
#' )
#' 
#' # Analyze specific targets only
#' pipeline_footprint <- ga_targets(
#'   names_targets = c("data_prep", "model_fit", "results"),
#'   add_storage_estimation = TRUE
#' )
#' }
#'
#' # The next exemple emulate a mini-targets before to ask for tar_meta
#' tar_dir({ # tar_dir() runs code from a temp dir for CRAN.
#'   tar_script(
#'     {
#'       list(
#'         tar_target(
#'           name = waiting,
#'           command = Sys.sleep(2),
#'           description = "Sleep 2 seconds"
#'         ),
#'         tar_target(x, writeLines(
#'           targets::tar_option_get("error"),
#'           "error.txt"
#'         ))
#'       )
#'     },
#'     ask = FALSE
#'   )
#'
#'   tar_make()
#'   tm <- tar_meta()
#'
#'   res_gat <-
#'     ga_targets(
#'       tar_meta_raw = tm,
#'       n_cores = 6,
#'       TDP_per_core = 15.8,
#'       location_code = "FR",
#'       PUE = 2,
#'       add_storage_estimation = TRUE
#'     )
#'
#'   ggplot(res_gat$ref_value, aes(
#'     y = reorder(variable, as.numeric(value)),
#'     x = as.numeric(value), fill = log10(prop_footprint)
#'   )) +
#'     geom_col() +
#'     geom_col(data = data.frame(
#'       variable = "Total ",
#'       value = res_gat$carbon_footprint_total_gCO2
#'     ), fill = "grey30") +
#'     geom_col(
#'       data = data.frame(
#'         variable = "Cores",
#'         value = res_gat$carbon_intensity * res_gat$power_draw_for_cores_kWh
#'       ),
#'       fill = "darkred"
#'     ) +
#'     geom_col(
#'       data = data.frame(
#'         variable = "Memory",
#'         value = res_gat$carbon_intensity * res_gat$power_draw_for_memory_kWh
#'       ),
#'       fill = "orange"
#'     ) +
#'     geom_col(
#'       data = data.frame(
#'         variable = "Storage",
#'         value = res_gat$carbon_intensity * res_gat$power_draw_per_gb
#'       ),
#'       fill = "violet"
#'     ) +
#'     scale_x_continuous(trans = "log1p") +
#'     geom_vline(
#'       xintercept = res_gat$carbon_footprint_total_gCO2,
#'       col = "grey30", lwd = 1.2
#'     ) +
#'     geom_label(aes(label = round(prop_footprint, 1)), fill = "grey90") +
#'     xlab("g CO^2") +
#'     ylab("Modality")
#' })
#'
ga_targets <- function(names_targets = NULL,
                       targets_only = TRUE,
                       complete_only = FALSE,
                       store = targets::tar_config_get("store"),
                       tar_meta_raw = NULL,
                       ...) {
  if (is.null(tar_meta_raw)) {
    if (is.null(names_targets)) {
      df_meta <- targets::tar_meta(
        targets_only = targets_only,
        names = NULL,
        complete_only = complete_only,
        store = store
      )
    } else {
      df_meta <- targets::tar_meta(
        targets_only = targets_only,
        names = names_targets,
        complete_only = complete_only,
        store = store
      )
    }
  }
  else {
    df_meta <- tar_meta_raw
  }

  runtime_targets <- sum(as.numeric(df_meta$seconds), na.rm = TRUE) / 3600
  power_draw_stocks <- sum(as.numeric(df_meta$bytes), na.rm = TRUE) / 10^9

  res <- ga_footprint(runtime_h = as.numeric(runtime_targets),
                      mass_storage = power_draw_stocks,
                      ...)

  return(res)
}
