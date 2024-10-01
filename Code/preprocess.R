library(tidyverse)
library(tidytext)
library(lubridate)

source("Code/helpers.R")
source("config")

narratives <- read_csv(narratives_path)

narratives <- narratives |>
  select(Title, Story, Emotion) |>
  group_by_all() |>
  summarise() |>
  ungroup() |>
  mutate(ID = seq_len(n()))

# Clean and tokenize
tokens <- narratives |>
  mutate(Story = str_to_lower(Story)) |>
  mutate(Story = str_replace_all(Story, "xa0", " ")) |>
  mutate(Story = str_replace_all(Story, "\\\\n", " ")) |>
  mutate(Story = str_replace_all(Story, "\\\\", "")) |>
  mutate(Story = str_remove_all(Story, "[0-9+$]")) |>
  mutate(Story = str_replace_all(Story, "-", "")) |>
  mutate(Story = str_replace_all(Story, "'", "")) |>
  mutate(Story = str_replace_all(Story, "’", "")) |>
  mutate(Story = str_replace_all(Story, "[^[:alnum:]]", " ")) |>
  unnest_tokens(word, Story)

# Find stop words
my_stop_words <- tokens |>
  group_by(word) |>
  summarise(count = n()) |>
  filter(count < 5) |>
  select(word)

# Remove stop words
tokens <- tokens |>
  anti_join(my_stop_words)

# Data to train hSBM on
train <- tokens |>
  group_by(ID, Title, Emotion) |>
  summarise(Story = str_flatten(word, collapse = " ")) |>
  select(ID, Title, Story, Emotion) |>
  group_by(Title, Story, ID, Emotion) |>
  summarise(ID = ID[1]) |>
  arrange(ID) |>
  ungroup() |>
  mutate(newID = seq_len(n())) |>
  mutate(
    Original_Title = Title,
    Title = paste(Title, " ", "(", ID, ")", sep = "") # Ensures unique titles
  )

train_no_stop <- train |>
  unnest_tokens(word, Story) |>
  anti_join(stop_words, by = "word") |>
  group_by(ID, newID, Title, Original_Title, Emotion) |>
  summarise(Story = paste0(word, collapse = " "))

narratives_processed <- train_no_stop |>
  left_join(
    narratives |>
      select(Original_Title = Title, Emotion, Story_Raw = Story, ID),
    by = c("Original_Title", "Emotion", "ID")
  )

narratives_processed |>
  write_csv(paste0(base_path, "/narratives_processed.csv"))
