# Plot per-target runtime and output size from `targets` metadata

[![lifecycle-experimental](https://img.shields.io/badge/lifecycle-experimental-orange)](https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle)

Draw one horizontal bar per target from
[`targets::tar_meta()`](https://docs.ropensci.org/targets/reference/tar_meta.html),
with bar length mapped to the target runtime (`seconds`) and fill mapped
to the output size (`Gb`). Because `tar_meta()` only stores the metadata
of the **latest** build of each target, this figure summarizes the
resource impact of the *last* pipeline run. Targets that emitted a
warning during that run are flagged with a red star.

This is the metadata-based companion of
[`ga_autometric_lastrun()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_autometric_lastrun.md)
(which reconstructs the same "last run" picture from an `autometric`
log) and of
[`ga_targets_network()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_targets_network.md)
(which shows the dependency structure).

## Usage

``` r
ga_targets_meta_plot(
  names_targets = NULL,
  targets_only = TRUE,
  store = targets::tar_config_get("store"),
  tar_meta_raw = NULL,
  transform = "pseudo_log",
  mark_warnings = TRUE
)
```

## Arguments

- names_targets:

  (character, default `NULL`) Optional vector of target names to
  restrict the plot to. When `NULL`, every target is shown. Passed to
  [`targets::tar_meta()`](https://docs.ropensci.org/targets/reference/tar_meta.html).

- targets_only:

  (logical, default `TRUE`) Whether to show only actual targets (not
  functions or other global objects). Passed to
  [`targets::tar_meta()`](https://docs.ropensci.org/targets/reference/tar_meta.html).

- store:

  (character, default `targets::tar_config_get("store")`) Path to the
  targets data store. See `?targets::tar_meta()`.

- tar_meta_raw:

  (optional data.frame) A precomputed
  [`targets::tar_meta()`](https://docs.ropensci.org/targets/reference/tar_meta.html)
  result. When supplied, `store`, `names_targets` and `targets_only` are
  ignored. Useful for tests or pre-loaded metadata.

- transform:

  (character, default "pseudo_log") Transformation applied to the x
  (runtime) axis via
  [`ggplot2::scale_x_continuous()`](https://ggplot2.tidyverse.org/reference/scale_continuous.html).
  Runtimes often span several orders of magnitude, so a compressing
  transform such as "pseudo_log" or "log1p" keeps short targets visible.
  Use "identity" for a linear axis.

- mark_warnings:

  (logical, default `TRUE`) Whether to overlay a red star on targets
  that recorded a warning in their metadata.

## Value

A [`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html) object
with one bar per target.

## See also

[`ga_autometric_lastrun()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_autometric_lastrun.md),
[`ga_autometric_history()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_autometric_history.md),
[`ga_targets_network()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_targets_network.md)

## Author

Adrien Taudière

## Examples

``` r
targets::tar_dir({ # tar_dir() runs code from a temp dir for CRAN.
  targets::tar_script(
    {
      list(
        targets::tar_target(raw, rnorm(1e5)),
        targets::tar_target(scaled, raw * 2),
        targets::tar_target(summ, mean(scaled))
      )
    },
    ask = FALSE
  )
  targets::tar_make(reporter = "silent")
  ga_targets_meta_plot(tar_meta_raw = targets::tar_meta(targets_only = TRUE))
})
```
