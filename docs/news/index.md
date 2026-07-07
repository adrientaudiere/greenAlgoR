# Changelog

## greenAlgoR 0.2.0 (Development version)

- [`ga_autometric_history()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_autometric_history.md)
  draws a Gantt-style timeline of every process run in an `autometric`
  log, grouped into pipeline sessions (faceted by the `session_gap`
  argument) with a session-relative time axis, so a target rebuilt
  across several executions appears in several facets, exposing the
  trial-and-error and re-run cost that last-run views hide.
- [`ga_autometric_lastrun()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_autometric_lastrun.md)
  reconstructs the last-run resource impact from an `autometric` log,
  keeping only the single longest run of each target still present in
  the `targets` store and drawing one duration bar per target colored by
  mean CPU usage.
- [`ga_autometric_plot()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_autometric_plot.md)
  renders the CPU and memory usage recorded by the `autometric` package
  as a faceted `ggplot2` line plot over time, with one facet per metric
  and lines colored by logging phase, process or name.
- [`ga_targets_meta_plot()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_targets_meta_plot.md)
  draws one bar per target from
  [`targets::tar_meta()`](https://docs.ropensci.org/targets/reference/tar_meta.html),
  mapping runtime to bar length and output size to fill and flagging
  targets that emitted a warning, summarizing the resource impact of the
  last pipeline run from its metadata.
- [`ga_targets_network()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_targets_network.md)
  visualizes a `targets` pipeline as a resource-annotated dependency
  network via `ggnetwork`, mapping per-target runtime and output size to
  node size and color and the downstream-target runtime to edge width.

## greenAlgoR 0.1.2

- [`ga_footprint()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_footprint.md)
  gains flexible `carbon_intensity` input: in addition to the existing
  data.frame format, the parameter now accepts a single numeric value
  (used directly as gCO2e/kWh regardless of `location_code`) or a named
  numeric vector (overrides/adds entries to the bundled database). This
  makes it easy to plug in custom carbon-intensity values from sources
  like the Electricity Maps API.

## greenAlgoR 0.1.2

- Improve documentation
- Create two vignettes: “Introduction to greenAlgoR” and “Targets
  integration”
- Correct url to v3 of greenalgorithm and update internal data in
  sysdata.rda

## greenAlgoR 0.1.1

- Remove the useless argument `fields` from
  [`ga_targets()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_targets.md)

## greenAlgoR 0.1

- Initial github submission.
- Creation of function
  [`ga_footprint()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_footprint.md)
  and
  [`ga_targets()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_targets.md)
