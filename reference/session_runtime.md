# Compute session runtime and memory usage statistics

[![lifecycle-experimental](https://img.shields.io/badge/lifecycle-experimental-orange)](https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle)

Analyzes the current R session to extract timing and memory usage
information. This function is particularly useful for understanding
resource consumption patterns and can be used with
`ga_footprint(runtime_h = "session")`.

The function uses
[`base::proc.time()`](https://rdrr.io/r/base/proc.time.html) to get CPU
timing information and [`base::gc()`](https://rdrr.io/r/base/gc.html) to
estimate memory usage when requested.

## Usage

``` r
session_runtime(compute_mass_storage = TRUE)
```

## Arguments

- compute_mass_storage:

  Logical (default TRUE). Whether to compute memory usage statistics
  using the [`base::gc()`](https://rdrr.io/r/base/gc.html) function. Set
  to FALSE if you only need timing information.

## Value

A list containing:

- `cpu_times_users`: User CPU time in seconds

- `cpu_times_system`: System CPU time in seconds

- `time_elapsed`: Total elapsed time in seconds

- `cpu_times`: Combined user and system CPU time

- `mass_storage_used`: Memory currently used (if requested)

- `mass_storage_max`: Maximum memory used (if requested)

## Author

Adrien Taudière

## Examples

``` r
# Get complete session information
session_info <- session_runtime()
print(session_info)
#> $cpu_times_users
#> user.self 
#>    12.486 
#> 
#> $cpu_times_system
#> user.child 
#>      5.936 
#> 
#> $time_elapsed
#> elapsed 
#>  21.223 
#> 
#> $cpu_times
#> user.self 
#>    18.422 
#> 
#> $mass_storage_used
#> [1] 271.9
#> 
#> $mass_storage_max
#> [1] 397.7
#> 

# Get only timing information (faster)
timing_only <- session_runtime(compute_mass_storage = FALSE)
cat("Session has been running for", timing_only$time_elapsed, "seconds\n")
#> Session has been running for 21.729 seconds
```
