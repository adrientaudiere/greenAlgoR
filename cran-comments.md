## First submission

This is a first submission to CRAN.

## R CMD check results

0 errors | 0 warnings | 1 note

* "New submission", and "Version contains large components (0.3.0.9000)"
  on the development version; the latter disappears with the release
  version 0.3.0.

## Test environments

* local Linux (Pop!_OS 24.04), R 4.6.1, `R CMD check --as-cran --run-donttest`
  (2026-10-22, 129 s in total).

## Examples

* `csv_from_url_ga()` downloads a file, so its example runs only in
  interactive sessions (`@examplesIf interactive()`).
* `ga_targets()` runs a small 'targets' pipeline inside
  `targets::tar_dir()`, i.e. in a temporary directory.

## Method References

The package implements the methodology from:
Lannelongue, L., Grealey, J., Inouye, M. (2021). Green Algorithms:
Quantifying the Carbon Footprint of Computation. Advanced Science, 8(12), 2100707.
<doi:10.1002/advs.202100707>
