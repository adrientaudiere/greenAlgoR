## Platform types of the Green Algorithms calculator v3.1 and their PUE:
## 1 for a personal computer, the "unknown data centre" value otherwise.
platform_pue <- c(laptop = 1, desktop = 1, local_server = 1.56, cloud = 1.56)

## Session cache of detect_platform(), which may call a system command
the <- new.env(parent = emptyenv())

## Map an SMBIOS chassis type code (DMTF DSP0134) to a platform type
platform_from_chassis <- function(code) {
  code <- suppressWarnings(as.integer(code[1]))
  if (is.na(code)) {
    return(NA_character_)
  }
  if (code %in% c(8:11, 14, 30:32)) {
    return("laptop")
  }
  if (code %in% c(3:7, 13, 15, 16, 24, 34:36)) {
    return("desktop")
  }
  if (code %in% c(17, 23, 25, 28, 29)) {
    return("local_server")
  }
  NA_character_
}

## Linux: cloud VMs are recognised from their DMI vendor and product names,
## then the chassis type decides.
platform_linux <- function(dmi_dir = "/sys/class/dmi/id") {
  read_dmi <- function(f) {
    path <- file.path(dmi_dir, f)
    if (!file.exists(path)) {
      return("")
    }
    tryCatch(readLines(path, n = 1, warn = FALSE), error = \(e) "")
  }
  vendor_product <- paste(read_dmi("sys_vendor"), read_dmi("product_name"))
  if (grepl("Amazon EC2|Google Compute Engine|OpenStack", vendor_product)) {
    return("cloud")
  }
  if (grepl("Microsoft Corporation Virtual Machine", vendor_product)) {
    return("cloud")
  }
  platform_from_chassis(read_dmi("chassis_type"))
}

run_quiet <- function(cmd, args) {
  out <- tryCatch(
    suppressWarnings(system2(
      cmd,
      args,
      stdout = TRUE,
      stderr = FALSE,
      timeout = 10
    )),
    error = \(e) character(0)
  )
  if (!is.null(attr(out, "status"))) {
    return(character(0))
  }
  out
}

## macOS: recent models all report "MacXX,Y" as hw.model, so the battery is
## the reliable sign of a laptop.
platform_macos <- function() {
  batt <- run_quiet("pmset", c("-g", "batt"))
  if (length(batt) == 0) {
    return(NA_character_)
  }
  if (any(grepl("InternalBattery", batt))) {
    "laptop"
  } else {
    "desktop"
  }
}

platform_windows <- function() {
  out <- run_quiet(
    "powershell",
    c(
      "-NoProfile",
      "-Command",
      "(Get-CimInstance Win32_SystemEnclosure).ChassisTypes"
    )
  )
  platform_from_chassis(trimws(out))
}

## Detect the platform type of the current machine, or "unknown"
detect_platform <- function() {
  if (!is.null(the$platform)) {
    return(the$platform)
  }
  sysname <- Sys.info()[["sysname"]]
  platform <- switch(
    sysname,
    Linux = platform_linux(),
    Darwin = platform_macos(),
    Windows = platform_windows(),
    NA_character_
  )
  if (is.na(platform)) {
    platform <- "unknown"
  }
  the$platform <- platform
  platform
}
