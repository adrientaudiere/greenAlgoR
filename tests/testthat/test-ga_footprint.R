test_that("12h of my config works", {
  res_12_my_config <- ga_footprint(
    runtime_h = 12,
    n_cores = 6,
    TDP_per_core = 15.8,
    location_code = "FR",
    PUE = 1,
    cpu_model = "Core i5-9600KF",
    memory_ram = 67.4
  )
  expect_equal(length(res_12_my_config), 18)
  expect_equal(res_12_my_config$carbon_footprint_total_gCO2, 73.776386, tolerance = 1e-3)
  expect_equal(res_12_my_config$energy_needed_kWh, 1.438697, tolerance = 1e-3)
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
  expect_equal(res_12_my_config2$carbon_footprint_total_gCO2, 73.776386, tolerance = 1e-3)
  expect_equal(res_12_my_config2$energy_needed_kWh, 1.438697, tolerance = 1e-3)
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
  expect_equal(res_12_my_config3$carbon_footprint_total_gCO2, 683.3811, tolerance = 1e-3)
  expect_equal(res_12_my_config3$energy_needed_kWh, 1.438697, tolerance = 1e-3)
})

test_that("12h of my config works PUE 0.5", {
  res_12_my_config_pue0.5 <- ga_footprint(
    runtime_h = 12,
    location_code = "FR",
    PUE = 0.5,
    cpu_model = "Core i5-9600KF",
    memory_ram = 67.4
  )
  expect_equal(length(res_12_my_config_pue0.5), 18)
  expect_equal(res_12_my_config_pue0.5$carbon_footprint_total_gCO2, 36.88819, tolerance = 1e-3)
})

test_that("12h of my config works PSF 22", {
  res_12_my_config_psf22 <- ga_footprint(
    runtime_h = 12,
    location_code = "FR",
    PSF = 22,
    cpu_model = "Core i5-9600KF",
    memory_ram = 67.4
  )
  expect_equal(length(res_12_my_config_psf22), 18)
  expect_equal(res_12_my_config_psf22$carbon_footprint_total_gCO2, 2710.544, tolerance = 1e-3)
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
  expect_equal(res_12_weird_config$carbon_footprint_total_gCO2, 135.5764, tolerance = 1)
  expect_equal(res_12_weird_config$energy_needed_kWh, 2.643846, tolerance = 1e-2)
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
  expect_equal(res_12_weird_config2$carbon_footprint_total_gCO2, 34.46074, tolerance = 1e-3)
  expect_equal(res_12_weird_config2$energy_needed_kWh, 0.6720113, tolerance = 1e-3)
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
