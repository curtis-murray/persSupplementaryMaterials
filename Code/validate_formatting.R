library(testthat)
library(tidyverse)
library(tibble)
library(tidytext)
library(lubridate)

source("config")
source("Code/helpers.R")

# Source helpers.R if it exists, otherwise throw an error
if (file.exists("Code/helpers.R")) {
  source("Code/helpers.R")
} else {
  stop("helpers.R file not found in the Code directory")
}

# Check if base_path exists
if (!dir.exists(base_path)) {
  stop("Base path '", base_path, "' does not exist")
}

# Check if narratives_path exists
if (!file.exists(narratives_path)) {
  stop("Data file '", narratives_path, "' does not exist")
}

# Read the CSV file
narratives <- tryCatch(
  read_csv(narratives_path),
  error = function(e) {
    stop("Error reading CSV file: ", e$message)
  }
)

# Check for required columns
required_columns <- c("Story", "Emotion", "Title")
missing_columns <- setdiff(required_columns, colnames(narratives))
if (length(missing_columns) > 0) {
  stop("Missing required columns: ", paste(missing_columns, collapse = ", "))
}

# Check column types and formats
if (!is.character(narratives$Story)) {
  stop("'Story' column must be of type character")
}

if (!is.character(narratives$Title)) {
  stop("'Title' column must be of type character")
}

test_emotion_processing <- function(narratives) {
  # Example usage:
  valid_emotions <- tibble(
    Emotions = c(
      "['happy', 'excited']",
      "['Sad']",
      "['Anxious', 'Nervous', 'Worried']",
      "[]"
    )
  )
  tryCatch(
    {
      narratives_emotions_unnested <- narratives |>
        map_at(c("Emotion"), clean_pos_neg) |>
        as_tibble() |>
        unnest(Emotion) |>
        filter(Emotion != "") |>
        mutate(Emotion = str_squish(Emotion))
      if (nrow(narratives_emotions_unnested) == 0) {
        stop("No valid emotions after processing")
      }
    },
    error = function(e) {
      cat("Format emotions as shown in the below example")
      cat(valid_emotions)
      stop("Error processing emotions: ", e$message)
    }
  )
}

test_emotion_processing(narratives)

# If we've made it this far, all checks have passed
cat("Data loaded and validated successfully")
