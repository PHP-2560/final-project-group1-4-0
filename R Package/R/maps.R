#' plot_state
#'
#' Graphs the an outline of the state that the inputted school is located in for the top 200 nationally ranked universities or colleges in the United States.
#'
#' @param SchoolName The complete name of the college or university being plotted for the respective state that must be present in the dataset.
#' @return A map of a single state in the US with an abbreviated label of the state pasted in the interior.
#' @examples
#' plot_state('Brown University')
#' plot_state('Princeton University')
#' @import tidyverse
#' @import usmap
#' @import ggplot2
#' @import dplyr
plot_state <- function(university) {
    #load data and check if university name is there
    load("R/sysdata.Rdata")
    if (!(university %in% df$University)){
      return("This is not a valid university in the dataset")
    }
    df.copy <- df
    df.copy$Location <- as.character(df.copy$Location)
    df.copy$state <- substr(df.copy$Location, nchar(df.copy$Location) - 1, nchar(df.copy$Location))
    state <- df.copy %>%
      filter(University == university) %>%
      select(state)
    plot_usmap(include = c(state), labels = T) + labs(title = "US State Close-up")
}


#' plot_city
#'
#' Graphs a map of the United States and places a black dot where the inputted school is geographically located.
#'
#' @param schoolName The complete name of the college or university that is being plotted that must be present in the dataset.
#' @return A map of the United States with a black dot of the college or university. A few summary statistics are given underneath the graph, such as whether the school is public or private, the school rank, location, and annual tuition.
#' @examples
#' plot_city('Brown University')
#' plot_city('Princeton University')
#' @import tidyverse
#' @import ggmap
#' @import ggplot2
#' @import gridExtra
plot_city <- function(university) {

    #load data and check if university name is there
    load("R/sysdata.Rdata")
    if (!(university %in% df$University)){
      return("This is not a valid university in the dataset")
    }

    # Creating column for state that the school is located in
    df.copy <- df
    df.copy$Location <- as.character(df.copy$Location)
    df.copy$state <- substr(df.copy$Location, nchar(df.copy$Location) - 1, nchar(df.copy$Location))

    for (i in 1:length(df.copy$Location)) {
        df.copy$city[i] = strsplit(df.copy$Location, split = ",")[[i]][1]
    }

    # reading in a csv file with thousands of cities in the US and their respective geographical coordinates
    cityData <- as.tbl(read.csv("R/USCities.csv")) %>% select(city, state_id, lat, lng) %>% rename(latitude = lat, longitude = lng) %>% mutate(Location = paste(city,
        ", ", state_id, sep = ""))

    # Getting the coordinates of each school by joining the dataframe with the csv file
    df.copy1 <- left_join(df.copy, cityData, by = "Location")

    states <- map_data("state")

    coordinates <- df.copy1 %>% filter(University == university) %>% select(longitude, latitude)
    coordinates <- unlist(coordinates)
    # this grabs the correct coordinates for the user-inputted school

    Stats <- df.copy1 %>% filter(University == university)

    schoolPlot <- ggplot(data = states) +
      geom_polygon(aes(x = long, y = lat, fill = region, group = group), color = "white") + coord_fixed(1.3) +
      guides(fill = FALSE) +
      geom_point(aes(x = coordinates[1], y = coordinates[2]), size = 3) +
      labs(title = paste("US School Location of", university)) +
      theme(axis.title.x = element_blank(), axis.title.y = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(), axis.ticks = element_blank())

    SummaryTable <- data.frame(Stats$University, Stats$School_Type, Stats$Location, Stats$Tuition, which())
    names(SummaryTable) <- c("School Name", "School Type", "Location", "Tuition")

    tt <- ttheme_default(colhead = list(fg_params = list(parse = TRUE)))
    tbl <- tableGrob(SummaryTable, rows = NULL, theme = tt)
    # Plot chart and table into one object
    grid.arrange(schoolPlot, tbl, nrow = 2, as.table = TRUE, heights = c(3, 1))

}
