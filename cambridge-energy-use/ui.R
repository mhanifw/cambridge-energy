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
                        )
                    )
                  ),
             br()
           ),
           
           # Panel 2: Classifications
           
           tabPanel("Classifications",
                    fixedRow(
                      column(4, 
                        # Write-up 1: Cambridge MA
                        includeMarkdown("md/1_about.md"),
                      ),
                      column(8,
                        #Map Tabs
                        tabsetPanel(type = "tabs",
                                    # Neighborhood map
                                    tabPanel("Neighborhood",
                                             plotlyOutput("neighborhoods_map"),
                                             includeMarkdown("md/1_neighborhoods.md")),
                                    # Parcel index map
                                    tabPanel("Parcel index",
                                             plotlyOutput("index_map"),
                                             includeMarkdown("md/1_parcels_index.md")),
                                    # Parcels map
                                    tabPanel("Parcels",
                                             plotOutput("parcels_map"),
                                             includeMarkdown("md/1_parcels.md")))
                      )
                    )
           ),
           
           # Panel 3: Analysis
           
           tabPanel("Analysis",
                    fixedRow(
                      column(12,
                               column(3,
                                      # markdown energy source
                                      includeMarkdown("md/3_energy_map.md"),
                                      # selectInput energy source
                                      
                               ),
                               column(9,
                                      tabsetPanel(type = "tabs",
                                                  # tabPanel 1: Energy
                                                  tabPanel("Energy",
                                                           # selectInput energy map
                                                           br(),
                                                           selectInput("energy_map_type",
                                                                       label = "Show:",
                                                                       choices = c("Energy intensity (kBtu/sqft)" = "energy_intensity",
                                                                                   "Total energy use (kBtu)" = "energy_total")),
                                                           plotlyOutput("energy_map"),
                                                           #includeMarkdown("md/1_neighborhoods.md")
                                                           ),
                                                  
                                                  # tabPanel 2: Water
                                                  tabPanel("Water", 
                                                           # selectInput energy map
                                                           br(),
                                                           selectInput("water_map_type",
                                                                       label = "Show:",
                                                                       choices = c("Water intensity (kgal/sqft)" = "water_intensity",
                                                                                   "Total water use (kgal)" = "water_total")),
                                                           plotlyOutput("water_map")
                                                           ),
                                                  
                                                  # tabPanel 3: Greenhouse gas emissions
                                                  tabPanel("Greenhouse gas emissions", 
                                                           # selectInput energy map
                                                           br(),
                                                           selectInput("ghg_map_type",
                                                                       label = "Show:",
                                                                       choices = c("Greenhouse gas intensity (kgCO2e/ft2)" = "ghg_intensity",
                                                                                   "Total greenhouse gas emissions (kgCO2e)" = "ghg_total")),
                                                           plotlyOutput("ghg_map")))
                                       ),
                             br(),
                                 column(3,
                                        
                                        includeMarkdown("md/3_regression.md"),
                                        # sliderInput year built
                                        sliderInput("reg_year_built",
                                                    label = h4("Year built:"),
                                                    min = 1700,
                                                    max = 2016,
                                                    value = c(1776, 2016)),
                                        selectInput("reg_plot_type",
                                                    label = "Show:",
                                                    choices = c("College/University",
                                                                "Multifamily Housing",
                                                                "Office",
                                                                "Laboratory"))
                                 ),
                                 
                                 column(9,
                                        br(),
                                        plotOutput("regression"),
                                        br()
                                 ),
                             br(),
                             br(),
                             br()
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
