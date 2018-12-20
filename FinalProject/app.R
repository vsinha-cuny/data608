library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)

csv1 <- "https://raw.githubusercontent.com/vsinha-cuny/data608/master/FinalProject/NHA_indicators2.csv"
csv2 <- "https://raw.githubusercontent.com/vsinha-cuny/data608/master/FinalProject/Life_Expectancy.csv"
#csv1 <- "NHA_indicators2.csv"
#csv2 <- "Life_Expectancy.csv"

df1 = read.csv(csv1, skip=0, sep=",", stringsAsFactors=F, header=T)
df2 = read.csv(csv2, skip=1, sep=",", stringsAsFactors=F, header=T)
df2$Country[df2$Country == "United Kingdom of Great Britain and Northern Ireland"] <- "United Kingdom"

per_capita_exp <- function(df, cc) {
    c1 = filter(df, Countries == cc)
    c1 = select(c1, X2000:X2016)
    c3 = gather(c1[1,], Year, PerCapitaExp, X2000:X2016)
    df.exp = c3
    df.exp$PerCapitaExp = as.numeric(gsub(",", "", df.exp$PerCapitaExp))
    return(df.exp$PerCapitaExp)
}

life_expectancy <- function(df, cc) {
    df.hc = filter(df, Country == cc) %>% select(Year, Both.sexes)
    #browser()
    df.hc = df.hc[order(df.hc$Year, decreasing=F),]
    df.hc$Both.sexes = as.numeric(df.hc$Both.sexes)
    return(df.hc$Both.sexes)
}

server <- function(input, output, session) {
    all_data <- reactive({
        return(list(df1, df2))
    })

    output$plot_expenditure <- renderPlot({
        l1 = all_data()
        d1 = l1[[1]]
        cc1 = input$country1
        cc2 = input$country2

        Year = seq(from=2000, to=2016, by=1)
        Amt1 = per_capita_exp(df1, cc1)
        Amt2 = per_capita_exp(df1, cc2)
        df.amt = data.frame(Year, Amt1, Amt2)
        p1 = ggplot(df.amt, aes(x = Year)) + labs(y = "Per Capita Exp (US$)") +
                geom_line(aes(y=Amt1, color = cc1)) +
                geom_line(aes(y=Amt2, color = cc2))
        print(p1)
    })

    output$plot_life_expectancy <- renderPlot({
        l1 = all_data()
        d2 = l1[[2]]

        cc1 = input$country1
        cc2 = input$country2

        Year = seq(from=2000, to=2016, by=1)
        Exp1 = life_expectancy(df2, cc1)
        Exp2 = life_expectancy(df2, cc2)

        df.exp = data.frame(Year, Exp1, Exp2)
        p1 = ggplot(df.exp, aes(x = Year)) + labs(y = "Life Expectancy (both sexes)") +
                geom_line(aes(y=Exp1, color = cc1)) +
                geom_line(aes(y=Exp2, color = cc2))
        print(p1)
    })
}

ui <- fluidPage(
    titlePanel("Comparing Healthcare Expenditures vs. Life Expectancy"),
    sidebarLayout(position="right",
        sidebarPanel(
            selectInput('country1', 'Country 1', sort(unique(df1$Countries))),
            helpText("Select any two countries for comparison"),
            selectInput('country2', 'Country 2', sort(unique(df1$Countries)))
        ),
        mainPanel(
            plotOutput(outputId = "plot_expenditure", height = "300px"),
            plotOutput(outputId = "plot_life_expectancy", height = "300px")
        )
    )
)

shinyApp(ui = ui, server = server)
