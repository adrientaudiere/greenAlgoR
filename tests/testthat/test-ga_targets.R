tar_test("ga_targets works", {
  tar_script({
    list(
      tar_target(
        name = waiting,
        command =     Sys.sleep(12),
        description = "Sleep 12 seconds"
      ),
      tar_target(x, writeLines(targets::tar_option_get("error"), "error.txt"))
    )
  })
  tar_make()
  testthat::expect_equal(dim(tar_meta()), c(2, 18))
  expect_equal(ga_targets()$carbon_footprint_gCO2, 0.09819032, tolerance=1e-3)
  expect_equal(ga_targets()$energy_needed_kWh, 0.0002066649, tolerance=1e-4)
  tm <- tar_meta(targets_only = FALSE)

 expect_equal(ga_targets(tar_meta_raw=tm)$energy_needed_kWh, 0.0002066649, tolerance=1e-5)

})
