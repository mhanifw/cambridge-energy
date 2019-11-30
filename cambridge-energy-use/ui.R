#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Libraries
library(shiny)
library(sf)
library(fs)
library(janitor)
library(markdown)
library(tidyverse)

# Title
navbarPage("Cambridge: Buildings & Energy",
           
           # Panel 1: Classifications
           
           tabPanel("Classifications",
                    sidebarLayout(
                        sidebarPanel(
                            # Write-up 1: Cambridge MA
                            includeMarkdown("md/about.md"),
                                    ),
                        mainPanel(
                          
                          tabsetPanel(type = "tabs",
                                      # Neighborhood map
                                      tabPanel("Neighborhood", 
                                               hr(),
                                               plotOutput("neighborhoods_map"),
                                               includeMarkdown("md/1_neighborhoods.md")),
                                      # Parcel index map
                                      tabPanel("Parcel index", 
                                               hr(),
                                               plotOutput("index_map"),
                                               includeMarkdown("md/1_parcels_index.md")),
                                      # Parcels map
                                      tabPanel("Parcels", 
                                               hr(),
                                               plotOutput("parcels_map"),
                                               includeMarkdown("md/1_parcels.md")))
                          )
                        )
           ),
           
           # Panel 2: In a glance
           
           tabPanel(
             "In a glance",
             fixedRow(
               column(12,
                      "Level 1 column",
                      fixedRow(
                        column(3,
                               #Buildings age
                               includeMarkdown("md/2_buildings_age.md"),
                               sliderInput("year_built",
                                           label = h4("Year built:"),
                                           min = 1700,
                                           max = 2016,
                                           value = c(1976, 2016))
                        ),
                        column(9,
                               plotOutput("buildings_age")
                          )
                        ),
                      fixedRow(
                        hr(),
                        column(5,
                               "Level 2 column left"),
                        column(7,
                               "Level 2 column right")
                      )
                    ),
                  )
           ),
           
           # Panel 3: Analysis
           
           tabPanel("Analysis",
           ),
           
           # Panel 4: About
           
           tabPanel("About",
                      )
           )
