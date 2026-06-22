# greenAlgoR 0.1.2
* `ga_footprint()` gains flexible `carbon_intensity` input: in addition to the existing data.frame format, the parameter now accepts a single numeric value (used directly as gCO2e/kWh regardless of `location_code`) or a named numeric vector (overrides/adds entries to the bundled database). This makes it easy to plug in custom carbon-intensity values from sources like the Electricity Maps API.

# greenAlgoR 0.1.2

- Improve documentation
- Create two vignettes: "Introduction to greenAlgoR" and "Targets integration"
- Correct url to v3 of greenalgorithm and update internal data in sysdata.rda

# greenAlgoR 0.1.1
* Remove the useless argument `fields` from `ga_targets()`

# greenAlgoR 0.1

* Initial github submission.
* Creation of function `ga_footprint()` and `ga_targets()`
