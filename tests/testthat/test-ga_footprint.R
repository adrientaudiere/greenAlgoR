test_that("12h of my config works and cpu model overwrite n_cores and TDP_per_core", {
  res_12_my_config <- ga_footprint(
    runtime_h = 12,
    location_code = "FR",
    PUE = 1,
    cpu_model = "Core i5-13400",
    memory_ram = 67.4
  )
  expect_equal(length(res_12_my_config), 18)
  expect_equal(
    res_12_my_config$carbon_footprint_total_gCO2,
    36.157936,
    tolerance = 1e-3
  )
  expect_equal(res_12_my_config$energy_needed_kWh, 1.081278, tolerance = 1e-3)

  res_12_my_config_bis <- ga_footprint(
    runtime_h = 12,
    n_cores = 66,
    TDP_per_core = 15.8,
    location_code = "FR",
    PUE = 1,
    cpu_model = "Core i5-13400",
    memory_ram = 67.4
  )

  expect_equal(
    res_12_my_config_bis$carbon_footprint_total_gCO2,
    res_12_my_config$carbon_footprint_total_gCO2
  )

  expect_equal(
    res_12_my_config_bis$energy_needed_kWh,
    res_12_my_config$energy_needed_kWh
  )
})

test_that("12h of my config whitout cpu_model works", {
  res_12_my_config2 <- ga_footprint(
    runtime_h = 12,
    n_cores = 6,
    TDP_per_core = 15.8,
    location_code = "FR",
    PUE = 1,
    memory_ram = 67.4
  )
  expect_equal(length(res_12_my_config2), 18)
  expect_equal(
    res_12_my_config2$carbon_footprint_total_gCO2,
    48.11608,
    tolerance = 1e-3
  )
  expect_equal(res_12_my_config2$energy_needed_kWh, 1.438878, tolerance = 1e-3)
})

test_that("12h of my config in WORLD", {
  res_12_my_config3 <- ga_footprint(
    runtime_h = 12,
    n_cores = 6,
    TDP_per_core = 15.8,
    PUE = 1,
    memory_ram = 67.4
  )
  expect_equal(length(res_12_my_config3), 18)
  expect_equal(
    res_12_my_config3$carbon_footprint_total_gCO2,
    683.46705,
    tolerance = 1e-3
  )
  expect_equal(res_12_my_config3$energy_needed_kWh, 1.438878, tolerance = 1e-3)
})

test_that("12h of my config works PUE 0.5", {
  res_12_my_config_pue0.5 <- ga_footprint(
    runtime_h = 12,
    location_code = "FR",
    PUE = 0.5,
    cpu_model = "Core i5-13400",
    memory_ram = 67.4
  )
  expect_equal(length(res_12_my_config_pue0.5), 18)
  expect_equal(
    res_12_my_config_pue0.5$carbon_footprint_total_gCO2,
    18.078968,
    tolerance = 1e-3
  )
})

test_that("12h of my config works PSF 22", {
  res_12_my_config_psf22 <- ga_footprint(
    runtime_h = 12,
    location_code = "FR",
    PSF = 22,
    cpu_model = "Core i5-13400",
    memory_ram = 67.4
  )
  expect_equal(length(res_12_my_config_psf22), 18)
  expect_equal(
    res_12_my_config_psf22$carbon_footprint_total_gCO2,
    1240.9404,
    tolerance = 1e-3
  )
})

test_that("2h of a custom weird config", {
  res_12_weird_config <- ga_footprint(
    runtime_h = 2,
    n_cores = 6,
    TDP_per_core = 15.8,
    location_code = "FR",
    PUE = 0.5,
    add_ref_values = FALSE,
    add_storage_estimation = TRUE,
    PSF = 22,
    memory_ram = 67.4
  )
  expect_equal(length(res_12_weird_config), 19)
  expect_equal(
    res_12_weird_config$carbon_footprint_total_gCO2,
    88.41,
    tolerance = 1
  )
  expect_equal(
    res_12_weird_config$energy_needed_kWh,
    2.643846,
    tolerance = 1e-2
  )
})

test_that("2h of a custom weird config 2", {
  res_12_weird_config2 <- ga_footprint(
    runtime_h = 2,
    n_cores = 6,
    TDP_per_core = 0,
    location_code = "FR",
    PUE = 0.5,
    add_ref_values = TRUE,
    add_storage_estimation = TRUE,
    mass_storage = 120,
    PSF = 22,
    memory_ram = 67.4
  )
  expect_equal(length(res_12_weird_config2), 20)
  expect_equal(
    res_12_weird_config2$carbon_footprint_total_gCO2,
    22.48315,
    tolerance = 1e-3
  )
  expect_equal(
    res_12_weird_config2$energy_needed_kWh,
    0.672343,
    tolerance = 1e-3
  )
})


test_that("12h of my config works", {
  # I do not put memory_ram = 64 so I cant expect equal of value works with
  # codecov
  res_12h <- ga_footprint(
    runtime_h = 12,
    n_cores = 2
  )
  expect_equal(length(res_12h), 18)
})

test_that("Single numeric carbon_intensity is used directly", {
  res <- ga_footprint(runtime_h = 2, carbon_intensity = 42)
  expect_equal(res$carbon_intensity, 42)
})

test_that("Named numeric vector overrides bundled CI for a location", {
  res <- ga_footprint(
    runtime_h = 2,
    location_code = "FR",
    carbon_intensity = c("FR" = 56)
  )
  expect_equal(res$carbon_intensity, 56)
})

test_that("Named numeric vector adds a new location not in bundled DB", {
  res <- ga_footprint(
    runtime_h = 2,
    location_code = "CUSTOM_DC",
    carbon_intensity = c("CUSTOM_DC" = 450)
  )
  expect_equal(res$carbon_intensity, 450)
})

test_that("Backward compatibility: no carbon_intensity still works", {
  res <- ga_footprint(runtime_h = 2, location_code = "FR")
  expect_true(is.numeric(res$carbon_intensity))
  expect_true(res$carbon_intensity > 0)
})

test_that("Single numeric carbon_intensity yields correct footprint formula", {
  res <- ga_footprint(runtime_h = 2, carbon_intensity = 42)
  expected <- res$energy_needed_kWh * 42
  expect_equal(res$carbon_footprint_total_gCO2, expected)
})

test_that("ref_value gives the cores and memory footprints in gCO2", {
  res <- ga_footprint(runtime_h = 2, memory_ram = 16, location_code = "FR")
  rv <- res$ref_value
  expect_equal(
    as.numeric(rv$value[rv$variable == "Cores"]),
    res$carbon_footprint_cores
  )
  expect_equal(
    as.numeric(rv$value[rv$variable == "Memory"]),
    res$carbon_footprint_memory
  )
})

test_that("Defaults follow the Green Algorithms calculator v3.1", {
  res <- ga_footprint(runtime_h = 1, memory_ram = 1)
  expect_equal(res$PUE, 1.56)
  expect_equal(res$TDP_per_core, 7.46)
  expect_equal(res$carbon_intensity, 475)
})

test_that("cpu_model is matched exactly, then by the longest contained name", {
  fp <- function(model) {
    ga_footprint(runtime_h = 1, memory_ram = 1, cpu_model = model)
  }
  expect_equal(fp("Xeon Gold 5415+")$TDP_per_core, 150 / 8)
  expect_equal(fp("AMD EPYC 7713")$n_cores, 64)
  expect_equal(fp("13th Gen Intel Core i9-13900KS")$TDP_per_core, 150 / 24)
  expect_error(fp("No such CPU"), "don't match any cpu model")
})
