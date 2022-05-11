#' compute standard error of the mean
#'
#' @param x numeric vector, a sample of numbers
#' @return the standard error of the mean.
#' @section formula:
#' This is the formula for the standard error of the mean.
#' \deqn{ \frac{\sigma}{\sqrt{N}} }
#' @examples
#' sem(1:5)
sem <- function(x){
  sd(x)/sqrt(length(x))
}
