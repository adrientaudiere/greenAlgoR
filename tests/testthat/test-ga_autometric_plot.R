make_fake_log <- function() {
  data.frame(
    version = "0.1.2",
    phase = rep(c("load", "compute"), each = 5),
    pid = 1L,
    name = "local",
    status = 0L,
    time = rep(seq(0, 0.4, by = 0.1), 2),
    core = runif(10, 0, 40),
    cpu = runif(10, 0, 10),
    resident = runif(10, 70, 90),
    virtual = runif(10, 900, 1000),
    stringsAsFactors = FALSE
  )
}

test_that("ga_autometric_plot builds a ggplot from a log data frame", {
  skip_if_not_installed("autometric")
  d <- make_fake_log()
  p <- ga_autometric_plot(d)
  expect_s3_class(p, "ggplot")

  p2 <- ga_autometric_plot(
    d,
    metrics = c("cpu", "core", "resident", "virtual"),
    color_by = "phase"
  )
  expect_s3_class(p2, "ggplot")
  # Four metrics -> four facets, coloured by the two phases.
  expect_length(unique(p2$data$metric), 4)
})

test_that("ga_autometric_plot errors on a missing metric column", {
  skip_if_not_installed("autometric")
  d <- make_fake_log()
  d$resident <- NULL
  expect_error(ga_autometric_plot(d, metrics = "resident"), "missing required")
})
