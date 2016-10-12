#' @export
googleChart <- function(data, chart.type, columns = NULL, width = NULL, height = NULL) {
  
  x <- list()
  x$chartType = chart.type
  x$data <- toJSON(unname(data))
  x$columns <- sapply(names(data), function(x) switch(class(data[[x]]), #Make this a named list so the user can easily merge individual column properties without having to specify the full array.
      integer=list(label = x, type="number"),                #We unname it (object->array) in the JS file.
      double=list(label = x, type="number"),
      numeric=list(label = x, type = "number"),
      character=list(label = x, type = "string"),
      logical=list(label = x, type = "boolean"),
      factor=list(label = x, type = "string"),
      Date=list(label = x, type = "date"),
      list(label = x, type = "string")), simplify=F, USE.NAMES=T)
  
  if(!is.null(columns)) {
    x$columns <- mergeLists(x$columns, columns)
  }

  #Some default global options
  #Interactivity enabled globally, including tooltips
  #Do not show legend by default
  #Points rather than lines/bars
  x$options <- list()
  if(!is.data.frame(data)) {
    stop("googleCharts: An object of class data.frame is expected for the data parameter")
  }
#  attr(x, "data") <- data
#  # create widget
  htmlwidgets::createWidget(
    name = "googleCharts",
    x = x,
    width = width,
    height = height,
    ,dependencies = htmltools::htmlDependency("api", 1
      ,src=c("href"="https://www.google.com/jsapi?autoload={'modules':[{'name':'visualization', 'version':'1'}]}")
      ,script="")
  )
}
