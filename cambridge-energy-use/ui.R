#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(markdown)

navbarPage("Cambridge: Buildings & Energy",
           tabPanel("In a glance",
                    sidebarLayout(
                        sidebarPanel(
                            includeMarkdown("about.md"),
                            
                            includeMarkdown("about2.md")
                        ),
                        mainPanel(
                            plotOutput("plot")
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
