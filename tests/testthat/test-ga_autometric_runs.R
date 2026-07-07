make_fake_runlog <- function() {
  data.frame(
    version = "0.1.2",
    phase = c(
      rep("raw", 4),
      rep("scaled", 4),
      rep("raw", 4),
      rep("prepare:pipeline", 2)
    ),
    pid = c(rep(11L, 4), rep(12L, 4), rep(21L, 4), rep(99L, 2)),
    name = "local",
    status = 0L,
    time = c(
      c(0, 0.1, 0.2, 0.4),
      c(0.4, 0.45, 0.5, 0.55),
      c(1.0, 1.05, 1.1, 1.2),
      c(0, 0.01)
    ),
    core = 10,
    cpu = c(rep(80, 4), rep(30, 4), rep(90, 4), rep(1, 2)),
    resident = 80,
    virtual = 950,
    stringsAsFactors = FALSE
  )
}

test_that("ga_autometric_lastrun keeps the longest run per stored phase", {
  skip_if_not_installed("autometric")
  p <- ga_autometric_lastrun(
    make_fake_runlog(),
    object_names = c("raw", "scaled")
  )
  expect_s3_class(p, "ggplot")
  # One bar per stored phase, prepare: phase dropped.
  expect_equal(nrow(p$data), 2)
  # raw has two runs (0.4 h and 0.2 h); the 0.4 h one is kept.
  raw_row <- p$data[p$data$phase == "raw", ]
  expect_equal(as.numeric(raw_row$duration), 0.4)
})

test_that("ga_autometric_lastrun errors when nothing matches the store", {
  skip_if_not_installed("autometric")
  expect_error(
    ga_autometric_lastrun(make_fake_runlog(), object_names = "absent"),
    "No logged phase"
  )
})

test_that("ga_autometric_history keeps every run including reruns", {
  skip_if_not_installed("autometric")
  p <- ga_autometric_history(make_fake_runlog())
  expect_s3_class(p, "ggplot")
  # raw (x2) + scaled (x1), prepare: phase dropped -> 3 segments.
  expect_equal(nrow(p$data), 3)
  expect_equal(sum(p$data$phase == "raw"), 2)
})

test_that("ga_autometric_history filters short runs via min_duration", {
  skip_if_not_installed("autometric")
  p <- ga_autometric_history(make_fake_runlog(), min_duration = 0.3)
  # Only the two 0.4 h+ raw runs survive.
  expect_true(all(p$data$phase == "raw"))
})

test_that("ga_autometric_history splits far-apart runs into sessions", {
  skip_if_not_installed("autometric")
  # Two runs 100 h apart: without session splitting the second would be an
  # invisible sliver on a 0-100 h axis (the original empty-graph bug).
  d <- data.frame(
    version = "0.1.2",
    phase = c(rep("raw", 3), rep("raw", 3)),
    pid = c(rep(1L, 3), rep(2L, 3)),
    name = "local",
    status = 0L,
    time = c(0, 0.1, 0.3, 100, 100.1, 100.3),
    core = 10,
    cpu = 50,
    resident = 80,
    virtual = 950,
    stringsAsFactors = FALSE
  )
  p <- ga_autometric_history(d)
  expect_length(levels(p$data$session), 2)
  # Session-relative time keeps every segment short (max 0.3 h), not ~100 h.
  expect_lt(max(p$data$rel_end), 1)
})

test_that("ga_autometric_history session_gap = Inf forces one session", {
  skip_if_not_installed("autometric")
  d <- data.frame(
    version = "0.1.2",
    phase = c(rep("raw", 3), rep("raw", 3)),
    pid = c(rep(1L, 3), rep(2L, 3)),
    name = "local",
    status = 0L,
    time = c(0, 0.1, 0.3, 100, 100.1, 100.3),
    core = 10,
    cpu = 50,
    resident = 80,
    virtual = 950,
    stringsAsFactors = FALSE
  )
  p <- ga_autometric_history(d, session_gap = Inf)
  expect_length(levels(p$data$session), 1)
})
