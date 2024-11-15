#' Title
#'
#' @param add_storage_estimation 
#' @param names 
#' @param fields 
#' @param targets_only 
#' @param complete_only 
#' @param store 
#' @param ... 
#'
#' @return
#' @export
#'
#' @examples
ga_targets <- function(
  add_storage_estimation = FALSE,
  names = NULL,
  fields = NULL,
  targets_only = TRUE,
  complete_only = FALSE,
  store = targets::tar_config_get("store"),
  ...) {

  print(store)

  if(is.null(names)) {
    if(is.null(fields)) {
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
    if(is.null(fields)) {
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

  runtime_targets <- sum(df_meta$seconds)/3600

  res <- ga_footprint(runtime_h = as.numeric(runtime_targets), ...)

  if(add_storage_estimation) {
    power_draw_stocks <- sum(df_meta$bytes)/10^9 * 0.001 # source https://onlinelibrary.wiley.com/doi/10.1002/advs.202100707
    res[["power_draw_storage (kWh)"]] <- power_draw_stocks * res$PUE * res$PSF * res[["runtime (h)"]]

    res[["energy needed (kWh)"]] <- res[["energy needed (kWh)"]] + res[["power_draw_storage (kWh)"]]
    res[["carbon_footprint (g CO2)"]] <- res[["energy needed (kWh)"]] * res[["carbon intensity"]]
  }
  return(res)
}

ga_targets(
  nb_cores = 6,
  TDP_per_core = 15.8,
  location_code = "FR",
  PUE=1
)

ga_targets(
  nb_cores = 6,
  TDP_per_core = 15.8,
  location_code = "FR",
  PUE=1,
  add_storage_estimation = T
)

res_gat <- ga_targets(
  nb_cores = 6,
  TDP_per_core = 15.8,
  location_code = "FR",
  PUE=2,
  add_storage_estimation = T
)

ggplot(res_gat$ref_value, aes(y = reorder(variable, as.numeric(value)), x = as.numeric(value), fill = log10(prop_footprint))) +
  geom_col() +
  geom_col(data = data.frame(variable = "Total ", value = res_gat$`carbon_footprint (g CO2)`), fill = "grey30") +
  geom_col(data = data.frame(variable = "Cores", value = res_gat$`carbon intensity` * res_gat$`power_draw_for_cores (kWh)`), fill = "darkred") +
  geom_col(data = data.frame(variable = "Memory", value = res_gat$`carbon intensity` * res_gat$`power_draw_for_memory (kWh)`), fill = "orange") +
  geom_col(data = data.frame(variable = "Storage", value = res_gat$`carbon intensity` * res_gat$`power_draw_storage (kWh)`), fill = "violet") +
  scale_x_continuous(trans = "log1p") +
  geom_vline(xintercept = res_gat$`carbon_footprint (g CO2)`, col = "grey30", lwd = 1.2) +
  geom_label(aes(label = round(prop_footprint, 1)), fill="grey90") +
  xlab("g CO^2") +
  ylab("Modality")

