#' @export
googleChart <- function(data, chart.type, columns = NULL, width = NULL, height = NULL) {

  x <- list()
  x$chartType = chart.type
  vec.col.classes <- sapply(data, class, USE.NAMES=T)
  x$columns <- sapply(names(data), function(x) switch(vec.col.classes[x], #Make this a named list so the user can easily merge individual column properties without having to specify the full array.
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
  vec.col.gtable.classes <- sapply(x$columns, function(x) x$type)
  if(any(vec.col.gtable.classes == "date")) {
    for(str.col in names(data)[vec.col.gtable.classes =="date"]) {
      data[[str.col]] <- paste0(
        "Date("
        ,apply(t(as.matrix(as.POSIXlt(data[[str.col]]))[,c("year", "mon", "mday")]) +
          rbind(rep(1900, length(data[str.col])),rep(0,length(data[[str.col]])), rep(0, length(data[[str.col]]))),2,FUN=function(x) paste(x, collapse=","))
        ,")")
    }
  }
  x$data <- jsonlite::toJSON(unname(data))

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


#' Shiny bindings for googleCharts
#'
#' @export
googleChartOutput <- function(outputId, width = "100%", height = "400px") {
  tagList(
    singleton(
      tags$head(
        tags$script(type = 'text/javascript'
          ,src="https://www.google.com/jsapi?autoload={'modules':[{'name':'visualization', 'version':'1'}]}"))
    )
    ,htmlwidgets::shinyWidgetOutput(outputId, "googleCharts", width, height)
  )
}

#' @rdname flot-shiny
#' @export
renderGoogleChart <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, googleChartOutput, env, quoted = TRUE)
}
