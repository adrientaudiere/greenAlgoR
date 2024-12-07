% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{session_runtime}
\alias{session_runtime}
\title{Compute session run time and mass storage use (based on \code{gc()})}
\usage{
session_runtime(compute_mass_storage = TRUE)
}
\arguments{
\item{compute_mass_storage}{(logical, default TRUE) Do the mass storage is
computed from \code{base::gc()} function}
}
\value{
A list of values
}
\description{
\if{html}{\out{
<a href="https://adrientaudiere.github.io/greenAlgoR/articles/Rules.html#lifecycle">
<img src="https://img.shields.io/badge/lifecycle-experimental-orange" alt="lifecycle-experimental"></a>
}}


Compute cpu times using \code{base::proc.time()} and mass storage using
\code{base::gc()}
}
\examples{
session_runtime()
session_runtime(compute_mass_storage = FALSE)
}
\author{
Adrien Taudière
}
