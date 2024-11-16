#' Compute footprint in grams of CO2 for {targets} pipelines
#'
#' @description
#'
#' <a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
#' <img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
#'
#' It is mainly a wrapper of function `ga_footprint()` that compute run time and
#' mass_storage (only used if add_storage_estimation = TRUE) using
#' `targets::tar_meta()`.
#'
#' @param names Optional, names of the targets. See ?targets::tar_meta()
#' @param fields Optional, names of columns/fields to select.
#'   See ?targets::tar_meta()
#' @param targets_only Logical, whether to just show information about targets
#'   or also return metadata on functions and other global objects.
#' @param complete_only Logical,
#' whether to return only complete rows (no NA values).
#' @param store Character of length 1, path to the targets data store.
#'   See ?targets::tar_meta()
#' @param tar_meta_raw Optional, if not NULL, other listed options above
#'  (params for `targets::tar_meta()` are not used.
#' @param ... Other args to be passed on `ga_footprint()`
#'
#' @return A list of value. See ?ga_footprint for the details.
#' @export
#' @author Adrien Taudière
#' @examples
#'
#' # In a targets folder, just run function ga_targets()
#' # with the options you want
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
#'         tar_target(x, writeLines(targets::tar_option_get("error"), "error.txt"))
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
#'   ggplot(res_gat$ref_value, aes(y = reorder(variable, as.numeric(value)), x = as.numeric(value), fill = log10(prop_footprint))) +
#'     geom_col() +
#'     geom_col(data = data.frame(variable = "Total ", value = res_gat$carbon_footprint_gCO2), fill = "grey30") +
#'     geom_col(data = data.frame(variable = "Cores", value = res_gat$carbon_intensity * res_gat$power_draw_for_cores_kWh), fill = "darkred") +
#'     geom_col(data = data.frame(variable = "Memory", value = res_gat$carbon_intensity * res_gat$power_draw_for_memory_kWh), fill = "orange") +
#'     geom_col(data = data.frame(variable = "Storage", value = res_gat$carbon_intensity * res_gat$power_draw_per_gb), fill = "violet") +
#'     scale_x_continuous(trans = "log1p") +
#'     geom_vline(xintercept = res_gat$carbon_footprint_gCO2, col = "grey30", lwd = 1.2) +
#'     geom_label(aes(label = round(prop_footprint, 1)), fill = "grey90") +
#'     xlab("g CO^2") +
#'     ylab("Modality")
#' })
#'
ga_targets <- function(names = NULL,
                       fields = NULL,
                       targets_only = TRUE,
                       complete_only = FALSE,
                       store = targets::tar_config_get("store"),
                       tar_meta_raw = NULL,
                       ...) {
  if (is.null(tar_meta_raw)) {
    if (is.null(names)) {
      if (is.null(fields)) {
        df_meta <- targets::tar_meta(
          targets_only = targets_only,
          names = NULL,
          fields = NULL,
          complete_only = complete_only,
          store = here::here(store)
        )
      } else {
        df_meta <- targets::tar_meta(
          targets_only = targets_only,
          names = NULL,
          fields = fields,
          complete_only = complete_only,
          store = here::here(store)
        )
      }
    } else {
      if (is.null(fields)) {
        df_meta <- targets::tar_meta(
          targets_only = targets_only,
          names = names,
          fields = NULL,
          complete_only = complete_only,
          store = here::here(store)
        )
      } else {
        df_meta <- targets::tar_meta(
          targets_only = targets_only,
          names = names,
          fields = fields,
          complete_only = complete_only,
          store = here::here(store)
        )
      }
    }
  } else {
    df_meta <- tar_meta_raw
  }

  runtime_targets <- sum(df_meta$seconds, na.rm = TRUE) / 3600
  power_draw_stocks <- sum(df_meta$bytes, na.rm = TRUE) / 10^9

  res <- ga_footprint(
    runtime_h = as.numeric(runtime_targets),
    mass_storage = power_draw_stocks,
    ...
  )

  return(res)
}
