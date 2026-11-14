# Changelog

## greenAlgoR 0.3.0

### Breaking changes

- The internal data follow the Green Algorithms data v3.1, the version
  of the Green Algorithms calculator v3.1, so footprints change for the
  same inputs. Carbon intensities are now the life-cycle values of
  Electricity Maps 2024, whose zone codes replace part of the former
  location codes: codes such as `"US-CA"`, `"US-FL"`, `"RU"` or
  `"CN-HK"` give the error “location_code … not found”; pick an
  Electricity Maps zone from
  `greenAlgoR:::carbon_intensity_internal$location`
  (e.g. `"US-CAL-CISO"`) or pass your own value with `carbon_intensity`.
  `"WORLD"` stays at 475 gCO2e/kWh. Some CPU models of the former table
  are gone (e.g. `"Core i5-9600KF"`); set `TDP_per_core` and `n_cores`
  for them.
- [`ga_footprint()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_footprint.md)
  sets the PUE from the new `platform` argument, as the calculator v3.1
  does: 1 for a `"laptop"` or a `"desktop"`, 1.56 for a `"local_server"`
  or the `"cloud"` (unknown data centre; the former default was 1.67
  everywhere). The default `platform = "auto"` detects the machine type
  from its chassis type (Linux, Windows), its battery (macOS) or the
  name of a cloud virtual machine (Linux), returns it as `platform` in
  the result, and falls back to 1.56 with a message when detection
  fails. `PUE`, now `NULL` by default, still overrides it. `platform`
  comes right after `location_code`, so a `PUE` given by position must
  now be named. `TDP_per_core` defaults to 7.46 W (the “Average” CPU of
  the calculator, was 12).

### Other changes

- [`ga_footprint()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_footprint.md)
  matches `cpu_model` exactly first, then by the longest model name
  contained in it, so models whose name holds a regular-expression
  character (`"Xeon Gold 5415+"`) or is the start of another one
  (`"AMD EPYC 7713"` and `"AMD EPYC 7713P"`) are found.
- [`ga_footprint()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_footprint.md)
  gives the footprints of the cores and of the memory in gCO2e in the
  `ref_value` table, like the other rows; without
  `add_storage_estimation`, the “Cores” and “Memory” rows held their
  energy in kWh.
- [`ga_footprint()`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_footprint.md)
  no longer lists the memory power draw (0.3725 W/GB) among the
  reference values compared to the footprint; the reference values come
  from `context.csv` of the Green Algorithms data v3.1 (Netflix
  streaming is now 55 gCO2e per hour, and the yearly per-capita
  planetary boundary, 985 kgCO2e, is added).

## greenAlgoR 0.2.0

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
