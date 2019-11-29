#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
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

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    # Page 1 objects
    
    parcels_shp <- 
        read_rds("shiny-data/parcels.rds") %>%
        clean_names() %>%
        mutate(map_lot = ml) %>%
        select(map_lot, shape_st_ar, shape_st_le, geometry)
    
    parcel_index_shp <- 
        read_rds("shiny-data/parcel_index.rds") %>%
        clean_names()
    
    neighborhoods_shp <- 
        read_rds("shiny-data/neighborhoods.rds") %>%
        clean_names()
    
    # Output 1: Cambridge Neighborhoods Map
    output$neighborhoods_map <- renderPlot({
        ggplot() +
            geom_sf(data = neighborhoods_shp, aes(fill = name)) +
            labs(
                title = "Cambridge MA Neighborhoods",
                subtitle = "2019 boundaries",
                caption = "Data source: City of Cambridge, MA"
            )
        })
    
    # Output 2: Cambridge Parcels Index Map
    output$index_map <- renderPlot({
        ggplot() +
            geom_sf(data = parcel_index_shp) +
            labs(
                title = "Cambridge MA Neighborhoods",
                subtitle = "2019 Parcel Index",
                caption = "Data source: City of Cambridge, MA"
            )
    })
    
    # Output 3: Cambridge Parcels Map
    output$parcels_map <- renderPlot({
        ggplot() +
            geom_sf(data = parcels_shp) +
            labs(
                title = "Cambridge MA Parcels",
                subtitle = "2019 Parcel Index",
                caption = "Data source: City of Cambridge, MA"
            )
    })
    
    # Output 4: CombinedMap
    output$render_map <- renderPlot({
        
        neighborhoods_map <-
            ggplot() +
            geom_sf(data = neighborhoods_shp, aes(fill = name)) +
            labs(
                title = "Cambridge MA Neighborhoods",
                subtitle = "2019 boundaries",
                caption = "Data source: City of Cambridge, MA"
            )
        
        index_map <-
            ggplot() +
            geom_sf(data = parcel_index_shp) +
            labs(
                title = "Cambridge MA Neighborhoods",
                subtitle = "2019 Parcel Index",
                caption = "Data source: City of Cambridge, MA"
            )
        
        parcels_map <-
            ggplot() +
            geom_sf(data = parcels_shp) +
            labs(
                title = "Cambridge MA Parcels",
                subtitle = "2019 Parcel Index",
                caption = "Data source: City of Cambridge, MA"
            )
    })
    
    # Output 4: Energy usage plot
    
    #Dummy outputs
    output$plot <- renderPlot({
        plot(cars, type=input$plotType)
    })
    
    output$summary <- renderPrint({
        summary(cars)
    })
    
    output$table <- DT::renderDataTable({
        DT::datatable(cars)
    })
})
