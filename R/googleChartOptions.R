#' googleChartOptions
#'
#' Add options to a googleChart. All options are completely optional. They are documented individually
#' in the online documentation of the JS library: see for example \href{https://developers.google.com/chart/interactive/docs/gallery/geochart#configuration-options}{configuration options for GeoChart}.
#' All parameters are accepted without validation, and are converted to arrays and objects using jsonlite::toJSON.
#' 
#' In addition to the JS library parameters, we make note of the following two parameters specific to the [R] package: formatter,
#' and clickListener, described in more detail in the Arguments section.
#' 
#' 
#' @param gChart An object instantiated using \code{\link{googleChart}} to add configuration options to.
#' @param formatter An object created using htmlwidget::JS(""), describing a function taking a google
#'  DataTable as input and applying \href{https://developers.google.com/chart/interactive/docs/reference#formatters}{formatters}, as needed.  See, \href{http://detule.github.io/googleCharts/#formatters}{this example}.
#' @param eventHandlers An object created using htmlwidget::JS("").
#' @param ... parameters specific to the JS/google library.
#'
#' @return googleChart
#'   
#' @note See the 
#'   \href{http://detule.github.io/googleCharts}{online
#'   documentation} for additional details and examples.
#' @export
googleChartOptions <- function(gChart, ...) {

  lst.existing.opts = gChart$x$options
  # merge options into attrs$options
  gChart$x$options <- mergeLists(lst.existing.opts, list(...))
   
  # return modified googleChart
  gChart
}

