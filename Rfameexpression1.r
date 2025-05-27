#R pRogram executed from jupiteRlab
#chaRting one fameexpRession
#can pRobably be improved by u ???
# eRik Oct 2024



# Load required libraries
library(jsonlite)
library(dplyr)
library(ggplot2)
library(scales)
library(lubridate)
library(tidyr)

 
famebase <- "$REFERTID/data/fornavn.db"  # Adjust with your actual filename
famesoek <- "ERIK+EIRIK"
famedato <- "date 2000 to *"

# Construct the command with correctly quoted arguments
command <- paste("ssh sl-fame-1.ssb.no '",              
                 "$REFERTID/system/myfame/api/getfameexpr \"", famebase, 
                 "\" \"", famesoek, "\" \"", famedato, "\"'", sep="")

# Print the command to console for debugging
cat("Constructed Command:\n", command, "\n")

# Execute the command and capture the output
output <- system(command, intern = TRUE, ignore.stderr = FALSE)


  # Get the HOME environment variable
    home_dir <- Sys.getenv("HOME")

  # Construct the full path using the home directory
    json_file_path <- file.path(home_dir, ".GetFAME/getfameexpr.json")
    
   
  # Read the JSON file
    json_data <- fromJSON(json_file_path)

# Now read the actual data from the result file if it exists

    series_data =json_data  # Read the series data from the file
    
 
    # Initialize an empty data frame to store all data
    df_all <- data.frame()

    # Assuming the series data is structured similarly as before
    for (series in series_data$Series) {
        series_name <- series$Name
        
        # Convert each observation series to a data frame
        df <- as.data.frame(series$Observations)
        
        # Add the series name to the data frame
        df <- df %>% mutate(Series = series_name)
        
        # Combine the current data frame with the main one
        df_all <- bind_rows(df_all, df)
    }

    # Convert the Date column to datetime (if available) or work with Epo
    df_all$Date <- as_datetime(df_all$Date)

    # Extract the Epoch times and Values from the Epo field
    df_all <- df_all %>%
        mutate(Epoch = as_datetime(sapply(Epo, function(x) x[1] / 1000)),  # Convert from milliseconds to seconds
               Value = sapply(Epo, function(x) x[2]))

    # Plotting the data using ggplot2
    ggplot(df_all, aes(x = Epoch, y = Value, color = Series)) +
        geom_line() +
        scale_x_datetime(labels = date_format("%Y"), date_breaks = "1 year") +
        labs(title = paste("DemoChart:", famesoek, "-", famedato),
             x = "Years", y = "% Values") +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
        guides(color = guide_legend(title = "Series")) +
        scale_y_continuous(labels = comma)
