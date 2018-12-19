# load relevant libraries
library(shiny)
library(dplyr)
library(tools)
library(shinythemes)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(tidyverse)
library(shinythemes)
library(tools)
library(ipeds)
library(maps)
library(shinydashboard)
library(leaflet.extras)
library(htmltools)


# load our data frame
load("sysdata.rda")

# run app
runApp()
