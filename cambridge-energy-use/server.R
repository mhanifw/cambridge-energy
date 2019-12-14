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
library(plotly)
library(treemapify)
library(janitor)
library(markdown)
library(tidyverse)

# Plotly

Sys.setenv("plotly_username"="mhanifw")
Sys.setenv("plotly_api_key"="tWeknMdPvifFQ1mfxkZR")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    # Page 1 objects
    
    parcels_shp <- 
        read_rds("shiny-data/parcels.rds") %>%
        clean_names() 
    
    parcel_index_shp <- 
        read_rds("shiny-data/parcel_index.rds") %>%
        clean_names()
    
    neighborhoods_shp <- 
        read_rds("shiny-data/neighborhoods.rds") %>%
        clean_names()
    
    # Page 2 Objects
    
    energyuse <-
        read_rds(path = "shiny-data/energyuse.rds")
    
    energy_source <-
        read_rds(path = "shiny-data/energy_source.rds")
    
    # Page 3 objects
    
    energy_map <-
        read_rds(path = "shiny-data/energy_map.rds")
    
    # Output 1_1: Cambridge Buildings Histogram
    
    output$buildings_age <- renderPlotly({
        
        min_built = input$year_built[1]
        max_built = input$year_built[2]
        granularity = input$granularity
        
        x <- 
            energyuse %>%
            filter(reporting_year == granularity, report_type != "Child") %>%
            filter(year_built > min_built & year_built < max_built) %>%
            ggplot(aes(x = year_built)) +
            geom_histogram(aes(fill = property_type), color = "white") +
            labs(
                title = "How old are buildings in Cambridge?",
                subtitle = "Only shows nonresidential properties 50,000 sqft, residential properties with 50 or more units, and municipal properties > 10,000 sqft",
                x = "Year built",
                y = "Count"
            )
        
        ggplotly(x)
        
    })
    
    # Output 1_2: Energy source treemap
    
    output$energy_source_treemap <- renderPlot ({
        
        source_type <- switch(input$source_type,
                              grid_electricity = energy_source$grid_electricity,
                              natural_gas = energy_source$natural_gas,
                              fuel_oil = energy_source$fuel_oil,
                              diesel = energy_source$diesel,
                              kerosene = energy_source$kerosene,
                              total_kbtu = energy_source$total_kbtu)
        
        energy_source %>%
            ggplot(aes(area = source_type, 
                       fill = source_type, 
                       label = primary_property_type_self_selected)) +
            geom_treemap() +
            geom_treemap_text(fontface = "italic", colour = "white", place = "centre",
                              grow = FALSE)
        
    })
    
    # Output 2_1: Plotly Cambridge Neighborhoods
    output$neighborhoods_map <- renderPlotly({
        
        x <- 
            ggplot() +
            geom_sf(data = neighborhoods_shp, aes(fill = name)) +
            labs(
                title = "Cambridge MA Neighborhoods",
                subtitle = "Official 2019 Boundaries",
                caption = "Data source: City of Cambridge, MA"
            ) +
            theme(legend.position = "none")
        
        ggplotly(x)
        
    })
    
    # Output 2_2: Plotly Cambridge Parcels Index Map
    output$index_map <- renderPlotly({
        x <- 
            ggplot() +
            geom_sf(data = parcel_index_shp, aes(text = pcix_no)) +
            labs(
                title = "Cambridge MA Parcel index",
                subtitle = "Official 2019 Boundaries",
                caption = "Data source: City of Cambridge, MA"
            )
        
        ggplotly(x)
        
    })
    
    
    # Output 2_3: Plotly Cambridge Parcels Map
    output$parcels_map <- renderPlot({
        
        ggplot() +
            geom_sf(data = parcels_shp) +
            labs(
                title = "Cambridge MA Parcels",
                subtitle = "Official 2019 Boundaries",
                caption = "Data source: City of Cambridge, MA"
            )
    })
    
    # Output 3_a: Plotly Energy map
    
    output$energy_map <- renderPlotly ({
        
        map_type <- switch(input$energy_map_type,
                           energy_intensity = energy_map$parcel_energy_intensity,
                           energy_total = energy_map$parcel_energy_use)
        
        x <-
            energy_map %>%
            ggplot(aes(fill = map_type)) +
            scale_fill_gradient(name = "colors are in log scale",
                                trans = "log",
                                low = "white",
                                high = "#F0A35C") +
            geom_sf() +
            labs(
                title = "Electricity usage for each Parcel index in Cambridge",
                subtitle = "Official 2019 Boundaries",
                caption = "Data source: City of Cambridge, MA"
            )
        
        ggplotly(x)
        
    })
    
    # Output 3_b: Plotly Water map
    
    output$water_map <- renderPlotly ({
        
        map_type <- switch(input$water_map_type,
                           water_intensity = energy_map$parcel_water_intensity,
                           water_total = energy_map$parcel_water_use)
        
        x <-
            energy_map %>%
            ggplot(aes(fill = map_type)) +
            scale_fill_gradient(name = "colors are in log scale",
                                trans = "log",
                                low = "white",
                                high = "#2E74D1") +
            geom_sf() +
            labs(
                title = "Water usage for each Parcel index in Cambridge",
                subtitle = "Official 2019 Boundaries",
                caption = "Data source: City of Cambridge, MA"
            )
        
        ggplotly(x)
        
    })
    
    # Output 3_c: Plotly GHG map
    
    output$ghg_map <- renderPlotly ({
        
        map_type <- switch(input$ghg_map_type,
                           ghg_intensity = energy_map$parcel_ghg_intensity,
                           ghg_total = energy_map$parcel_ghg_emission)
        
        x <-
            energy_map %>%
            ggplot(aes(fill = map_type)) +
            scale_fill_gradient(name = "colors are in log scale",
                                trans = "log",
                                low = "white",
                                high = "#F46161") +
            geom_sf() +
            labs(
                title = "Greenhouse gas emissions for each Parcel index in Cambridge",
                subtitle = "Official 2019 Boundaries",
                caption = "Data source: City of Cambridge, MA"
            )
        
        ggplotly(x)
        
    })
    
    # Output 3_d: Regression line on multifamily housing and year built
    
    output$regression <- renderPlot({
        
        min_built = input$reg_year_built[1]
        max_built = input$reg_year_built[2]
        selected = input$reg_plot_type
        
        energyuse %>%
            filter(report_type != "Child" & reporting_year == 2018) %>%
            mutate(total_kbtu = as.numeric(source_energy_use_k_btu)) %>%
            filter(primary_property_type_self_selected == selected,
                   year_built > min_built & year_built < max_built) %>%
            ggplot(aes(x = year_built, y = total_kbtu)) +
            geom_point() + 
            geom_smooth(method = "lm") +
            theme(legend.position = "none")
        
    })
    
    # Output 4 cambridge image
    output$about_img <- renderImage({
        filename <- normalizePath(file.path(".",
                                            paste("cambridge.png")))
        
        # Return a list containing the filename
        list(src = filename)
    }, deleteFile = FALSE)
    
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