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

navbarPage("Cambridge: Buildings & Energy",
           tabPanel("In a glance",
                    sidebarLayout(
                        sidebarPanel(
                            #Write-up 1: Cambridge MA
                            includeMarkdown("about.md"),
                            
                            #Spacing
                            hr(),
                            
                            #selectInput for Map
                            selectInput("variable", "Variable:",
                                        c("Neighborhoods" = "neighborhoods_map",
                                          "Parcel index" = "index_map",
                                          "Parcels" = "parcels_map"))
                        ),
                        mainPanel(
                            
                            # #Plot neighborhoods
                            # plotOutput("neighborhoods_map"),
                            
                            # #Plot index
                            # plotOutput("index_map"),
                            # 
                            # #Plot parcels
                            # plotOutput("parcels_map")
                          
                            #Plot parcels
                            plotOutput("render_map")
                        )
                    )
           ),
           tabPanel("Summary",
                    verbatimTextOutput("summary")
           ),
           navbarMenu("More",
                      tabPanel("Table",
                               DT::dataTableOutput("table")
                      ),
                      tabPanel("About")
                      )
           )
