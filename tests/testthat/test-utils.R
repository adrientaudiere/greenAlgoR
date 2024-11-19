test_that("csv_from_url_ga works fine", {
  carbon_intensity_internal <-
    csv_from_url_ga("https://raw.githubusercontent.com/GreenAlgorithms/green-algorithms-tool/refs/heads/master/data/v2.2/CI_aggregated.csv")
  expect_equal(dim(carbon_intensity_internal), c(130, 8))

  carbon_intensity_internal2 <-
    csv_from_url_ga("https://raw.githubusercontent.com/GreenAlgorithms/green-algorithms-tool/refs/heads/master/data/v2.2/CI_aggregated.csv", remove_first_line = FALSE)
  expect_equal(dim(carbon_intensity_internal2), c(131, 8))
})

test_that("session_runtime works fine", {
  sr <- session_runtime()
  expect_equal(length(sr), 6)
})

test_that("round_conditionaly works fine", {
  expect_equal(round_conditionaly(c(0.0001, 1000.000001)), c(0.0001, 1000))
})
