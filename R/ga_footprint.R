benchmarkme::get_cpu()$model_name
# Find your cpu TDP and your nb of cpu on https://www.techpowerup.com/cpu-specs/ or in http://calculator.green-algorithms.org/ if available

ga_footprint <- function(
  runtime_h = NA, # in hours, "session" take the cpu usage of the actual R session 
  location_code = "WORLD",
  PUE = 1.67,
  TDP_per_core = 12.0,
  n_cores = 1,
  cpu_model = "Any", # Must be present in the list of http://calculator.green-algorithms.org/ "auto" is not running for the moment 
  memory_ram = NA, # in GB
  PSF = 1,
  usage_core = 1,
  add_ref_value = TRUE,
  add_storage_estimation = FALSE,
  mass_storage = NULL # # in GB
) {

  if(is.na(runtime_h)) {
    stop("You must specify a runtime in hours in the parameter runtime_h")
  }
  
  if(runtime_h=="auto") {
    runtime_h <- session_runtime()$cpu_times/3600
  }
  
  if(is.na(memory_ram)) {
    memory_ram <- as.numeric(benchmarkme::get_ram())/10^9
  }

  if(cpu_model != "Any") {
    # if (cpu_model != "auto") {
    #   cpu_model <- benchmarkme::get_cpu()$model_name
    # }
    TDP_cpu <- csv_from_url_green_algo("https://raw.githubusercontent.com/GreenAlgorithms/green-algorithms-tool/refs/heads/master/data/v2.2/TDP_cpu.csv")
    match_cpu_model <- sapply(TDP_cpu$model, function(x) {grepl( x, cpu_model)})
    TDP_per_core <- as.numeric(TDP_cpu$TDP_per_core[match_cpu_model])
    n_cores <- TDP_cpu$n_cores[match_cpu_model]
  }

  TDP <- TDP_per_core * n_cores

  carbon_intensity <- csv_from_url_green_algo("https://raw.githubusercontent.com/GreenAlgorithms/green-algorithms-tool/refs/heads/master/data/v2.2/CI_aggregated.csv")
  ref_value <- csv_from_url_green_algo("https://raw.githubusercontent.com/GreenAlgorithms/green-algorithms-tool/refs/heads/master/data/v2.2/referenceValues.csv")

  CI <- as.numeric(carbon_intensity$carbonIntensity[carbon_intensity$location == location_code])

  # source : https://github.com/GreenAlgorithms/green-algorithms-tool/blob/master/data/v2.2/defaults_PUE.csv

  power_draw_for_cores <- n_cores * TDP_per_core * usage_core * 0.001
  power_draw_for_memory <- 0.3725 * memory_ram * 0.001  # source : https://onlinelibrary.wiley.com/doi/10.1002/advs.202100707

  energy_needed <- runtime_h * (power_draw_for_cores + power_draw_for_memory) * PUE * PSF
  carbon_footprint <- energy_needed * CI

  res <- list(
    "runtime (h)" = runtime_h,
    "location_code" = location_code,
    "TDP_per_core" = TDP_per_core,
    "n_cores" = n_cores,
    "cpu_model" = cpu_model,
    "memory_ram" = memory_ram,
    "usage core" = usage_core,
    "carbon intensity" = CI,
    "PUE" = PUE,
    "PSF" = PSF,
    "power_draw_for_cores (kWh)" = power_draw_for_cores,
    "power_draw_for_memory (kWh)" = power_draw_for_memory,
    "ratio_power_memory__power_cores" = round(power_draw_for_memory / power_draw_for_cores, 2),
    "energy needed (kWh)" = energy_needed,
    "carbon_footprint (g CO2)" = carbon_footprint
  )
  
  if(add_ref_value) {
    ref_value <- csv_from_url_green_algo("https://raw.githubusercontent.com/GreenAlgorithms/green-algorithms-tool/refs/heads/master/data/v2.2/referenceValues.csv")
    ref_value <- ref_value[-1,]

    ref_value$prop_footprint <-  sapply(as.numeric(ref_value$value), function(x) {x/res$`carbon_footprint (g CO2)`})
    res[["ref_value"]] <- ref_value
  }
  
  if(add_storage_estimation) {
    if(is.null(mass_storage)){
      mass_storage <- sum(gc(FALSE, TRUE, TRUE)[1:2,2])*10^3
    }
    
    power_draw_stocks <- mass_storage # source https://onlinelibrary.wiley.com/doi/10.1002/advs.202100707
    res[["power_draw_storage (kWh)"]] <- power_draw_stocks * res$PUE * res$PSF * res[["runtime (h)"]]
    
    res[["energy needed (kWh)"]] <- res[["energy needed (kWh)"]] + res[["power_draw_storage (kWh)"]]
    res[["carbon_footprint (g CO2)"]] <- res[["energy needed (kWh)"]] * res[["carbon intensity"]]
  }
  
  return(res)
}

ga_footprint(
  runtime_h = 12,
  n_cores = 6,
  TDP_per_core = 15.8,
  location_code = "FR",
  PUE=1,
  cpu_model = "Core i5-9600KF"
)

ga_footprint(runtime_h = "auto")



session_runtime <- function() {
  cpu_times_all <- proc.time()
  cpu_times_users <- cpu_times_all[1] + cpu_times_all[2]
  cpu_times_system <- cpu_times_all[4] + cpu_times_all[5]
  time_elapsed <- cpu_times_all[3]
  cpu_times_users_system <- cpu_times_users + cpu_times_system
  return(list(
    "cpu_times_users" = cpu_times_users,
    "cpu_times_system" = cpu_times_system,
    "time_elapsed" = time_elapsed,
    "cpu_times" = cpu_times_users_system
  ))
}


mass_storage_used <- sum(gc()[1:2,2])
mass_storage_max <- sum(gc()[1:2,6])
