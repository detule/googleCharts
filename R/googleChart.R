#' googleChart
#'
#' Main entry point - all charts are produced by passing a data-set using the data parameter, and selecting
#' a type of chart using the chart.type parameter.  Data format is specific to each type of chart;  the user should consult the
#' relevant API documentation as needed (for example \href{https://developers.google.com/chart/interactive/docs/gallery/columnchart#data-format}{Data format for column charts}).
#'
#' In addition, we allow the user to override column specific meta-data using the columns parameter.  See \href{http://detule.github.io/googleCharts/#column}{here} for an example on how
#' one can override the type of data reported to the underlying API for each column.
#'
#' @param data A wide data-frame containing data and meta-data columns
#' @param chart.type A string denoting the type of chart to produce.  We are currently not enforcing any discipline on this parameter to allow the user access to new and experimental charts
#'  as they are made available to the JS library loader.  Commonly used options are AnnotationChart, AreaChart, BarChart, BubbleChart, Calendar, ColumnChart, ComboChart, Gantt, GeoMap, MotionChart,
#'  PieChart, Sankey, ScatterChart, Timeline, Table, or WordTree.  However there are many more, such as CandlestickChart, Gauge, Histogram, etc - consult
#'  the \href{https://developers.google.com/chart/interactive/docs/gallery}{JS gallery page} for a complete listing.
#' @param columns A list named after colnames(data) (optional)
#' @param width Width in pixels (optional, defaults to automatic sizing, except in the case of GeoMap and MotionMap, whereby it defaults to 556px and 500px, respectively)
#' @param height Height in pixels (optional, defaults to automatic sizing)
#'
#' @return googleChart
#'
#' @note See the
#'   \href{http://detule.github.io/googleCharts}{online
#'   documentation} for additional details and examples.
#'
#' @export
googleChart <- function(data, chart.type, columns = NULL, width = NULL, height = NULL) {

  if(!is.data.frame(data)) {
    stop("googleCharts: An object of class data.frame is expected for the data parameter")
  }

  if(length(columns) != length(names(columns)) | !all(names(columns) %in% names(data))) {
    stop("googleCharts: Improperly formatted `columns` parameter.  Must be",
          " a named list with all(names(columns) %in% names(data))")
  }

  x <- list()
  x$chartType = chart.type

  #Let's figure out what kind of data-types are in the data.frame,
  #translate these to Google's data-types, and merge the `columns`
  #argument.
  vec.col.classes <- sapply(data, class, USE.NAMES=T)
  x$columns <- sapply(names(data), function(x) switch(vec.col.classes[x]
      ,integer=list(label = x, type="number")
      ,double=list(label = x, type="number")
      ,numeric=list(label = x, type = "number")
      ,character=list(label = x, type = "string")
      ,logical=list(label = x, type = "boolean")
      ,factor=list(label = x, type = "string")
      ,Date=list(label = x, type = "date")
      ,list(label = x, type = "string")), simplify=F, USE.NAMES=T)

  #Make x$columns a named list so the user can easily merge individual
  #column properties without having to specify the full array.
  #We unname it (object->array) in the JS file.
  
  if(!is.null(columns)) {
    x$columns <- mergeLists(x$columns, columns)
  }
  vec.col.gtable.classes <- sapply(x$columns, function(x) x$type)

  #Let's leverage [R]'s vectorized functions to make the [R]::Date to JS::Date conversion.
  #Here we use the ability to create dates from string literals:
  #https://developers.google.com/chart/interactive/docs/datesandtimes#dates-and-times-using-the-date-string-representation
  #Looks pretty ugly - may need to re-visit later.
  if(any(vec.col.gtable.classes == "date")) {
    for(str.col in names(data)[vec.col.gtable.classes =="date"]) {
      data[[str.col]] <- ifelse(is.na(data[[str.col]])
        ,NA
        ,paste0(
          "Date("
          ,apply(t(as.matrix(as.POSIXlt(as.Date(data[[str.col]])))[,c("year", "mon", "mday"), drop=F]) +
            rbind(rep(1900, length(data[str.col])),rep(0,length(data[[str.col]])), rep(0, length(data[[str.col]]))),2,FUN=function(x) paste(x, collapse=","))
          ,")")
        )
    }
  }
  x$data <- jsonlite::toJSON(unname(data), na = "null")

  #Some default global options
  x$options <- list(
    width = ifelse(chart.type == "GeoMap", "556px", ifelse(chart.type == "MotionChart", "500px", "100%"))
    ,eventHandlers = htmlwidgets::JS("
                      function(wrapper) {
                          if(typeof(Shiny) != 'undefined') {
                            google.visualization.events.addListener(wrapper, 'select', function() {
                              var selection = wrapper.getChart().getSelection();
                              Shiny.onInputChange($('#'+wrapper.getContainerId()).closest('div.shiny-bound-output').attr('id') + '_selected', selection);
                            })
                          }
                      }")
  )

  # create widget
  htmlwidgets::createWidget(
    name = "googleCharts",
    x = x,
    width = width,
    height = height
  )
}


#' Shiny bindings for googleCharts
#' 
#' Output and render functions for using googleCharts within Shiny 
#' applications and interactive Rmd documents.
#' 
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{"100\%"},
#'   \code{"400px"}, \code{"auto"}) or a number, which will be coerced to a
#'   string and have \code{"px"} appended.
#' @param expr An expression that generates a googleChart
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This 
#'   is useful if you want to save an expression in a variable.
#'   
#' @rdname googleChart-shiny
#' @export
googleChartOutput <- function(outputId, width = "100%", height = "400px") {
  tagList(
    htmltools::singleton(
      tags$head(
        tags$script(type = "text/javascript"
          ,src="https://www.gstatic.com/charts/loader.js")
        ,tags$script("google.charts.load('current');")
      )
    )
    ,htmlwidgets::shinyWidgetOutput(outputId, "googleCharts", width, height)
  )
}

#' @export
renderGoogleChart <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, googleChartOutput, env, quoted = TRUE)
}
