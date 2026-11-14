## Build R/sysdata.rda from the Green Algorithms data v3.1, the version used by
## the Green Algorithms calculator v3.1 (`CURRENT_VERSION` in its
## utils/handle_inputs.py). Run from the package root:
##   Rscript data-raw/sysdata.R
## Columns are kept as character, as csv_from_url_ga() returns them.

ga_data_commit <- "0a1d169b22af38e020fadc5c61409030a8d086ca"
base_url <- paste0(
  "https://raw.githubusercontent.com/Cambridge-Sustainable-Computing-Lab/",
  "Green-Algorithms-data/",
  ga_data_commit,
  "/v3.1/"
)
read_ga <- function(file, skip = 0) {
  read.csv(
    paste0(base_url, file),
    skip = skip,
    check.names = FALSE,
    colClasses = "character",
    encoding = "UTF-8"
  )
}

## CPUs: the calculator reads chips/manual/CPUs-manual.csv (first line is units)
cpu <- read_ga("chips/manual/CPUs-manual.csv", skip = 1)
TDP_cpu_internal <- data.frame(
  model = cpu$model,
  Manufacturer = cpu$Manufacturer,
  TDP = cpu$TDP,
  n_cores = cpu$n_cores,
  TDP_per_core = as.character(as.numeric(cpu$TDP) / as.numeric(cpu$n_cores)),
  Release_year = cpu$Release_year,
  die_area = cpu$die_area,
  source = cpu$source
)

## Carbon intensity: Electricity Maps 2024, life-cycle values, with the column
## mapping and region normalisation of the calculator's utils/CI_data_config.yml
ci <- read_ga(
  "carbon-intensity/electricitymap/CI-electricitymap-yearly_2024-with-continents.csv"
)
ci_col <- grep("Life cycle", names(ci), value = TRUE)
stopifnot(length(ci_col) == 1, !anyDuplicated(ci[["Zone id"]]))
region <- ci[["Zone name"]]
region[region == ci$Country] <- "Any"
carbon_intensity_internal <- data.frame(
  location = ci[["Zone id"]],
  continentName = ci$Continent,
  countryName = ci$Country,
  regionName = region,
  carbonIntensity = ci[[ci_col]],
  source = "Electricity Maps 2024, life cycle",
  comments = ""
)
## Electricity Maps has no world value; 475 gCO2e/kWh is the world average the
## calculator uses as its default carbon intensity.
carbon_intensity_internal <- rbind(
  data.frame(
    location = "WORLD",
    continentName = "World",
    countryName = "Any",
    regionName = "Any",
    carbonIntensity = "475",
    source = "https://www.iea.org/reports/global-energy-co2-status-report-2019/emissions",
    comments = "Data from 2019"
  ),
  carbon_intensity_internal
)

## Reference values in gCO2e (PB_ADP_per_capita is in kgSb e, so it is dropped)
ref_value_internal <- read_ga("context.csv")
ref_value_internal <- ref_value_internal[
  ref_value_internal$variable != "PB_ADP_per_capita",
]
rownames(ref_value_internal) <- NULL

usethis::use_data(
  TDP_cpu_internal,
  carbon_intensity_internal,
  ref_value_internal,
  internal = TRUE,
  overwrite = TRUE
)
