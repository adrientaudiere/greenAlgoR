#' Title
#'
#' @param url 
#' @param remove_first_line 
#'
#' @return
#' @export
#'
#' @examples
csv_from_url_green_algo <- function(url, remove_first_line = TRUE){
  url <- RCurl::getURL(url)
  df <-  read.csv(text = url, header = FALSE)
  if(remove_first_line) {
    df <- df[-1,]
  } 
  tib <-  as.data.frame(df[-1,])
  colnames(tib) <- as.character(df[1,])
  return(tib)
}
