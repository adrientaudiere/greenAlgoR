test_that("ga_targets_network builds a ggplot from a tar_network object", {
  skip_if_not_installed("ggnetwork")
  skip_if_not_installed("network")

  net <- list(
    vertices = data.frame(
      name = c("raw", "scaled", "summ"),
      type = "stem",
      status = "uptodate",
      seconds = c(0.5, 0.2, 0.01),
      bytes = c(767870, 775289, 55),
      stringsAsFactors = FALSE
    ),
    edges = data.frame(
      from = c("raw", "scaled"),
      to = c("scaled", "summ"),
      stringsAsFactors = FALSE
    )
  )

  p <- ga_targets_network(tar_network_raw = net)
  expect_s3_class(p, "ggplot")

  p2 <- ga_targets_network(
    tar_network_raw = net,
    size_by = "bytes",
    color_by = "status",
    label = FALSE
  )
  expect_s3_class(p2, "ggplot")
})

test_that("ga_targets_network errors on an empty pipeline", {
  skip_if_not_installed("ggnetwork")
  skip_if_not_installed("network")
  empty <- list(
    vertices = data.frame(
      name = character(0),
      seconds = numeric(0),
      bytes = numeric(0),
      status = character(0)
    ),
    edges = data.frame(from = character(0), to = character(0))
  )
  expect_error(ga_targets_network(tar_network_raw = empty), "no targets")
})
