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
                      # Row 1: Buildings age
                      fixedRow(
                        column(3,
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
                      # Row 2: Who consumes?
                      fixedRow(
                        hr(),
                        column(4,
                               "Level 2 column left",
                               includeMarkdown("md/2_energy_use.md"),
                               selectInput("energy_year",
                                           label = "Year:",
                                           choices = c(2016, 2017),
                                           selected = 2016)),
                        column(4,
                               "Level 2 column mid",
                               plotOutput("electric_use")
                               #plot output electic here
                               ),
                        column(4,
                               "Level 2 column right",
                               plotOutput("water_use")
                               #plot output water here
                               )
                      ),
                      # Row 3: Energy sources
                      fixedRow(
                        hr(),
                        column(5,
                               "Level 3 column left"),
                        column(7,
                               "Level 3 column right")
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
