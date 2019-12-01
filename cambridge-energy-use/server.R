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
    
    energy_source <-
        read_rds(path = "shiny-data/energy_source.rds")
    
    # Page 3 objects
    
    energy_map <-
        read_rds(path = "shiny-data/energy_map.rds")
    
    # Output 1_1: Cambridge Neighborhoods Map
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
    
    # Output 1_2: Plotly Cambridge Parcels Index Map
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
    
    # Output 2_2_a: Energy use bar plot
    
    output$electric_use <- renderPlot ({
        
        energyuse %>%
            filter(reporting_year == input$energy_year, 
                   report_type != "Child", 
                   site_energy_use_k_btu != "NA") %>%
            group_by(property_type) %>%
            summarize(sum_kBtu = sum(site_energy_use_k_btu)) %>%
            mutate(total = sum(sum_kBtu)) %>%
            ggplot(aes(x = property_type, y = sum_kBtu)) +
            geom_col(aes(fill = property_type)) +
            labs(
                title = "Electricity usage",
                subtitle = "From all sources, by group",
                x = "",
                y = "Total kBtu"
            ) +
            theme(legend.position = "none")
    })
    
    # Output 2_2_a: Renewable use bar plot
    
    output$water_use <- renderPlot ({
        
        energyuse %>%
            filter(reporting_year == input$energy_year, 
                   report_type != "Child", 
                   water_use_all_water_sources_kgal != "NA") %>%
            group_by(property_type) %>%
            summarize(sumKgal = sum(water_use_all_water_sources_kgal)) %>%
            mutate(total = sum(sumKgal)) %>%
            mutate(percentage = sumKgal / total) %>%
            ggplot(aes(x = property_type, y = sumKgal)) +
            geom_col(aes(fill = property_type)) +
            labs(
                title = "Water usage",
                subtitle = "From all sources, by group",
                x = "",
                y = "Total kgal"
            ) +
            theme(legend.position = "none")
    })
    
    # Output 2_3_a: Table
    output$energy_source_table <- DT::renderDataTable({
        DT::datatable(iris, options = list(lengthMenu = c(5, 30, 50), pageLength = 5))
    })
    
    # Output 2_3_b: Energy source treemap
    
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
    
    # Output 3_a: Plotly Cambridge Parcel index
    
    output$energy_map <- renderPlotly ({
        
        map_type <- switch(input$map_type,
                              energy_total = energy_map$parcel_energy_use[2:286],
                              energy_intensity = energy_map$parcel_energy_intensity[2:286],
                              ghg_emission_total = energy_map$parcel_ghg_emission[2:286],
                              ghg_emission_intensity = energy_map$parcel_ghg_intensity[2:286],
                              water_total = energy_map$water_use_all_water_sources_kgal[2:286],
                              water_intensity = energy_map$water_intensity_all_water_sources_gal_ft2[2:286])
        
        x <-
            energy_map %>%
            # Removing outliar
            filter(PCIX_NO != "52A") %>%
            ggplot() +
            geom_sf(aes(fill = map_type)) +
            labs(
                title = "Cambridge MA Parcels",
                subtitle = "Official 2019 Boundaries",
                caption = "Data source: City of Cambridge, MA"
            )  
        
        ggplotly(x)
    
    })
    
    # Output 4
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
