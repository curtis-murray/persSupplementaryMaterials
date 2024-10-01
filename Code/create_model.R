library(tidyverse)
library(tidytext)

source("Code/helpers.R")
source("config")

# Set paths
results_path <- paste0(base_path, "/Results/")
model_path <- paste0(results_path, "Model/")

# Create Model directory if it doesn't exist
if (!dir.exists(model_path)) {
  dir.create(model_path)
}

# Read necessary data
docs_all <- read_csv(paste0(results_path, "docs_all.csv")) |>
  transmute(Doc_ID = ...1 + 1, Doc = `0`)
words_all <- read_csv(paste0(results_path, "words_all.csv")) |>
  transmute(Word_ID = ...1 + 1, word = `0`)

narratives_processed <- read_csv(paste0(base_path, "/narratives_processed.csv"))

# load p(word | topic) at level 0
p_w_tw0 <- read_csv(paste0(results_path, "p_w_tw0.csv")) |>
  select(-...1)

# load p(topic | document) at level 0
p_tw_d0 <- read_csv(paste0(results_path, "p_tw_d0.csv")) |>
  select(-...1)

# Unnest emotions
narratives_emotions_unnested <- narratives_processed |>
  map_at(c("Emotion"), clean_pos_neg) |>
  as_tibble() |>
  unnest(Emotion) |>
  filter(Emotion != "") |>
  mutate(Emotion = str_squish(Emotion))

# Calculate p(document | emotion)
p_d_e0 <- narratives_emotions_unnested |>
  right_join(docs_all, by = c("Title" = "Doc")) |>
  select(Doc_ID, Emotion) |>
  group_by(Doc_ID) |>
  mutate(fill = 1) |>
  ungroup() |>
  pivot_wider(
    names_from = "Emotion",
    values_from = fill,
    values_fill = 0
  ) |>
  full_join(
    docs_all |> select(Doc_ID),
    by = "Doc_ID"
  ) |>
  arrange(Doc_ID) |>
  mutate(across(everything(), ~ replace_na(.x, 0))) |>
  select(-Doc_ID) |>
  mutate(across(everything(), ~ .x / sum(.x)))

# Calculate p(word | emotion) (see appendix of paper for more details)
p_w_e0 <- as.matrix(p_w_tw0) %*% as.matrix(p_tw_d0) %*% as.matrix(p_d_e0) |>
  as_tibble() |>
  mutate(word = words_all$word) |>
  select(word, everything())

# Calculate p_e0
p_e0 <- narratives_emotions_unnested |>
  group_by(Emotion) |>
  summarise(count = n()) |>
  mutate(p_s = count / sum(count)) |>
  right_join(
    tibble(
      Emotion = colnames(p_w_e0)[-1],
      Emotion_ID = seq_along(colnames(p_w_e0)[-1])
    ),
    by = "Emotion"
  ) |>
  arrange(Emotion_ID)

# Create model
model <- p_w_e0 |>
  pivot_longer(cols = -word, names_to = "Emotion", values_to = "likelihood") |>
  full_join(p_e0) |>
  select(word, Emotion, likelihood, prior = p_s)

# Write model to csv
write_csv(model, paste0(model_path, "/model.csv"))
