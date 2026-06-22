# Load CSV files from Green Algorithms GitHub repositories

[![lifecycle-experimental](https://img.shields.io/badge/lifecycle-experimental-orange)](https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle)

Helper function to download and parse CSV data from the Green Algorithms
project repositories. This function handles the specific format used by
Green Algorithms data files, which often have headers in specific rows.

## Usage

``` r
csv_from_url_ga(url, remove_first_line = TRUE)
```

## Arguments

- url:

  Character string with URL to a raw CSV file from Green Algorithms
  repository

- remove_first_line:

  Logical (default TRUE). Whether to remove the first line from the CSV
  file (often contains metadata rather than column headers).

## Value

A data.frame with properly formatted column names and data

## Author

Adrien Taudière

## Examples

``` r
if (FALSE) { # \dontrun{
# Download carbon intensity data
carbon_intensity <- csv_from_url_ga(
  paste0(
    "https://raw.githubusercontent.com/GreenAlgorithms/GA-data",
    "/5266caba6601dae0ffc93af8971e758f55292e08/v3.0/CI_aggregated.csv"
  )
)
head(carbon_intensity)
} # }
```
