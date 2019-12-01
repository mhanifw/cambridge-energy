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
library(plotly)
library(treemapify)
library(janitor)
library(markdown)
library(tidyverse)

# Title
navbarPage("Cambridge: Buildings & Energy",
           
           # Panel 1: In a glance
           
           tabPanel(
             "In a glance",
             fixedRow(
               column(12,
                      #"Level 1 column",
                      # Row 1: Buildings age
                      fixedRow(
                        column(3,
                               # markdown buildings age
                               includeMarkdown("md/2_buildings_age.md"),
                               # sliderInput year built
                               sliderInput("year_built",
                                           label = h4("Year built:"),
                                           min = 1700,
                                           max = 2016,
                                           value = c(1976, 2016)),
                               # selectInput granularity
                               selectInput("granularity",
                                           label = "Granularity:",
                                           choices = c(2017, 2018) %>%
                                             `names<-`(c("By group", "By types"))),
                        ),
                        column(9,
                               br(),
                               #plot output buildings age - histogram
                               plotlyOutput("buildings_age")
                              )
                        ),
                      # Row 2: Who consumes?
                      fixedRow(
                        hr(),
                        column(3,
                               # "Level 3 column left",
                               # markdown energy source
                               includeMarkdown("md/2_energy_source.md"),
                               
                               # selectInput energy source
                               selectInput("source_type",
                                           label = "Energy source:",
                                           choices = c("Grid electricity" = "grid_electricity",
                                                       "Natural gas" = "natural_gas",
                                                       "Fuel oil" = "fuel_oil",
                                                       "Diesel" = "diesel",
                                                       "Kerosene" = "kerosene",
                                                       "Total (kBtu)" = "total_kbtu"),
                                           selected = "Total (kBtu)")),
                        column(9,
                               # "Level 2 column right",
                               # plot output energy source
                               plotOutput("energy_source_treemap")
                               )
                        ),
                      # Row 3: Energy sources
                      fixedRow(
                        hr(),
                        column(3,
                                "Level 3 column left"
                               ),
                        column(9,
                               "Level 3 column right",
                               ),
                      )
                    )
                  ),
             br(),
             hr(),
           ),
           
           # Panel 2: Classifications
           
           tabPanel("Classifications",
                    sidebarLayout(
                      sidebarPanel(
                        # Write-up 1: Cambridge MA
                        includeMarkdown("md/1_about.md"),
                      ),
                      mainPanel(
                        
                        tabsetPanel(type = "tabs",
                                    # Neighborhood map
                                    tabPanel("Neighborhood", 
                                             hr(),
                                             plotlyOutput("neighborhoods_map"),
                                             includeMarkdown("md/1_neighborhoods.md")),
                                    # Parcel index map
                                    tabPanel("Parcel index", 
                                             hr(),
                                             plotlyOutput("index_map"),
                                             includeMarkdown("md/1_parcels_index.md")),
                                    # Parcels map
                                    tabPanel("Parcels", 
                                             hr(),
                                             plotOutput("parcels_map"),
                                             includeMarkdown("md/1_parcels.md")))
                      )
                    )
           ),
           
           # Panel 3: Analysis
           
           tabPanel("Analysis",
                    fixedRow(
                      column(12,
                             
                             h2("Spatial visualizations by Parcel index"),
                             hr(),
                             
                               column(3,
                                      # markdown energy source
                                      includeMarkdown("md/3_energy_map.md"),
                                      # selectInput energy source
                                      selectInput("map_type",
                                                  label = "Map type:",
                                                  choices = c("Total energy use (kBtu)" = "energy_total",
                                                              "Energy intensity (kBtu/sqft)" = "energy_intensity",
                                                              "Total GHG emission (tons)" = "ghg_emission_total",
                                                              "GHG emission intensity (tons/sqft)" = "ghg_emission_intensity",
                                                              "Total water use (kgal)" = "water_total",
                                                              "Water intensity (kgal/sqft)" = "water_intensity"))
                               ),
                               column(9,
                                      plotlyOutput("energy_map")
                                      )
                             )
                    )
           ),
           
           # Panel 4: About
           
           tabPanel("About",
                    fixedRow(
                      column(6,
                             includeMarkdown("md/4_about.md")
                             ),
                      column(6,
                             imageOutput("about_img")
                      )
                    )
               )
           )
