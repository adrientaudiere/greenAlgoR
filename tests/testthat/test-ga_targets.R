tar_test("ga_targets works", {
  tar_script({
    list(
      tar_target(
        name = waiting,
        command = Sys.sleep(2),
        description = "Sleep 2 seconds"
      ),
      tar_target(x, writeLines(targets::tar_option_get("error"), "error.txt"))
    )
  })
  tar_make()
  testthat::expect_equal(dim(tar_meta()), c(2, 18))
  testthat::expect_equal(length(ga_targets()), 18)
  tm <- tar_meta(targets_only = FALSE)

  testthat::expect_equal(length(ga_targets(tar_meta_raw = tm)), 18)
})

tar_test("ga_targets works with names_targets", {
  tar_script({
    list(
      tar_target(
        name = waiting,
        command = Sys.sleep(2),
        description = "Sleep 2 seconds"
      ),
      tar_target(x, writeLines(targets::tar_option_get("error"), "error.txt"))
    )
  })
  tar_make()
  testthat::expect_equal(dim(tar_meta()), c(2, 18))
  testthat::expect_equal(length(ga_targets()), 18)
  tm <- tar_meta(targets_only = FALSE)

  testthat::expect_equal(length(ga_targets(names_targets = "waiting")), 18)
})

