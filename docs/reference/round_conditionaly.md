# Conditionally round numeric values based on magnitude

[![lifecycle-experimental](https://img.shields.io/badge/lifecycle-experimental-orange)](https://adrientaudiere.github.io/MiscMetabar/articles/Rules.html#lifecycle)

Applies different rounding rules based on the magnitude of values.
Larger values are rounded to fewer decimal places, while smaller values
retain more precision. This is useful for presenting results with
appropriate precision across different scales.

## Usage

``` r
round_conditionaly(
  vec,
  cond = cbind(c(1e-05, 5), c(0.001, 3), c(0.01, 3), c(1, 2), c(10, 1), c(100, 0))
)
```

## Arguments

- vec:

  A numeric vector to be rounded

- cond:

  A matrix with 2 rows and n columns where:

  - First row: threshold values for applying rounding rules

  - Second row: number of decimal places to round to

  The function automatically sorts conditions in decreasing order of
  thresholds. Default provides reasonable rounding for most carbon
  footprint values.

## Value

A numeric vector of the same length as `vec` with values rounded
according to the conditional rules

## Author

Adrien Taudière

## Examples

``` r
# Default rounding behavior
values <- c(1000.27890, 10.87988, 1.769869, 0.99796, 0.000179)
round_conditionaly(values)
#> [1] 1000.27890   10.87988    1.76987    0.99796    0.00018

# Custom rounding rules
custom_rules <- cbind(c(10e-5, 5), c(10, 2)) # 5 decimals for tiny values, 2 for others
round_conditionaly(c(1000.27890, 0.000179, 10e-11), cond = custom_rules)
#> [1] 1.000279e+03 1.800000e-04 1.000000e-10

# Useful for carbon footprint reporting
footprint_values <- c(0.001234, 1.23456, 123.456, 12345.6)
round_conditionaly(footprint_values)
#> [1]     0.00123     1.23456   123.45600 12345.60000
```
