library(shiny)
library(dplyr)
library(ggplot2)

csv <- "https://raw.githubusercontent.com/vsinha-cuny/data608/master/proj3/cleaned-cdc-mortality-1999-2010-2.csv"
mdf = read.csv(csv, stringsAsFactors=F)
mdf[is.na(mdf)] <- 0

server <- function(input, output, session) {

    all_states <- reactive({
        return(mdf)
    })

    output$all_states <- renderPlot({
        adf = all_states() %>% filter(ICD.Chapter == input$cause & Year == 2010)
        adf = adf %>% select(State, Crude.Rate)

        p1 <- ggplot(adf, aes(x=State, y=Crude.Rate))
        ylabel = paste("CAUSE: ", input$cause)
        p1 <- p1 + labs(x="States", y=ylabel, title="Mortality Rates for All States: 2010")
        p1 <- p1 + geom_point(col="tomato2", size=2)
        print(p1)

    })

    output$state_ts_comparison <- renderPlot({

        all = all_states()
        sdf = filter(all, ICD.Chapter == input$cause & State == input$state)

        wdf = filter(all, ICD.Chapter == input$cause)
        wdf$Population = as.numeric(wdf$Population)
        wdf = data.frame(wdf %>% group_by(Year) %>% summarize(wsum = weighted.mean(Crude.Rate, Population)))
        sdf$National = wdf$wsum

        p1 <- ggplot(sdf, aes(x=Year))

        ylabel = paste("CAUSE: ", input$cause)
        title_str = paste(input$state, ": Crude Mortality Rate Over Time")
        p1 <- p1 + labs(x="State", y=ylabel, title=title_str)
        Color=input$state
        p1 <- p1 + geom_line(aes(y=Crude.Rate, color=Color))
        p1 <- p1 + geom_line(aes(y=National, color="National"))
        print(p1)

    })
}

ui <- fluidPage(

    titlePanel("Mortality Rates"),

    sidebarLayout(position="right",
        sidebarPanel(
            selectInput('cause', 'Cause', unique(as.character(mdf$ICD.Chapter))),
            helpText("Type of Disease (ICD classification)"),
            selectInput('state', 'State', unique(as.character(mdf$State)))
        ),
        mainPanel(
            plotOutput(outputId = "all_states", height = "300px"),
            plotOutput(outputId = "state_ts_comparison", height = "300px")
        )
    )
)

shinyApp(ui = ui, server = server)
