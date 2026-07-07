# Plot resource-usage logs recorded by the `autometric` package

[![lifecycle-experimental](https://img.shields.io/badge/lifecycle-experimental-orange)](https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle)

Render a [`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)
of the CPU and memory usage recorded by
[`autometric::log_start()`](https://wlandau.github.io/autometric/reference/log_start.html)
/
[`autometric::log_stop()`](https://wlandau.github.io/autometric/reference/log_stop.html).
Each selected metric is drawn as a line over time, faceted so that
percentage metrics (CPU) and megabyte metrics (memory) keep their own
y-axis scale. This turns an `autometric` log into a publication-ready
resource-usage figure and pairs naturally with the carbon-footprint
estimates of
[`ga_footprint()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_footprint.md).

## Usage

``` r
ga_autometric_plot(
  log,
  metrics = c("cpu", "resident"),
  color_by = "phase",
  ...
)
```

## Arguments

- log:

  Either a path to an `autometric` log file (read with
  [`autometric::log_read()`](https://wlandau.github.io/autometric/reference/log_read.html))
  or a data frame already returned by
  [`autometric::log_read()`](https://wlandau.github.io/autometric/reference/log_read.html)
  (with at least the columns `time`, `cpu`, `core`, `resident`,
  `virtual`).

- metrics:

  (character, default `c("cpu", "resident")`) Which columns to plot. Any
  subset of "cpu" (\\ "resident" (resident memory, MB) and "virtual"
  (virtual memory, MB).

- color_by:

  (character, default "phase") Column used to color the lines, typically
  "phase", "name" or "pid" so several logged phases or processes can be
  compared on one plot.

- ...:

  Additional arguments passed on to
  [`autometric::log_read()`](https://wlandau.github.io/autometric/reference/log_read.html)
  when `log` is a file path.

## Value

A [`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html) object
with one facet per metric.

## See also

[`ga_targets_network()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_targets_network.md),
[`ga_footprint()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_footprint.md)

## Author

Adrien Taudière

## Examples

``` r
if (requireNamespace("autometric", quietly = TRUE)) {
  log_file <- tempfile()
  autometric::log_start(path = log_file, seconds = 0.05)
  x <- numeric(0)
  for (i in 1:5) {
    x <- c(x, rnorm(2e5))
    Sys.sleep(0.1)
  }
  autometric::log_stop()
  ga_autometric_plot(log_file)
}
```
