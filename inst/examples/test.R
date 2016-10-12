googleCharts::googleChart(
  data.table(name=c('Germany', 'USA', 'Brazil', 'Canada', 'France', 'RU'), value=c(700, 300, 400, 500, 600, 800))
  ,chart.type="Table")

library(quantmod)
getSymbols("AAPL", from="1990-01-01", src="yahoo")
df.aapl.prices <-
  data.frame(Date = index(AAPL), close = as.numeric(AAPL[,"AAPL.Close"]), volume=as.numeric(AAPL[,"AAPL.Close"]))

googleCharts::googleChart(
  df.aapl.prices
  ,columns = list(volume=list(role="tooltip")), chart.type="ColumnChart"
) %>%
  googleCharts::googleChartOptions(title="Apple Closing Prices", legend = list(position = "bottom"))


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
        df.aapl.prices
        ,columns = list(volume=list(role="tooltip")), chart.type="ColumnChart"
      )
    })
  }
)
