googleCharts::googleChart(
  data.frame(
    Name=c('John', 'Mary', 'Steve', 'Ellen', 'Mike')
    ,Salary=c(10000, 25000, 8000, 20000, 12000)
    ,`Full Time`=c(T,T,F,T,F)
    ,stringsAsFactors = F
  )
  ,chart.type="Table") %>%
  googleChartOptions(width="100%")

googleCharts::googleChart(
  data.frame(
    Department=c('Shoes', 'Sports', 'Toys', 'Electronics', 'Food', 'Art')
    ,Revenues=c(10700, -15400, 12500, -2100, 22600, 1100)
    ,stringsAsFactors = F
  )
  ,chart.type="Table") %>%
  googleChartOptions(width="100%", allowHtml = T, formatter=htmlwidgets::JS("
    function(data) {
      var formatter = new google.visualization.NumberFormat({prefix: '$', negativeColor: 'red', negativeParens: true});
      formatter.format(data, 1);
    }"))

googleCharts::googleChart(
  data.frame(
    Department=c('Shoes', 'Sports', 'Toys', 'Electronics', 'Food', 'Art')
    ,Revenues=c(10700, -15400, 12500, -2100, 22600, 1100)
    ,stringsAsFactors = F
  )
  ,chart.type="Table") %>%
  googleChartOptions(width="100%", allowHtml = T, formatter=htmlwidgets::JS("
    function(data) {
      var formatter = new google.visualization.BarFormat({width: 120});
      formatter.format(data, 1);
    }"))

googleCharts::googleChart(
  data.frame(
    Country=c('Germany', 'USA', 'Brazil', 'Canada', 'France', 'RU')
    ,Popularity=c(700, 300, 400, 500, 600, 800)
  )
  ,chart.type="GeoMap")

googleCharts::googleChart(
  data.frame(
    President=c('Washington', 'Adams', 'Jefferson')
    ,Start=as.Date(c("1789-04-30", "1797-03-04", "1801-03-04"))
    ,End=as.Date(c("1797-03-04", "1801-03-04", "1809-03-04"))
  )
  ,chart.type="Timeline")

googleCharts::googleChart(
  data.frame(
    Date = as.Date(c("2314-03-15", "2314-03-16", "2314-03-17", "2314-03-18", "2314-03-19", "2314-03-20"))
    ,`Kepler-22b mission`=c(12400, 24045, 35022, 12284, 8476, 0)
    ,`Kepler title` = c(NA, "Lalibertines","Lalibertines","Lalibertines","Lalibertines","Lalibertines")
    ,`Kepler text` = c(NA, "First encounter", "They are very tall", "Attack on our crew!", "Heavy casualties", "All crew lost")
    ,`Gliese 163 mission` = c(10645, 12374, 15766, 34334, 66467, 79463)
    ,`Gliese title` = c(NA, NA, "Gallantors", "Gallantors", "Gallantors", "Gallantors")
    ,`Gliese text` = c(NA, NA, "First Encounter", "Statement of shared principles", "Mysteries revealed", "Omniscience achieved")
  )
  ,chart.type="AnnotationChart")

googleCharts::googleChart(
  data.frame(
    Major = c("Business", "Education", "Social Sciences", "Health", "Psychology")
    ,Degrees = c(256070, 108034, 127101, 81863, 74194)
    ,Degrees_new = c(358293, 101265, 172780, 129634, 97216)
  ), columns = list(Degrees = list(role="old-data"))
  ,chart.type = "PieChart"
) %>%
  googleChartOptions(
    diff = list(innerCircle = list(borderFactor= 0.08))
  )

googleCharts::googleChart(
  data.frame(
    Fruit=c('Apples', 'Oranges', 'Bananas', 'Apples', 'Oranges', 'Bananas')
    ,Date=as.Date(c("1988-01-01", "1988-01-01", "1988-01-01", "1989-06-01", "1989-06-01", "1989-06-01"))
    ,Sales=c(1000, 1150, 300, 1200, 750, 788)
    ,Expenses=c(300, 200, 250, 400, 150, 617)
    ,Locations=c("East", "West", "West", "East", "West", "West")
    ,stringsAsFactors = F
  )
  ,chart.type="MotionChart")

library(quantmod)
library(data.table)
getSymbols("AAPL", from="1990-01-01", src="yahoo")
dt.aapl.prices <-
  data.table(Date = index(AAPL), close = as.numeric(AAPL[,"AAPL.Close"])
    ,volume = as.numeric(AAPL[,"AAPL.Volume"]))[
      ,list(
        Price=close[.N]
        ,range=paste0("Intra-month range: ",round(max(close)-min(close)))
        ,Volume=round(mean(volume)/1E6,2)
      )
      ,by=list(month=as.Date(format(Date, "%Y-%m-01")))]

library(shiny)
shiny::shinyApp(
  ui = fluidPage(
    fluidRow(
      shiny::column(width=6, offset=3
        ,googleChartOutput("test"))
    )
    ,fluidRow(
      shiny::column(offset=3, width=9, textOutput("testSelection"))
    )
  )
  ,server = function(input, output, session) {
    output$test <- renderGoogleChart({
      googleCharts::googleChart(
        dt.aapl.prices
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
    })
    output$testSelection <- renderText({
      if(is.null(input$test_selected)) return("No current selection.")
      paste0("You selected row: ", input$test_selected["row"]+1, ", corresponding to Date: "
        ,dt.aapl.prices[input$test_selected["row"]+1,month] )
    })
  }
)
