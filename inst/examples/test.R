googleCharts::googleChart(
  data.table(name=c('Germany', 'USA', 'Brazil', 'Canada', 'France', 'RU'), value=c(700, 300, 400, 500, 600, 800))
  ,chart.type="Table")

library(quantmod)
library(data.table)
getSymbols("AAPL", from="1990-01-01", src="yahoo")

googleCharts::googleChart(
  data.table(Date = index(AAPL), close = as.numeric(AAPL[,"AAPL.Close"])
    ,volume = as.numeric(AAPL[,"AAPL.Volume"]))[
      ,list(
        Price=close[.N]
        ,range=paste0("Intra-month range: ",round(max(close)-min(close)))
        ,Volume=round(mean(volume)/1E6,2)
      )
      ,by=list(month=as.Date(format(Date, "%Y-%m-01")))]
  ,columns = list(range=list(role="tooltip")), chart.type="ComboChart"
) %>%
  googleCharts::googleChartOptions(
    title="Apple Closing Prices", legend = list(position = "bottom")
    ,series = list(
      list()
      ,list(targetAxisIndex = 1, type='bars')
    )
    ,vAxes = list(
      list(title = "Monthly Closing Prices")
      ,list(title="Mean Monthly Volume (MM)")
    )
    ,focusTarget = "category"
    ,explorer = list()
  )

df.aapl.prices <-
  data.frame(Date = index(AAPL), close = as.numeric(AAPL[,"AAPL.Close"]), volume=as.numeric(AAPL[,"AAPL.Close"]))

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
