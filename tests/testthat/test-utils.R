test_that("csv_from_url_ga works fine", {
  carbon_intensity_internal <-
    csv_from_url_ga("https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/CI_aggregated.csv")
  expect_equal(dim(carbon_intensity_internal), c(131, 8))

  carbon_intensity_internal2 <-
    csv_from_url_ga("https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/CI_aggregated.csv", remove_first_line = FALSE)
  expect_equal(dim(carbon_intensity_internal2), c(132, 8))
})

test_that("session_runtime works fine", {
  sr <- session_runtime()
  expect_equal(length(sr), 6)
})

test_that("round_conditionaly works fine", {
  expect_equal(round_conditionaly(c(0.0001, 1000.000001)), c(0.0001, 1000))
})
