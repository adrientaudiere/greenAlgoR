# Visualize a `targets` pipeline as a resource-annotated network

[![lifecycle-experimental](https://img.shields.io/badge/lifecycle-experimental-orange)](https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle)

Draw the dependency graph of a `targets` pipeline with `ggnetwork`,
encoding the per-target computational cost as visual aesthetics: node
**size** and **color** map to a resource metric (runtime in seconds or
output size in bytes) and each edge **width** maps to the runtime of its
downstream target. This gives a quick, at-a-glance picture of where a
pipeline spends its time and storage, complementing the aggregated
figures of
[`ga_targets()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_targets.md).

The per-target metrics (`seconds`, `bytes`) are taken directly from
[`targets::tar_network()`](https://docs.ropensci.org/targets/reference/tar_network.html),
so no separate `tar_meta()` call is needed.

## Usage

``` r
ga_targets_network(
  store = targets::tar_config_get("store"),
  script = targets::tar_config_get("script"),
  tar_network_raw = NULL,
  size_by = "seconds",
  color_by = "bytes",
  layout = "fruchtermanreingold",
  label = TRUE,
  arrow_gap = 0.02,
  ...
)
```

## Arguments

- store:

  (character, default `targets::tar_config_get("store")`) Path to the
  targets data store. See `?targets::tar_network()`.

- script:

  (character, default `targets::tar_config_get("script")`) Path to the
  target script file (e.g. `_targets.R`). Required by
  [`targets::tar_network()`](https://docs.ropensci.org/targets/reference/tar_network.html)
  to build the pipeline graph. See `?targets::tar_network()`.

- tar_network_raw:

  (optional list) A precomputed
  [`targets::tar_network()`](https://docs.ropensci.org/targets/reference/tar_network.html)
  result (a list with `$vertices` and `$edges`). When supplied, `store`
  is ignored. Useful for tests, custom analyses, or when the pipeline
  metadata is already loaded.

- size_by:

  (character, default "seconds") Vertex attribute mapped to node size.
  One of "seconds" (runtime) or "bytes" (output size).

- color_by:

  (character, default "bytes") Vertex attribute mapped to node color.
  One of "seconds", "bytes" or "status" (the target build status).

- layout:

  (character, default "fruchtermanreingold") A network layout name
  passed to
  [`ggnetwork::ggnetwork()`](https://rdrr.io/pkg/ggnetwork/man/ggnetwork.html).

- label:

  (logical, default TRUE) Draw the target names next to the nodes.

- arrow_gap:

  (numeric, default 0.02) Gap left between the arrow head and the target
  node, passed to
  [`ggnetwork::ggnetwork()`](https://rdrr.io/pkg/ggnetwork/man/ggnetwork.html).

- ...:

  Additional arguments passed on to
  [`ggnetwork::ggnetwork()`](https://rdrr.io/pkg/ggnetwork/man/ggnetwork.html).

## Value

A [`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html) object
showing the pipeline network.

## See also

[`ga_targets()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_targets.md),
[`ga_autometric_plot()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_autometric_plot.md)

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
  net <- targets::tar_network(targets_only = TRUE)
  ga_targets_network(tar_network_raw = net)
})
```
