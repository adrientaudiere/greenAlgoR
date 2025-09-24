#' Compute footprint in grams of CO2 using [Lannelongue et al. 2021](https://doi.org/10.1002/advs.202100707) algorithm
#'
#' @description
#'
#' <a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
#' <img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
#'
#'
#' Please cite Lannelongue, L., Grealey, J., Inouye, M., Green Algorithms:
#' Quantifying the Carbon Footprint of Computation. Adv. Sci. 2021, 2100707.
#' https://doi.org/10.1002/advs.202100707
#'
#' Default value are from https://github.com/GreenAlgorithms/green-algorithms-tool:
#'
#' - PUE: https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/default_PUE.csv
#' - TDP_per_core: https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/CPUs.csv
#' - power_draw_per_gb: https://onlinelibrary.wiley.com/doi/10.1002/advs.202100707
#'
#' Description of the algorithm from the
#' [green-algorithms](https://github.com/GreenAlgorithms/green-algorithms-tool)
#'  website:
#'
#' """
#'
#'   The carbon footprint is calculated by estimating the energy draw of the
#'   algorithm and the carbon intensity of producing this energy at a
#'   given location:
#'
#'   \deqn{carbon footprint = energy needed * carbon intensity}
#'
#'   Where the energy needed is:
#'
#'  \deqn{runtime * (power draw for cores * usage + power draw for memory) * PUE * PSF}
#'
#'   The power draw for the computing cores depends on the model and number of cores,
#'  while the memory power draw only depends on the size of memory available.
#'  The usage factor corrects for the real core usage (default is 1, i.e. full usage).
#'  The PUE (Power Usage Effectiveness) measures how much extra energy is needed
#'  to operate the data centre (cooling, lighting etc.).
#'
#'  The PSF (Pragmatic Scaling Factor) is used to take into account multiple
#'  identical runs (e.g. for testing or optimisation).
#'
#'  The Carbon Intensity depends on the location and the technologies used
#'  to produce electricity. But note that the "energy needed"
#'  \[...\] is independent of the location.
#'
#'  """
#'
#' @param runtime_h Runtime in hours (numeric). Use a positive number for
#'   explicit runtime, or "session" to automatically calculate based on
#'   current R session time using \code{proc.time()}.
#' @param location_code Character string specifying geographical location for
#'   carbon intensity. Available options include country codes (e.g., "FR", "US", "CN")
#'   or "WORLD" for global average. See the Green Algorithms database for
#'   complete list of supported locations.
#' @param PUE Power Usage Effectiveness (numeric, default 1.67). Measures data center
#'   efficiency - how much extra energy is needed for cooling, lighting, etc.
#'   Use 1.05 for personal computers, 1.2-1.7 for data centers. See
#'   \url{https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/default_PUE.csv}
#' @param TDP_per_core Thermal Design Power per core in Watts (numeric, default 12).
#'   CPU power consumption per core. Find values at \url{https://www.techpowerup.com/cpu-specs/}
#'   or \url{http://calculator.green-algorithms.org/}. Overridden by \code{cpu_model} parameter.
#' @param n_cores Number of CPU cores (integer, default 1).
#'   Overridden by \code{cpu_model} parameter.
#' @param cpu_model Character string specifying exact CPU model. Must match entries
#'   in the Green Algorithms database. When specified, automatically sets
#'   \code{TDP_per_core} and \code{n_cores}. Use "Any" for generic calculation.
#' @param memory_ram RAM memory in GB (numeric). If NULL, attempts to detect
#'   automatically using \code{benchmarkme::get_ram()}.
#' @param power_draw_per_gb Power consumption per GB of RAM in Watts (numeric, default 0.3725).
#' @param PSF Pragmatic Scaling Factor (numeric, default 1). Accounts for multiple
#'   runs of the same computation. As noted by Lannelongue et al. (2021):
#'   "computations are rarely performed only once" - use values > 1 to account
#'   for repeated runs, parameter sweeps, or iterative development.
#'   GHG emissions are multiplied."
#' @param usage_core (int, default 1).
#'   The usage factor corrects for the real core usage
#'   (default is 1, i.e. full usage).
#' @param add_ref_values (logical, default TRUE) Do we compute and return
#'   reference values to compare to your footprint ?
#' @param add_storage_estimation (logical, default FALSE) Do we compute the
#'   footprint of mass storage ? By default FALSE because it is far less
#'   important than cpu and memory usage. Note that
#'   [green-algorithms](https://github.com/GreenAlgorithms/)
#'   original tool do not compute mass storage usage.
#' @param mass_storage (int. in GB, default NULL) The size of the mass_storage.
#'   Only used if add_storage_estimation is set to TRUE. If set to NULL, use
#'   the `base::gc()` function to estimate storage used.
#' @param carbon_intensity (default NULL). Advanced users only.
#'   A dataframe with `location` and `carbonIntensity`
#'   columns. Set to carbon_intensity_internal if NULL.
#'   carbon_intensity_internal is set using command line
#'   csv_from_url_ga("https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/CI_aggregated.csv")
#' @param TDP_cpu (default NULL). Advanced users only.
#'   A dataframe with `model`, `n_cores` and `TDP_per_core`
#'   columns. Set to TDP_cpu_internal if NULL.
#'   TDP_cpu_internal is set using command line
#'   csv_from_url_ga("https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/CPUs.csv")
#' @param ref_value (default NULL). Advanced users only.
#'   A dataframe with `variable` and `value`
#'   columns. Set to ref_value_internal if NULL.
#'   ref_value_internal is set using command line
#'   csv_from_url_ga("https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/referenceValues.csv")
#'
#' @return A list of values
#'  - `runtime_h`: the input run time in hours
#'  - `location_code`: the input location code
#'  - `TDP_per_core`: the input TDP_per_core (if cpu_model is set, correspond to
#'    the TDP_per_core for this cpu)
#'  - `n_cores`: the input n_cores (if cpu_model is set, correspond to
#'    the n_cores for this cpu)
#'  - `cpu_model`: the input cpu model. If set to "Any", TDP_per_core and ncore are used
#'  - `memory_ram`: the input memory ram in GB
#'  - `power_draw_per_gb`: the input power draw per GB
#'  - `usage_core`: the input usage core
#'  - `carbon_intensity`: the input carbon intensity (depend on location code)
#'  - `PUE`: the input PUE
#'  - `PSF`: the input PUE
#'  - `power_draw_for_cores_kWh`: the output power draw for cores in kWh
#'  - `power_draw_for_memory_kWh`: the output power draw for RAM memory in kWh
#'  - `energy_needed_kWh`: the output energy needed in kWh
#'  - `carbon_footprint_cores`: the output carbon footprint in grams of CO2 for
#'    cores usage
#'  - `carbon_footprint_memory`: the output carbon footprint in grams of CO2 for
#'    memory usage
#'  - `carbon_footprint_total_gCO2`: the total output carbon footprint in grams of CO2
#'  - `ref_value`: (optionnal, return if add_ref_values is TRUE) : a dataframe
#'  - `power_draw_storage_kWh`: (optionnal, return if add_storage_estimation is TRUE)
#'    the output power draw for mass storage in kWh
#' @export
#' @author Adrien Taudière
#' @examples
#' # Basic usage with explicit parameters
#' result <- ga_footprint(
#'   runtime_h = 2,
#'   n_cores = 4,
#'   TDP_per_core = 15,
#'   memory_ram = 16,
#'   location_code = "WORLD"
#' )
#' result$carbon_footprint_total_gCO2
#'
#' # Using specific CPU model (automatically sets cores and TDP)
#' ga_footprint(
#'   runtime_h = 1,
#'   cpu_model = "Core i5-9600KF",
#'   location_code = "FR"
#' )
#'
#' # Calculate footprint for current R session
#' ga_footprint(runtime_h = "session")
#'
#' # Compare different locations
#' locations <- c("WORLD", "FR", "US", "NO")
#' sapply(locations, function(loc) {
#'   ga_footprint(runtime_h = 1, location_code = loc)$carbon_footprint_total_gCO2
#' })
#'
#' # Advanced usage with storage estimation and reference values
#' res_ga <- ga_footprint(
#'   runtime_h = 4,
#'   n_cores = 8,
#'   memory_ram = 32,
#'   add_storage_estimation = TRUE,
#'   add_ref_values = TRUE
#' )
#'
#' ggplot(res_ga$ref_value, aes(y = variable, x = as.numeric(value), fill = log10(prop_footprint))) +
#'   geom_col() +
#'   geom_col(data = data.frame(
#'     variable = "Total",
#'     value = res_ga$carbon_footprint_total_gCO2
#'   ), fill = "grey30") +
#'   geom_col(data = data.frame(
#'     variable = "Cores",
#'     value = res_ga$carbon_footprint_cores
#'   ), fill = "darkred") +
#'   geom_col(data = data.frame(
#'     variable = "Memory",
#'     value = res_ga$carbon_footprint_memory
#'   ), fill = "orange") +
#'   geom_col(data = data.frame(
#'     variable = "Mass storage",
#'     value = res_ga$carbon_footprint_storage
#'   ), fill = "violet") +
#'   scale_x_continuous(
#'     trans = "log1p",
#'     breaks = c(0, 10^c(1:max(log1p(as.numeric(res_ga$ref_value$value)))))
#'   ) +
#'   geom_vline(
#'     xintercept = res_ga$carbon_footprint_total_gCO2,
#'     col = "grey30", lwd = 1.2
#'   ) +
#'   geom_label(aes(label = round_conditionaly(prop_footprint)),
#'     fill = "grey90", position = position_stack(vjust = 1.1)
#'   ) +
#'   labs(
#'     title = "Carbon footprint of the analysis",
#'     subtitle = paste0(
#'       "(", res_ga$carbon_footprint_total_gCO2,
#'       " g CO2", ")"
#'     ),
#'     caption = "Please cite Lannelongue et al. 2021 (10.1002/advs.202100707)"
#'   ) +
#'   xlab("Carbon footprint (g CO2) in log10") +
#'   ylab("Modality") +
#'   theme(legend.position = "none")
ga_footprint <- function(runtime_h = NULL,
                         location_code = "WORLD",
                         PUE = 1.67,
                         TDP_per_core = 12.0,
                         n_cores = 1,
                         cpu_model = "Any",
                         memory_ram = NULL,
                         power_draw_per_gb = 0.3725,
                         PSF = 1,
                         usage_core = 1,
                         add_ref_values = TRUE,
                         add_storage_estimation = FALSE,
                         mass_storage = NULL,
                         carbon_intensity = NULL,
                         TDP_cpu = NULL,
                         ref_value = NULL) {
  if (is.null(runtime_h)) {
    stop("You must specify a runtime in hours in the parameter runtime_h or
         the special character 'session' or 'session_runtime'")
  }

  if (runtime_h == "session") {
    runtime_h <- session_runtime()$cpu_times / 3600
  } else if (runtime_h == "session_time_elapsed") {
    runtime_h <- session_runtime()$time_elapsed / 3600
  }

  if (is.null(memory_ram)) {
    memory_ram <- as.numeric(benchmarkme::get_ram()) / 10^9
  }

  if (cpu_model != "Any") {
    # if (cpu_model != "auto") {
    #   cpu_model <- benchmarkme::get_cpu()$model_name
    # }
    if (is.null(TDP_cpu)) {
      TDP_cpu <- TDP_cpu_internal
    }

    match_cpu_model <- sapply(TDP_cpu$model, function(x) {
      grepl(x, cpu_model)
    })

    if (sum(match_cpu_model) == 0) {
      stop(
        "cpu_model ",
        cpu_model,
        " don't match any cpu model present in object TDP_cpu_internal"
      )
    } else if (sum(match_cpu_model) > 1) {
      stop(
        "cpu_model ",
        cpu_model,
        " match multiple cpu model present in object TDP_cpu_internal"
      )
    }

    TDP_per_core <- as.numeric(TDP_cpu$TDP_per_core[match_cpu_model])
    n_cores <- as.numeric(TDP_cpu$n_cores[match_cpu_model])
  }

  TDP <- TDP_per_core * n_cores

  if (is.null(carbon_intensity)) {
    carbon_intensity <- carbon_intensity_internal
  }
  CI <- as.numeric(carbon_intensity$carbonIntensity[carbon_intensity$location == location_code])

  power_draw_for_cores <- n_cores * TDP_per_core * usage_core * 0.001 * runtime_h * PUE * PSF
  power_draw_for_memory <- power_draw_per_gb * memory_ram * 0.001 * runtime_h * PUE * PSF

  carbon_footprint_cores <- power_draw_for_cores * CI
  carbon_footprint_memory <- power_draw_for_memory * CI

  energy_needed <- power_draw_for_cores + power_draw_for_memory
  carbon_footprint <- carbon_footprint_cores + carbon_footprint_memory

  res <- list(
    "runtime_h" = runtime_h,
    "location_code" = location_code,
    "TDP_per_core" = TDP_per_core,
    "n_cores" = n_cores,
    "cpu_model" = cpu_model,
    "memory_ram" = memory_ram,
    "power_draw_per_gb" = power_draw_per_gb,
    "usage core" = usage_core,
    "carbon_intensity" = CI,
    "PUE" = PUE,
    "PSF" = PSF,
    "power_draw_for_cores_kWh" = power_draw_for_cores,
    "power_draw_for_memory_kWh" = power_draw_for_memory,
    "energy_needed_kWh" = energy_needed,
    "carbon_footprint_cores" = carbon_footprint_cores,
    "carbon_footprint_memory" = carbon_footprint_memory,
    "carbon_footprint_total_gCO2" = carbon_footprint
  )

  if (add_ref_values) {
    if (is.null(ref_value)) {
      ref_value <- ref_value_internal[order(as.numeric(ref_value_internal$value)), ]
      rownames(ref_value) <- NULL
    }
    res[["ref_value"]] <- rbind(
      c("Total", res$carbon_footprint_total_gCO2, NA),
      c("Cores", res$power_draw_for_cores_kWh, NA),
      c("Memory", res$power_draw_for_memory_kWh, NA),
      ref_value
    )
  }

  if (add_storage_estimation) {
    if (is.null(mass_storage)) {
      mass_storage <- sum(gc()[1:2, 2]) / 10^3 * 0.001
    } else {
      mass_storage <- mass_storage * 0.001
    }
    res[["power_draw_storage_kWh"]] <- mass_storage * res$PUE * res[["runtime_h"]] # * res$PSF
    res[["carbon_footprint_storage"]] <- res[["power_draw_storage_kWh"]] * CI
    res[["energy_needed_kWh"]] <- res[["energy_needed_kWh"]] + res[["power_draw_storage_kWh"]]
    res[["carbon_footprint_total_gCO2"]] <- res[["carbon_footprint_cores"]] + res[["carbon_footprint_memory"]] + res[["carbon_footprint_storage"]]

    if (add_ref_values) {
      res[["ref_value"]] <- rbind(
        c("Total", res$carbon_footprint_total_gCO2, NA),
        c("Cores", res$carbon_footprint_cores, NA),
        c("Memory", res$carbon_footprint_memory, NA),
        c("Mass storage", res$carbon_footprint_storage, NA),
        ref_value
      )
    }
  }
  if (add_ref_values) {
    res[["ref_value"]]$prop_footprint <- sapply(as.numeric(res[["ref_value"]]$value), function(x) {
      x / res$carbon_footprint_total_gCO2
    })

    # to force ggplot to keep row order
    res[["ref_value"]]$variable <- factor(res[["ref_value"]]$variable,
      levels = res[["ref_value"]]$variable
    )
  }

  return(res)
}
