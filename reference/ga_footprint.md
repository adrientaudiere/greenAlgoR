# Compute footprint in grams of CO2 using [Lannelongue et al. 2021](https://doi.org/10.1002/advs.202100707) algorithm

[![lifecycle-experimental](https://img.shields.io/badge/lifecycle-experimental-orange)](https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle)

Please cite Lannelongue, L., Grealey, J., Inouye, M., Green Algorithms:
Quantifying the Carbon Footprint of Computation. Adv. Sci. 2021,
2100707.
[doi:10.1002/advs.202100707](https://doi.org/10.1002/advs.202100707)

Default value are from
https://github.com/Cambridge-Sustainable-Computing-Lab/Green-Algorithms-calculator:

- PUE:
  https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/default_PUE.csv

- TDP_per_core:
  https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/CPUs.csv

- power_draw_per_gb:
  https://onlinelibrary.wiley.com/doi/10.1002/advs.202100707

Description of the algorithm from the
[green-algorithms](https://github.com/Cambridge-Sustainable-Computing-Lab/Green-Algorithms-calculator)
website:

"""

The carbon footprint is calculated by estimating the energy draw of the
algorithm and the carbon intensity of producing this energy at a given
location:

\$\$carbon footprint = energy needed \* carbon intensity\$\$

Where the energy needed is:

\$\$runtime \* (power draw for cores \* usage + power draw for memory)
\* PUE \* PSF\$\$

The power draw for the computing cores depends on the model and number
of cores, while the memory power draw only depends on the size of memory
available. The usage factor corrects for the real core usage (default is
1, i.e. full usage). The PUE (Power Usage Effectiveness) measures how
much extra energy is needed to operate the data centre (cooling,
lighting etc.).

The PSF (Pragmatic Scaling Factor) is used to take into account multiple
identical runs (e.g. for testing or optimisation).

The Carbon Intensity depends on the location and the technologies used
to produce electricity. But note that the "energy needed" \[...\] is
independent of the location.

"""

## Usage

``` r
ga_footprint(
  runtime_h = NULL,
  location_code = "WORLD",
  PUE = 1.67,
  TDP_per_core = 12,
  n_cores = 1,
  cpu_model = "Any",
  memory_ram = NULL,
  power_draw_per_gb = 0.3725,
  PSF = 1,
  usage_core = 1,
  add_ref_values = TRUE,
  add_storage_estimation = FALSE,
  mass_storage = NULL,
  carbon_intensity = NULL,
  TDP_cpu = NULL,
  ref_value = NULL
)
```

## Arguments

- runtime_h:

  Runtime in hours (numeric). Use a positive number for explicit
  runtime, or "session" to automatically calculate based on current R
  session time using
  [`proc.time()`](https://rdrr.io/r/base/proc.time.html).

- location_code:

  Character string specifying geographical location for carbon
  intensity. Available options include country codes (e.g., "FR", "US",
  "CN") or "WORLD" for global average. See the Green Algorithms database
  for complete list of supported locations.

- PUE:

  Power Usage Effectiveness (numeric, default 1.67). Measures data
  center efficiency - how much extra energy is needed for cooling,
  lighting, etc. Use 1.05 for personal computers, 1.2-1.7 for data
  centers. See
  <https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/default_PUE.csv>

- TDP_per_core:

  Thermal Design Power per core in Watts (numeric, default 12). CPU
  power consumption per core. Find values at
  <https://www.techpowerup.com/cpu-specs/> or
  <https://calculator.green-algorithms.org/>. Overridden by `cpu_model`
  parameter.

- n_cores:

  Number of CPU cores (integer, default 1). Overridden by `cpu_model`
  parameter.

- cpu_model:

  Character string specifying exact CPU model. Must match entries in the
  Green Algorithms database. When specified, automatically sets
  `TDP_per_core` and `n_cores`. Use "Any" for generic calculation.

- memory_ram:

  RAM memory in GB (numeric). If NULL, attempts to detect automatically
  using
  [`benchmarkme::get_ram()`](https://rdrr.io/pkg/benchmarkme/man/get_ram.html).

- power_draw_per_gb:

  Power consumption per GB of RAM in Watts (numeric, default 0.3725).

- PSF:

  Pragmatic Scaling Factor (numeric, default 1). Accounts for multiple
  runs of the same computation. As noted by Lannelongue et al. (2021):
  "computations are rarely performed only once" - use values \> 1 to
  account for repeated runs, parameter sweeps, or iterative development.
  GHG emissions are multiplied."

- usage_core:

  (int, default 1). The usage factor corrects for the real core usage
  (default is 1, i.e. full usage).

- add_ref_values:

  (logical, default TRUE) Do we compute and return reference values to
  compare to your footprint ?

- add_storage_estimation:

  (logical, default FALSE) Do we compute the footprint of mass storage ?
  By default FALSE because it is far less important than cpu and memory
  usage. Note that
  [green-algorithms](https://github.com/GreenAlgorithms/) original tool
  do not compute mass storage usage.

- mass_storage:

  (int. in GB, default NULL) The size of the mass_storage. Only used if
  add_storage_estimation is set to TRUE. If set to NULL, use the
  [`base::gc()`](https://rdrr.io/r/base/gc.html) function to estimate
  storage used.

- carbon_intensity:

  (default NULL). Custom carbon intensity values. Note that only the
  value for the specified `location_code` will be used. Accepts three
  formats:

  - `NULL` (default): use the bundled Green Algorithms database
    (`carbon_intensity_internal`).

  - A single numeric value: carbon intensity in gCO2e/kWh, used directly
    regardless of `location_code`. Useful when you know your local CI
    from sources like the Electricity Maps API.

  - A named numeric vector: names are location codes, values are carbon
    intensities in gCO2e/kWh. These override matching entries in the
    bundled database and add new ones. For example,
    `c("FR" = 56, "CUSTOM_DC" = 450)`.

  - A data.frame with `location` and `carbonIntensity` columns: used
    as-is (original advanced-user behaviour).

- TDP_cpu:

  (default NULL). Advanced users only. A dataframe with `model`,
  `n_cores` and `TDP_per_core` columns. Set to TDP_cpu_internal if NULL.
  TDP_cpu_internal is set using command line
  csv_from_url_ga("https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/CPUs.csv")

- ref_value:

  (default NULL). Advanced users only. A dataframe with `variable` and
  `value` columns. Set to ref_value_internal if NULL. ref_value_internal
  is set using command line
  csv_from_url_ga("https://raw.githubusercontent.com/GreenAlgorithms/GA-data/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/referenceValues.csv")

## Value

A list of values

- `runtime_h`: the input run time in hours

- `location_code`: the input location code

- `TDP_per_core`: the input TDP_per_core (if cpu_model is set,
  correspond to the TDP_per_core for this cpu)

- `n_cores`: the input n_cores (if cpu_model is set, correspond to the
  n_cores for this cpu)

- `cpu_model`: the input cpu model. If set to "Any", TDP_per_core and
  ncore are used

- `memory_ram`: the input memory ram in GB

- `power_draw_per_gb`: the input power draw per GB

- `usage_core`: the input usage core

- `carbon_intensity`: the input carbon intensity (depend on location
  code)

- `PUE`: the input PUE

- `PSF`: the input PUE

- `power_draw_for_cores_kWh`: the output power draw for cores in kWh

- `power_draw_for_memory_kWh`: the output power draw for RAM memory in
  kWh

- `energy_needed_kWh`: the output energy needed in kWh

- `carbon_footprint_cores`: the output carbon footprint in grams of CO2
  for cores usage

- `carbon_footprint_memory`: the output carbon footprint in grams of CO2
  for memory usage

- `carbon_footprint_total_gCO2`: the total output carbon footprint in
  grams of CO2

- `ref_value`: (optionnal, return if add_ref_values is TRUE) : a
  dataframe

- `power_draw_storage_kWh`: (optionnal, return if add_storage_estimation
  is TRUE) the output power draw for mass storage in kWh

## Author

Adrien Taudière

## Examples

``` r
# Basic usage with explicit parameters
result <- ga_footprint(
  runtime_h = 2,
  n_cores = 4,
  TDP_per_core = 15,
  memory_ram = 16,
  location_code = "WORLD"
)
result$carbon_footprint_total_gCO2
#> [1] 104.6455

# Using specific CPU model (automatically sets cores and TDP)
ga_footprint(
  runtime_h = 1,
  cpu_model = "Core i5-9600KF",
  location_code = "FR"
)
#> $runtime_h
#> [1] 1
#> 
#> $location_code
#> [1] "FR"
#> 
#> $TDP_per_core
#> [1] 15.8
#> 
#> $n_cores
#> [1] 6
#> 
#> $cpu_model
#> [1] "Core i5-9600KF"
#> 
#> $memory_ram
#> [1] 16.77076
#> 
#> $power_draw_per_gb
#> [1] 0.3725
#> 
#> $`usage core`
#> [1] 1
#> 
#> $carbon_intensity
#> [1] 51.28
#> 
#> $PUE
#> [1] 1.67
#> 
#> $PSF
#> [1] 1
#> 
#> $power_draw_for_cores_kWh
#> [1] 0.158316
#> 
#> $power_draw_for_memory_kWh
#> [1] 0.01043267
#> 
#> $energy_needed_kWh
#> [1] 0.1687487
#> 
#> $carbon_footprint_cores
#> [1] 8.118444
#> 
#> $carbon_footprint_memory
#> [1] 0.5349872
#> 
#> $carbon_footprint_total_gCO2
#> [1] 8.653432
#> 
#> $ref_value
#>                     variable              value
#> 1                      Total   8.65343171641974
#> 2                      Cores           0.158316
#> 3                     Memory 0.0104326684169216
#> 4                memoryPower             0.3725
#> 5              google_search                 10
#> 6  streaming_netflix_perhour                 36
#> 7                train_perkm                 41
#> 8       flight_economy_perkm                171
#> 9      passengerCar_EU_perkm                175
#> 10     passengerCar_US_perkm                251
#> 11                tree_month                917
#> 12                  treeYear              11000
#> 13            flight_PAR-LON              50000
#> 14            flight_PAR-DUB             110000
#> 15              flight_NY-SF             570000
#> 16            flight_NYC-MEL            2310000
#>                                                                                                                                                                                source
#> 1                                                                                                                                                                                <NA>
#> 2                                                                                                                                                                                <NA>
#> 3                                                                                                                                                                                <NA>
#> 4                         in W/GB from http://dl.acm.org/citation.cfm?doid=3076113.3076117 and https://www.tomshardware.com/uk/reviews/intel-core-i7-5960x-haswell-e-cpu,3918-13.html
#> 5                                                                                                                           gCO2 from http://www.janavirgin.com/CO2/CO2GLE_about.html
#> 6                                                                 gCO2 from https://www.carbonbrief.org/factcheck-what-is-the-carbon-footprint-of-streaming-video-on-netflix (update)
#> 7                                                   in gCO2/km, but more like 5-37g, from https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2020
#> 8                                                in gCO2/km, but more like 139-244g, from https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2020
#> 9  in gCO2/km from http://www.sciencedirect.com/science/article/pii/S1352231018307295 and https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2019
#> 10                                                                               in gCO2/km from https://www.epa.gov/greenvehicles/greenhouse-gas-emissions-typical-passenger-vehicle
#> 11                                                                                                                                                       gCO2 same source as treeYear
#> 12                                                                                          in gCO2/tree/year from http://www.sciencedirect.com/science/article/pii/S0269749101002640
#> 13                                                                                                            gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#> 14                                                                                                            gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#> 15                                                                                                            gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#> 16                                                                                                            gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#>    prop_footprint
#> 1    1.000000e+00
#> 2    1.829517e-02
#> 3    1.205611e-03
#> 4    4.304651e-02
#> 5    1.155611e+00
#> 6    4.160199e+00
#> 7    4.738005e+00
#> 8    1.976095e+01
#> 9    2.022319e+01
#> 10   2.900583e+01
#> 11   1.059695e+02
#> 12   1.271172e+03
#> 13   5.778054e+03
#> 14   1.271172e+04
#> 15   6.586982e+04
#> 16   2.669461e+05
#> 

# Calculate footprint for current R session
ga_footprint(runtime_h = "session")
#> $runtime_h
#> user.self 
#> 0.0027225 
#> 
#> $location_code
#> [1] "WORLD"
#> 
#> $TDP_per_core
#> [1] 12
#> 
#> $n_cores
#> [1] 1
#> 
#> $cpu_model
#> [1] "Any"
#> 
#> $memory_ram
#> [1] 16.77076
#> 
#> $power_draw_per_gb
#> [1] 0.3725
#> 
#> $`usage core`
#> [1] 1
#> 
#> $carbon_intensity
#> [1] 475
#> 
#> $PUE
#> [1] 1.67
#> 
#> $PSF
#> [1] 1
#> 
#> $power_draw_for_cores_kWh
#>   user.self 
#> 5.45589e-05 
#> 
#> $power_draw_for_memory_kWh
#>    user.self 
#> 2.840294e-05 
#> 
#> $energy_needed_kWh
#>    user.self 
#> 8.296184e-05 
#> 
#> $carbon_footprint_cores
#>  user.self 
#> 0.02591548 
#> 
#> $carbon_footprint_memory
#> user.self 
#> 0.0134914 
#> 
#> $carbon_footprint_total_gCO2
#>  user.self 
#> 0.03940687 
#> 
#> $ref_value
#>                     variable                value
#> 1                      Total   0.0394068738884078
#> 2                      Cores          5.45589e-05
#> 3                     Memory 2.84029397650691e-05
#> 4                memoryPower               0.3725
#> 5              google_search                   10
#> 6  streaming_netflix_perhour                   36
#> 7                train_perkm                   41
#> 8       flight_economy_perkm                  171
#> 9      passengerCar_EU_perkm                  175
#> 10     passengerCar_US_perkm                  251
#> 11                tree_month                  917
#> 12                  treeYear                11000
#> 13            flight_PAR-LON                50000
#> 14            flight_PAR-DUB               110000
#> 15              flight_NY-SF               570000
#> 16            flight_NYC-MEL              2310000
#>                                                                                                                                                                                source
#> 1                                                                                                                                                                                <NA>
#> 2                                                                                                                                                                                <NA>
#> 3                                                                                                                                                                                <NA>
#> 4                         in W/GB from http://dl.acm.org/citation.cfm?doid=3076113.3076117 and https://www.tomshardware.com/uk/reviews/intel-core-i7-5960x-haswell-e-cpu,3918-13.html
#> 5                                                                                                                           gCO2 from http://www.janavirgin.com/CO2/CO2GLE_about.html
#> 6                                                                 gCO2 from https://www.carbonbrief.org/factcheck-what-is-the-carbon-footprint-of-streaming-video-on-netflix (update)
#> 7                                                   in gCO2/km, but more like 5-37g, from https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2020
#> 8                                                in gCO2/km, but more like 139-244g, from https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2020
#> 9  in gCO2/km from http://www.sciencedirect.com/science/article/pii/S1352231018307295 and https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2019
#> 10                                                                               in gCO2/km from https://www.epa.gov/greenvehicles/greenhouse-gas-emissions-typical-passenger-vehicle
#> 11                                                                                                                                                       gCO2 same source as treeYear
#> 12                                                                                          in gCO2/tree/year from http://www.sciencedirect.com/science/article/pii/S0269749101002640
#> 13                                                                                                            gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#> 14                                                                                                            gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#> 15                                                                                                            gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#> 16                                                                                                            gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#>    prop_footprint
#> 1    1.000000e+00
#> 2    1.384502e-03
#> 3    7.207610e-04
#> 4    9.452666e+00
#> 5    2.537628e+02
#> 6    9.135462e+02
#> 7    1.040428e+03
#> 8    4.339344e+03
#> 9    4.440850e+03
#> 10   6.369447e+03
#> 11   2.327005e+04
#> 12   2.791391e+05
#> 13   1.268814e+06
#> 14   2.791391e+06
#> 15   1.446448e+07
#> 16   5.861921e+07
#> 

# Compare different locations
locations <- c("WORLD", "FR", "US", "NO")
sapply(locations, function(loc) {
  ga_footprint(runtime_h = 1, location_code = loc)$carbon_footprint_total_gCO2
})
#>      WORLD         FR         US         NO 
#> 14.4745175  1.5626384 12.9185830  0.2322017 

# Use a custom carbon intensity value (e.g. from Electricity Maps API)
ga_footprint(runtime_h = 2, carbon_intensity = 42)$carbon_footprint_total_gCO2
#> [1] 2.559704

# Override specific locations with custom CI values
ga_footprint(
  runtime_h = 2,
  location_code = "FR",
  carbon_intensity = c("FR" = 56, "CUSTOM_DC" = 450)
)$carbon_footprint_total_gCO2
#> [1] 3.412939

# Advanced usage with storage estimation and reference values
res_ga <- ga_footprint(
  runtime_h = 4,
  n_cores = 8,
  memory_ram = 32,
  add_storage_estimation = TRUE,
  add_ref_values = TRUE
)

library(ggplot2)
ggplot(res_ga$ref_value, aes(y = variable, x = as.numeric(value), fill = log10(prop_footprint))) +
  geom_col() +
  geom_col(data = data.frame(
    variable = "Total",
    value = res_ga$carbon_footprint_total_gCO2
  ), fill = "grey30") +
  geom_col(data = data.frame(
    variable = "Cores",
    value = res_ga$carbon_footprint_cores
  ), fill = "darkred") +
  geom_col(data = data.frame(
    variable = "Memory",
    value = res_ga$carbon_footprint_memory
  ), fill = "orange") +
  geom_col(data = data.frame(
    variable = "Mass storage",
    value = res_ga$carbon_footprint_storage
  ), fill = "violet") +
  scale_x_continuous(
    trans = "log1p",
    breaks = c(0, 10^c(1:max(log1p(as.numeric(res_ga$ref_value$value)))))
  ) +
  geom_vline(
    xintercept = res_ga$carbon_footprint_total_gCO2,
    col = "grey30", lwd = 1.2
  ) +
  geom_label(aes(label = round_conditionaly(prop_footprint)),
    fill = "grey90", position = position_stack(vjust = 1.1)
  ) +
  labs(
    title = "Carbon footprint of the analysis",
    subtitle = paste0(
      "(", res_ga$carbon_footprint_total_gCO2,
      " g CO2", ")"
    ),
    caption = "Please cite Lannelongue et al. 2021 (10.1002/advs.202100707)"
  ) +
  xlab("Carbon footprint (g CO2) in log10") +
  ylab("Modality") +
  theme(legend.position = "none")
```
