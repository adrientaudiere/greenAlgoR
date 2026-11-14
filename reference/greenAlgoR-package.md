# `greenAlgoR` package

**Carbon Footprint Estimation for R Computations**

The `greenAlgoR` package provides tools to estimate the carbon footprint
and energy consumption of computational tasks in R. Based on the Green
Algorithms framework developed by Lannelongue et al. (2021), this
package helps researchers and data scientists understand and minimize
the environmental impact of their work.

## Internal Data

The package includes some internal datasets to work outline. You can
access them directly after loading the package (TDP_cpu_internal,
carbon_intensity_internal and ref_value_internal). You can also replace
default data by overwritting them. They come from the Green Algorithms
data v3.1, the version used by the Green Algorithms calculator v3.1
(<https://github.com/Cambridge-Sustainable-Computing-Lab/Green-Algorithms-data>,
commit 0a1d169):

- `TDP_cpu_internal`: `v3.1/chips/manual/CPUs-manual.csv`, with
  `TDP_per_core` computed as `TDP / n_cores`.

- `carbon_intensity_internal`: the life-cycle carbon intensities of
  Electricity Maps 2024
  (`v3.1/carbon-intensity/electricitymap/CI-electricitymap-yearly_2024-with-continents.csv`),
  plus a `"WORLD"` row at 475 gCO2e/kWh, the world average the
  calculator uses as its default.

- `ref_value_internal`: `v3.1/context.csv`, without `PB_ADP_per_capita`,
  which is not in gCO2e.

## Main Functions

- [`ga_footprint`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_footprint.md):
  Calculate carbon footprint for individual computations

- [`ga_targets`](https://adrientaudiere.github.io/greenAlgoR/reference/ga_targets.md):
  Calculate carbon footprint for targets pipelines

- [`session_runtime`](https://adrientaudiere.github.io/greenAlgoR/reference/session_runtime.md):
  Compute session runtime and memory usage

## Key Features

- Estimate CO2 emissions based on runtime, CPU usage, and memory
  consumption

- Support for different geographical locations with varying carbon
  intensities

- Integration with the `targets` package for pipeline analysis

- Visualization tools for carbon footprint comparisons

- Configurable hardware specifications (CPU models, memory, storage)

## Getting Started

To get started with `greenAlgoR`, try:


    # Basic usage - estimate footprint of a 12-hour computation
    result <- ga_footprint(runtime_h = 12, location_code = "WORLD")

    # For your current R session
    session_footprint <- ga_footprint(runtime_h = "session")

    # For targets pipelines (in a targets project)
    targets_footprint <- ga_targets()

## References

Lannelongue, L., Grealey, J., Inouye, M. (2021). Green Algorithms:
Quantifying the Carbon Footprint of Computation. *Advanced Science*,
8(12), 2100707.
[doi:10.1002/advs.202100707](https://doi.org/10.1002/advs.202100707)

## Author

Adrien Taudière <adrien.taudiere@zaclys.net>
