#' \code{greenAlgoR} package
#'
#' @description 
#' \strong{Carbon Footprint Estimation for R Computations}
#' 
#' The \code{greenAlgoR} package provides tools to estimate the carbon footprint 
#' and energy consumption of computational tasks in R. Based on the Green Algorithms 
#' framework developed by Lannelongue et al. (2021), this package helps researchers 
#' and data scientists understand and minimize the environmental impact of their work.
#' 
#' @section Main Functions:
#' \itemize{
#'   \item \code{\link{ga_footprint}}: Calculate carbon footprint for individual computations
#'   \item \code{\link{ga_targets}}: Calculate carbon footprint for targets pipelines
#'   \item \code{\link{session_runtime}}: Compute session runtime and memory usage
#' }
#' 
#' @section Key Features:
#' \itemize{
#'   \item Estimate CO2 emissions based on runtime, CPU usage, and memory consumption
#'   \item Support for different geographical locations with varying carbon intensities
#'   \item Integration with the \code{targets} package for pipeline analysis
#'   \item Visualization tools for carbon footprint comparisons
#'   \item Configurable hardware specifications (CPU models, memory, storage)
#' }
#' 
#' @section Getting Started:
#' To get started with \code{greenAlgoR}, try:
#' \preformatted{
#' # Basic usage - estimate footprint of a 12-hour computation
#' result <- ga_footprint(runtime_h = 12, location_code = "WORLD")
#' 
#' # For your current R session
#' session_footprint <- ga_footprint(runtime_h = "session")
#' 
#' # For targets pipelines (in a targets project)
#' targets_footprint <- ga_targets()
#' }
#' 
#' @references 
#' Lannelongue, L., Grealey, J., Inouye, M. (2021). 
#' Green Algorithms: Quantifying the Carbon Footprint of Computation. 
#' \emph{Advanced Science}, 8(12), 2100707. 
#' \doi{10.1002/advs.202100707}
#' 
#' @author Adrien Taudière \email{adrien.taudiere@zaclys.net}
#' @name greenAlgoR-package
#' @import ggplot2 targets benchmarkme
NULL
