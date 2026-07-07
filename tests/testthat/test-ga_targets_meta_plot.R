make_fake_meta <- function() {
  data.frame(
    name = c("raw", "scaled", "summ"),
    seconds = c(10, 2, 5),
    bytes = c(8e9, 1e6, 5e6),
    warnings = c(NA, NA, "a warning"),
    stringsAsFactors = FALSE
  )
}

test_that("ga_targets_meta_plot builds a ggplot from tar_meta data", {
  p <- ga_targets_meta_plot(tar_meta_raw = make_fake_meta())
  expect_s3_class(p, "ggplot")
  # One bar per target with a recorded runtime.
  expect_equal(nrow(p$data), 3)
})

test_that("ga_targets_meta_plot drops targets without a runtime", {
  d <- make_fake_meta()
  d$seconds[2] <- NA
  p <- ga_targets_meta_plot(tar_meta_raw = d)
  expect_equal(nrow(p$data), 2)
})

test_that("ga_targets_meta_plot errors when no runtime is recorded", {
  d <- make_fake_meta()
  d$seconds <- NA_real_
  expect_error(ga_targets_meta_plot(tar_meta_raw = d), "No target")
})

test_that("ga_targets_meta_plot errors on missing required columns", {
  d <- make_fake_meta()
  d$bytes <- NULL
  expect_error(ga_targets_meta_plot(tar_meta_raw = d), "missing required")
})
