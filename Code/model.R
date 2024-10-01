source("Code/load_model.R")

test_data_path <- paste0(base_path, "/Test/test_data.csv")
test_data <- read_csv(test_data_path)

data <- tibble(
  text_column = c(
    "The staff were very helpful and kind. I loved my experience.",
    "The wait was awful, the staff were rude and told me to stop complaining."
  )
)

# Analyse emotions in a dataframe
model_emotions_tbl(data, "text_column")

# Analyse emotions in a single text string
model_emotions_text("The staff were very helpful and kind.")

# Analyse sentiment in a dataframe
model_sentiment_tbl(data, "text_column")

# Analyse sentiment in a dataframe
model_sentiment_tbl(data, "text_column")

# Analyse sentiment in a single text string
model_sentiment_text(
  "The wait was awful, the staff were rude and told me to stop complaining."
)

