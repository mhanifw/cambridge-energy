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
    
    # Page 2 Objects

    energyuse <-
        read_rds(path = "shiny-data/energyuse.rds")
    
    # Output 1_1: Cambridge Neighborhoods Map
    output$neighborhoods_map <- renderPlot({
        ggplot() +
            geom_sf(data = neighborhoods_shp, aes(fill = name)) +
            labs(
                title = "Cambridge MA Neighborhoods",
                subtitle = "Official 2019 Boundaries",
                caption = "Data source: City of Cambridge, MA"
            )
        })
    
    # Output 1_2: Cambridge Parcels Index Map
    output$index_map <- renderPlot({
        ggplot() +
            geom_sf(data = parcel_index_shp) +
            labs(
                title = "Cambridge MA Parcel index",
                subtitle = "Official 2019 Boundaries",
                caption = "Data source: City of Cambridge, MA"
            )
    })
    
    # Output 1_3: Cambridge Parcels Map
    output$parcels_map <- renderPlot({
        ggplot() +
            geom_sf(data = parcels_shp) +
            labs(
                title = "Cambridge MA Parcels",
                subtitle = "Official 2019 Boundaries",
                caption = "Data source: City of Cambridge, MA"
            )
    })
    
    # Output 2_1: Cambridge Buildings Histogram
    
    output$buildings_age <- renderPlot({

        min_built = input$year_built[1]
        max_built = input$year_built[2]
        
        energyuse %>%
            filter(reporting_year == 2018, report_type != "Child") %>%
            
            filter(year_built > min_built & year_built < max_built) %>%
            ggplot(aes(x = year_built)) +
            geom_histogram(aes(fill = property_type)) +
            labs(
                title = "How old are buildings in Cambridge?",
                subtitle = "Only shows nonresidential properties 50,000 sqft, residential properties with 50 or more units, and municipal properties > 10,000 sqft",
                x = "Year built",
                y = "Count"
            )
        
    })
    
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
