#' googleChartOptions
#' @export
googleChartOptions <- function(gChart, ...) {

  lst.existing.opts = gChart$x$options
  # merge options into attrs$options
  gChart$x$options <- mergeLists(lst.existing.opts, list(...))
   
  # return modified googleChart
  gChart
}

