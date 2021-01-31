##################################################
## Code: local_news_dash.R
## Project: The Trace
## Description: Build shiny app to display map with points
## Date: December 13, 2020
## Author: Susannah Derr
##################################################
rm(list=ls())

library(shiny)
library(shinydashboard)
library(data.table)
library(tidyverse)
library(dplyr)
library(scales)
library(DT)
library(leaflet)
library(readr)
library(leaflet.minicharts)


for_ranking<-read_csv("https://raw.githubusercontent.com/susannahd/local_reporting/main/Local%20News%20Landscape%20Condensed%202021-01-29.csv?token=AIAFIUYPLQFA3IOQ5XOS5E3AC43CK")
for_mapping<-read_csv("https://raw.githubusercontent.com/susannahd/local_reporting/main/Local%20News%20Landscape%20Mapping%20File%202021-01-29.csv?token=AIAFIU5G3QSMURF64LED5C3AC43H4")

ui<-dashboardPage(skin = "black"
                  ,dashboardHeader(title = "Local Reporting Initiative Prioritization")
                  ,dashboardSidebar(
                    sidebarMenu(
                      id = "tabs"
                      ,menuItem("How To Guide", icon = icon("info"), tabName = "about")
                      ,menuItem("Map View", tabName = "map", icon = icon("map"))
                      ,menuItem("Rank View",icon = icon("th"),tabName='rank')
                      ,sliderInput('gva','2020 Gun Violence',min=0,max=1,value=0.5,step=.05,ticks=FALSE)
                      ,sliderInput('police_violence', 'Police Violence',min=0,max=1,value=0.5,step=0.05,ticks=FALSE)
                      ,sliderInput('local_news', 'Local News Outlets Per Capita',min=0,max=1,value=0.5,step=0.05,ticks=FALSE)
                      ,sliderInput('inn', 'INN Members',min=0,max=1,value=0.5,step=0.05,ticks=FALSE)
                      ,sliderInput('black_media', 'Black and/or Latino Media Presence',min=0,max=1,value=0.5,step=0.05,ticks=FALSE)
                      ,sliderInput('black', 'Black Community',min=0,max=1,value=0.5,step=0.05,ticks=FALSE)
                      ,checkboxGroupInput('division','Division',c('Pacific','West North Central','West South Central','Mountain','East South Central','East North Central','South Atlantic','Middle Atlantic','New England'),selected=c('Pacific','West North Central','West South Central','Mountain','East South Central','East North Central','South Atlantic','Middle Atlantic','New England'))
                      ,actionButton("update", "Update Dashboard")
)),
                  
                  dashboardBody(
                    tabItems(
                      tabItem("about" 
                              ,fluidRow(
                                column(width = 9,
                                       column(12, h1("How To Guide: Local Reporting Initiative Prioritization"))
                                       ,column(12,h4("This tool was developed to help prioritize cities for The Trace's local reporting initiative. It incorporates data from the U.S. Census Bureau (for ZCTA level demographic projections), UNC's Expanding Media Desert project, the Center for Community Media's Black Media Initiative, CUNY's Latino News Media Map, the Institute for Nonprofit News' Member Directory, the National Association of Black Journalists' Chapters page, the Gun Violence Archive, and Mapping Police Violence."))
                                      ,column(12,h4("All of the data was consolidated into a single dataset to help understand The Trace's potential for impact in a given city, based on gun violence incidents and the presence of local and diverse media outlets."))
                                       ,column(12,h4("By using the sliders on the home page, users can indicate how important a variable is in determining the location for future on-the-ground reporting: sliding to the right indicates greater importance; to the left, lesser importance. The number on the slider represents the weight assigned to that variable in determining its overall rank. The Map View will display a map showing the top ranked 50 cities based on the user settings. The Rank View will display a list of those same top 50 cities, along with their associated data. "))
                                ))#End fluidRow
                      )#End tabItem about
##TAB ITEM MAP                      
                      ,tabItem("map" 
                              ,fluidRow(
                                column(width = 12,
                                       box(width = NULL, solidHeader = TRUE,
                                           leafletOutput("local_map", height = 800))
                                ))#End fluidRow
                      )#End tabItem map
##TAB ITEM RANK
                      ,tabItem("rank"
                               ,fluidRow()
                               ,fluidRow(column(DT::dataTableOutput("ranked_cities"),width=12))
                               ,fluidRow(p(class = 'text-center', downloadButton('downloader', 'Download Table')))
                               #End fluidRow
                      )#End tabItem detail
                    )#End tabItems
                  )#End dashboardBody
)#End ui

##SERVER
####################################################
server <- function(input, output) {
  
  ##RANKED CITIES
  ranked_cities<-eventReactive(input$update, {
      ranked_data<-for_ranking %>%
      mutate(weighted_gva=gva_rank*input$gva
              ,weighted_local_news =newspapers_per_capita_rank*input$local_news
              ,weighted_inn =inn_rank*input$inn
              ,weighted_blm =blm_rank*input$black_media
              ,weighted_black_community =black_community_rank*input$black
              ,weighted_police_violence =pva_rank*input$police_violence
              ,total=(weighted_gva+weighted_local_news+weighted_inn+weighted_blm+weighted_black_community+weighted_police_violence)/6
              ,total_rank=dense_rank(total)) %>%
        group_by(division) %>%
        mutate(rank_in_division=dense_rank(total)) %>%
        filter(division %in% input$division)
  })
  
  ##RANKED CITIES FOR MAPPING
  map_data<-reactive({
    map_data<-ranked_cities() %>%
      left_join(for_mapping,by=c('state_abbr','division','city')) %>%
      filter(total_rank<=50) %>%
      group_by(state_abbr,division,city) %>%
      slice(which.min(as.numeric(zip)))
  })
  
  ##CONDENSED DATA
  ranked_cities_condensed<-reactive({
    data<-ranked_cities() %>%
      rename(State=state_abbr
             ,Division=division
             ,City=city
             ,Population=total_population
             ,Newspapers=total_newspapers
             ,`Local News Coverage Ranking`=local_rank
             ,`Black or Latino Media Groups`=black_latino_media
             ,`Diverse Media Ranking`=blm_rank
             ,`INN Members`=inn_members
             ,`INN Rank`=inn_rank
             ,`2020 Gun Violence Incidents`=gun_incidents
             ,`Gun Violence Ranking`=gva_rank
             ,`2013-2020 Murders by Police`=murder_by_police
             ,`Police Violence Ranking`=gvpc_rank
             ,`Percent Black Population`= perc_black
             ,`Black Community Ranking`=black_community_rank
             ,`Total Rank`=total_rank
             ,`Rank in Division`=rank_in_division) %>%
      select(Division
             ,State,City,Population,Newspapers
             ,`Black or Latino Media Groups`,`2020 Gun Violence Incidents`,`2013-2020 Murders by Police`,
             `Percent Black Population`,`Rank in Division`,`Total Rank`,`INN Members`) %>%
       filter(`Total Rank`<=100) %>%
       mutate(`Percent Black Population`=round(`Percent Black Population`,3)) %>%
       arrange(`Total Rank`)
  })
  
  ##OUTPUTS
  ############################################################  
  ##MAP VIEW
  output$local_map <- renderLeaflet({
    
    data<-map_data()
    
    pal<-colorNumeric(
      palette="Blues",
      domain=data$total_rank,
      reverse=TRUE)
    
    map <- leaflet(map_data()) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(
        ~longitude,
        ~latitude,
        color = ~pal(total_rank),
        label = ~as.character(total_rank),
        opacity = 0.8,
        radius = 8,
        popup=~total_rank
      ) 
  })
  
  ##RANK VIEW
  #dataTable,top cities
  output$ranked_cities<-DT::renderDataTable({
    datatable(ranked_cities_condensed(),rownames=FALSE)
  })  
  
  # ##DOWNLOAD TABLE
  output$downloader <- downloadHandler(
    filename = function() {
      paste0('Local Reporting Initiative Priority Cities ',Sys.Date(),".csv")
    },

    content = function(file) {
      write.csv(ranked_cities_condensed(),file,row.names=FALSE)
    }
  )
  
}
shinyApp(ui, server)