googleCharts::googleChart(
  data.table(name=c('Germany', 'USA', 'Brazil', 'Canada', 'France', 'RU'), value=c(700, 300, 400, 500, 600, 800))
  ,chart.type="Table")

library(quantmod)
getSymbols("AAPL", from="1990-01-01", src="yahoo")
googleCharts::googleChart(
  data.frame(Date = index(AAPL), close = as.numeric(AAPL[,"AAPL.Close"]), volume=as.numeric(AAPL[,"AAPL.Close"]))
  ,columns = list(volume=list(role="tooltip")), chart.type="ColumnChart"
)


library(shiny)
shiny::shinyApp(
  ui = fluidPage(
    fluidRow(
      shiny::column(width=6, offset=3
        ,googleChartOutput("test"))
    )
  )
  ,server = function(input, output, session) {
    output$test <- renderGoogleChart({
      googleCharts::googleChart(
        data.frame(Date = index(AAPL), close = as.numeric(AAPL[,"AAPL.Close"]), volume=as.numeric(AAPL[,"AAPL.Close"]))
        ,columns = list(volume=list(role="tooltip")), chart.type="ColumnChart"
      )
    })
  }
)
