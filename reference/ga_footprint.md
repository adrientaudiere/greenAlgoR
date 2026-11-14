# Compute footprint in grams of CO2 using the Green Algorithms method

Implements the Green Algorithms method of Lannelongue et al. (2021)
([doi:10.1002/advs.202100707](https://doi.org/10.1002/advs.202100707) ).
[![lifecycle-experimental](https://img.shields.io/badge/lifecycle-experimental-orange)](https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle)

Please cite Lannelongue, L., Grealey, J., Inouye, M., Green Algorithms:
Quantifying the Carbon Footprint of Computation. Adv. Sci. 2021,
2100707.
[doi:10.1002/advs.202100707](https://doi.org/10.1002/advs.202100707)

Default values are those of the Green Algorithms calculator v3.1
(https://github.com/Cambridge-Sustainable-Computing-Lab/Green-Algorithms-calculator),
from the Green Algorithms data v3.1:

- PUE:
  https://raw.githubusercontent.com/Cambridge-Sustainable-Computing-Lab/Green-Algorithms-data/0a1d169b22af38e020fadc5c61409030a8d086ca/v3.1/data-centres/default-PUE_2024.csv

- TDP_per_core: the "Average" CPU of
  https://raw.githubusercontent.com/Cambridge-Sustainable-Computing-Lab/Green-Algorithms-data/0a1d169b22af38e020fadc5c61409030a8d086ca/v3.1/chips/manual/CPUs-manual.csv

- power_draw_per_gb:
  https://raw.githubusercontent.com/Cambridge-Sustainable-Computing-Lab/Green-Algorithms-data/0a1d169b22af38e020fadc5c61409030a8d086ca/v3.1/hardware-impacts.csv

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
  platform = "auto",
  PUE = NULL,
  TDP_per_core = 7.46,
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
  intensity: an Electricity Maps zone code (e.g. "FR", "US", "CN",
  "NO-NO1", "US-NW-PGE") or "WORLD" for the world average. The list is
  in the `location` column of `carbon_intensity_internal`.

- platform:

  Type of machine the computation runs on: `"auto"` (default),
  `"laptop"`, `"desktop"`, `"local_server"` or `"cloud"`. It sets the
  PUE as the Green Algorithms calculator does when `PUE` is `NULL`: 1
  for a laptop or a desktop computer (no data centre), 1.56 for a local
  server or the cloud. `"auto"` detects the type from the chassis type
  of the machine (Linux, Windows), its battery (macOS) or the name of a
  cloud virtual machine (Linux); when detection fails, the platform is
  `"unknown"`, the PUE is 1.56 and a message says so.

- PUE:

  Power Usage Effectiveness (numeric, default `NULL`: set from
  `platform`). Measures data centre efficiency - how much extra energy
  is needed for cooling, lighting, etc. 1.56 is the value the Green
  Algorithms calculator uses for an unknown data centre, see
  <https://raw.githubusercontent.com/Cambridge-Sustainable-Computing-Lab/Green-Algorithms-data/0a1d169b22af38e020fadc5c61409030a8d086ca/v3.1/data-centres/default-PUE_2024.csv>

- TDP_per_core:

  Thermal Design Power per core in Watts (numeric, default 7.46, the
  "Average" CPU of the Green Algorithms data). CPU power consumption per
  core. Find values at <https://www.techpowerup.com/cpu-specs/> or
  <https://calculator.green-algorithms.org/>. Overridden by `cpu_model`
  parameter.

- n_cores:

  Number of CPU cores (integer, default 1). Overridden by `cpu_model`
  parameter.

- cpu_model:

  Character string specifying the CPU model, as written in the `model`
  column of `TDP_cpu_internal`, or a longer name that contains it (the
  longest model name found in it is used). When specified, automatically
  sets `TDP_per_core` and `n_cores`. Use "Any" to use `TDP_per_core` and
  `n_cores` instead.

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
  TDP_cpu_internal is built from the file chips/manual/CPUs-manual.csv
  of the Green Algorithms data v3.1 (see
  [greenAlgoR-package](https://adrientaudiere.github.io/greenAlgoR/reference/greenAlgoR-package.md)).

- ref_value:

  (default NULL). Advanced users only. A dataframe with `variable` and
  `value` columns. Set to ref_value_internal if NULL. ref_value_internal
  is built from the file context.csv of the Green Algorithms data v3.1
  (see
  [greenAlgoR-package](https://adrientaudiere.github.io/greenAlgoR/reference/greenAlgoR-package.md)).

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

- `platform`: the platform type used (detected if `platform = "auto"`)

- `PUE`: the PUE used (set from `platform` if `PUE` is `NULL`)

- `PSF`: the input PSF

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
#> [1] 97.75272

# Using specific CPU model (automatically sets cores and TDP)
ga_footprint(
  runtime_h = 1,
  cpu_model = "Core i5-13400",
  location_code = "FR"
)
#> $runtime_h
#> [1] 1
#> 
#> $location_code
#> [1] "FR"
#> 
#> $TDP_per_core
#> [1] 6.5
#> 
#> $n_cores
#> [1] 10
#> 
#> $cpu_model
#> [1] "Core i5-13400"
#> 
#> $memory_ram
#> [1] 16.75944
#> 
#> $power_draw_per_gb
#> [1] 0.3725
#> 
#> $`usage core`
#> [1] 1
#> 
#> $carbon_intensity
#> [1] 33.44
#> 
#> $platform
#> [1] "cloud"
#> 
#> $PUE
#> [1] 1.56
#> 
#> $PSF
#> [1] 1
#> 
#> $power_draw_for_cores_kWh
#> [1] 0.1014
#> 
#> $power_draw_for_memory_kWh
#> [1] 0.00973891
#> 
#> $energy_needed_kWh
#> [1] 0.1111389
#> 
#> $carbon_footprint_cores
#> [1] 3.390816
#> 
#> $carbon_footprint_memory
#> [1] 0.3256692
#> 
#> $carbon_footprint_total_gCO2
#> [1] 3.716485
#> 
#> $ref_value
#>                     variable            value
#> 1                      Total 3.71648515749249
#> 2                      Cores         3.390816
#> 3                     Memory 0.32566915749249
#> 4              google_search               10
#> 5                train_perkm               41
#> 6  streaming_netflix_perhour               55
#> 7       flight_economy_perkm              171
#> 8      passengerCar_EU_perkm              175
#> 9      passengerCar_US_perkm              251
#> 10                tree_month              917
#> 11                  treeYear            11000
#> 12            flight_PAR-LON            50000
#> 13            flight_PAR-DUB           110000
#> 14              flight_NY-SF           570000
#> 15         PB_GWP_per_capita           985000
#> 16            flight_NYC-MEL          2310000
#>                                                                                                                                                                                               source
#> 1                                                                                                                                                                                               <NA>
#> 2                                                                                                                                                                                               <NA>
#> 3                                                                                                                                                                                               <NA>
#> 4                                                                                                                                          gCO2 from http://www.janavirgin.com/CO2/CO2GLE_about.html
#> 5                                                                  in gCO2/km, but more like 5-37g, from https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2020
#> 6                                                                                                          gCO2 from https://www.carbontrust.com/resources/carbon-impact-of-video-streaming (update)
#> 7                                                               in gCO2/km, but more like 139-244g, from https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2020
#> 8                 in gCO2/km from http://www.sciencedirect.com/science/article/pii/S1352231018307295 and https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2019
#> 9                                                                                               in gCO2/km from https://www.epa.gov/greenvehicles/greenhouse-gas-emissions-typical-passenger-vehicle
#> 10                                                                                                                                                                      gCO2 same source as treeYear
#> 11                                                                                                         in gCO2/tree/year from http://www.sciencedirect.com/science/article/pii/S0269749101002640
#> 12                                                                                                                           gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#> 13                                                                                                                           gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#> 14                                                                                                                           gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#> 15 gCO2e/year/person from Sala et al. (2020) "Environmental sustanability of European production and consumption assessed against panetary boundaries" https://doi.org/10.1016/j.jenvman.2020.110686
#> 16                                                                                                                           gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#>    prop_footprint
#> 1    1.000000e+00
#> 2    9.123717e-01
#> 3    8.762827e-02
#> 4    2.690714e+00
#> 5    1.103193e+01
#> 6    1.479893e+01
#> 7    4.601122e+01
#> 8    4.708750e+01
#> 9    6.753693e+01
#> 10   2.467385e+02
#> 11   2.959786e+03
#> 12   1.345357e+04
#> 13   2.959786e+04
#> 14   1.533707e+05
#> 15   2.650354e+05
#> 16   6.215550e+05
#> 

# Calculate footprint for current R session
ga_footprint(runtime_h = "session")
#> $runtime_h
#>   user.self 
#> 0.002165556 
#> 
#> $location_code
#> [1] "WORLD"
#> 
#> $TDP_per_core
#> [1] 7.46
#> 
#> $n_cores
#> [1] 1
#> 
#> $cpu_model
#> [1] "Any"
#> 
#> $memory_ram
#> [1] 16.75944
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
#> $platform
#> [1] "cloud"
#> 
#> $PUE
#> [1] 1.56
#> 
#> $PSF
#> [1] 1
#> 
#> $power_draw_for_cores_kWh
#>    user.self 
#> 2.520187e-05 
#> 
#> $power_draw_for_memory_kWh
#>    user.self 
#> 2.109015e-05 
#> 
#> $energy_needed_kWh
#>    user.self 
#> 4.629202e-05 
#> 
#> $carbon_footprint_cores
#>  user.self 
#> 0.01197089 
#> 
#> $carbon_footprint_memory
#>  user.self 
#> 0.01001782 
#> 
#> $carbon_footprint_total_gCO2
#>  user.self 
#> 0.02198871 
#> 
#> $ref_value
#>                     variable              value
#> 1                      Total 0.0219887097128924
#> 2                      Cores 0.0119708879333333
#> 3                     Memory 0.0100178217795591
#> 4              google_search                 10
#> 5                train_perkm                 41
#> 6  streaming_netflix_perhour                 55
#> 7       flight_economy_perkm                171
#> 8      passengerCar_EU_perkm                175
#> 9      passengerCar_US_perkm                251
#> 10                tree_month                917
#> 11                  treeYear              11000
#> 12            flight_PAR-LON              50000
#> 13            flight_PAR-DUB             110000
#> 14              flight_NY-SF             570000
#> 15         PB_GWP_per_capita             985000
#> 16            flight_NYC-MEL            2310000
#>                                                                                                                                                                                               source
#> 1                                                                                                                                                                                               <NA>
#> 2                                                                                                                                                                                               <NA>
#> 3                                                                                                                                                                                               <NA>
#> 4                                                                                                                                          gCO2 from http://www.janavirgin.com/CO2/CO2GLE_about.html
#> 5                                                                  in gCO2/km, but more like 5-37g, from https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2020
#> 6                                                                                                          gCO2 from https://www.carbontrust.com/resources/carbon-impact-of-video-streaming (update)
#> 7                                                               in gCO2/km, but more like 139-244g, from https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2020
#> 8                 in gCO2/km from http://www.sciencedirect.com/science/article/pii/S1352231018307295 and https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2019
#> 9                                                                                               in gCO2/km from https://www.epa.gov/greenvehicles/greenhouse-gas-emissions-typical-passenger-vehicle
#> 10                                                                                                                                                                      gCO2 same source as treeYear
#> 11                                                                                                         in gCO2/tree/year from http://www.sciencedirect.com/science/article/pii/S0269749101002640
#> 12                                                                                                                           gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#> 13                                                                                                                           gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#> 14                                                                                                                           gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#> 15 gCO2e/year/person from Sala et al. (2020) "Environmental sustanability of European production and consumption assessed against panetary boundaries" https://doi.org/10.1016/j.jenvman.2020.110686
#> 16                                                                                                                           gCO2e from https://calculator.carbonfootprint.com/calculator.aspx?tab=3
#>    prop_footprint
#> 1    1.000000e+00
#> 2    5.444107e-01
#> 3    4.555893e-01
#> 4    4.547788e+02
#> 5    1.864593e+03
#> 6    2.501284e+03
#> 7    7.776718e+03
#> 8    7.958630e+03
#> 9    1.141495e+04
#> 10   4.170322e+04
#> 11   5.002567e+05
#> 12   2.273894e+06
#> 13   5.002567e+06
#> 14   2.592239e+07
#> 15   4.479572e+07
#> 16   1.050539e+08
#> 

# Compare different locations
locations <- c("WORLD", "FR", "US", "NO")
sapply(locations, function(loc) {
  ga_footprint(runtime_h = 1, location_code = loc)$carbon_footprint_total_gCO2
})
#>      WORLD         FR         US         NO 
#> 10.1538424  0.7148305  8.5548794  0.7116240 

# Use a custom carbon intensity value (e.g. from Electricity Maps API)
ga_footprint(runtime_h = 2, carbon_intensity = 42)$carbon_footprint_total_gCO2
#> [1] 1.795627

# Override specific locations with custom CI values
ga_footprint(
  runtime_h = 2,
  location_code = "FR",
  carbon_intensity = c("FR" = 56, "CUSTOM_DC" = 450)
)$carbon_footprint_total_gCO2
#> [1] 2.394169

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
