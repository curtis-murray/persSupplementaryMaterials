# Topic Modeling Data Processing Script
#
# This script processes output files from a multilayer/metadata hierarchical topic model
#
# Input files:
# - p_w_tw[level].csv: p(word | word topic) - Word probability given word topic at [level]
# - p_m_tm[level].csv: p(meta | meta topic) - emotion probability given emotion topic [level]
# - p_tw_d[level].csv: p(topic | document) - Topic probability given document [level]
# - p_tm_d[level].csv: p(meta topic | document) - emotion topic probability given document
# - words_all.csv: List of all words
# - docs_all.csv: List of all documents
# - meta_all.csv: List of all metadata
#
# The script performs the following operations:
# 1. Reads and processes word data, document data, and metadata
# 2. Processes word | topic probabilities, creating a tidy format
# 3. Processes emotion | emotion topic probabilities
# 4. Processes topic | document probabilities
# 5. Processes emotion-topic | document probabilities
# 6. Saves all processed data in a 'Clean' subdirectory
#
# Output files (in 'Clean' subdirectory):
# - tidy_topics.csv: Processed word | topic probabilities
# - tidy_topics_meta.csv: Processed emotions | emotion topic probabilities
# - tidy_topics_docs.csv: Processed topic | document probabilities
# - tidy_topics_meta_docs.csv: Processed emotion-topic | document probabilities

# Load required libraries
library(tidyverse)
library(tidytext)

# Set the base path for data files
source("config")
results_path <- paste0(base_path, "/Results")
clean_results_path <- paste0(results_path, "/Clean")
model_path <- paste0(results_path, "/Model")

# Create Model directory if it doesn't exist
if (!dir.exists(clean_results_path)) {
  dir.create(clean_results_path)
}

# Find all relevant CSV files
p_w_tw_all_path <- list.files(path = results_path, pattern = glob2rx("*p_w_tw*.csv"), full.names = TRUE)
p_m_tm_all_path <- list.files(path = results_path, pattern = glob2rx("*p_m_tm*.csv"), full.names = TRUE)
p_tw_d_all_path <- list.files(path = results_path, pattern = glob2rx("*p_tw_d*.csv"), full.names = TRUE)
p_tm_d_all_path <- list.files(path = results_path, pattern = glob2rx("*p_tm_d*.csv"), full.names = TRUE)
words_all_all_path <- list.files(path = results_path, pattern = "words_all*", full.names = TRUE)

# Read and process words data
words_all <- tibble(words_all_all_path = words_all_all_path) %>%
  mutate(
    words = map(
      words_all_all_path,
      ~ read_csv(.x) %>%
        mutate(word_ID = ...1 + 1, word = `0`) %>%
        select(word_ID, word)
    )
  ) %>%
  unnest(words) %>%
  select(-words_all_all_path)

# Read documents data
docs_all <- read_csv(paste(results_path, "/docs_all.csv", sep = "")) %>%
  transmute(doc_ID = ...1 + 1, document = `0`)

# Read metadata (emotions)
meta_all <- read_csv(paste(results_path, "/meta_all.csv", sep = "")) %>%
  transmute(meta_ID = ...1 + 1, meta = `0`)

# Process topic-word probabilities
tidy_topics <- tibble(p_w_tw_all_path = p_w_tw_all_path) %>%
  mutate(Level = str_extract(p_w_tw_all_path, "(?<=p_w_tw)\\d{1,}")) %>%
  map_at("Level", as.double) %>%
  as_tibble() %>%
  mutate(
    mat = map(
      p_w_tw_all_path,
      ~ read_csv(.x) %>%
        select(word_ID = ...1, everything()) %>%
        mutate(word_ID = word_ID + 1) %>%
        gather("topic", "p", -word_ID) %>%
        mutate(topic = as.numeric(topic) + 1) %>%
        filter(p > 0)
    )
  ) %>%
  ungroup() %>%
  arrange(Level) %>%
  unnest(mat) %>%
  select(-p_w_tw_all_path) %>%
  left_join(words_all, by = "word_ID")


# Save processed topic-word probabilities
write_csv(tidy_topics, paste(clean_results_path, "/tidy_topics.csv", sep = ""))

# Process probabilities emotions | emotion topic
tidy_topics_meta <- tibble(p_m_tm_all_path = p_m_tm_all_path) %>%
  mutate(Level = str_extract(p_m_tm_all_path, "(?<=p_m_tm)\\d{1,}")) %>%
  map_at("Level", as.double) %>%
  as_tibble() %>%
  mutate(
    mat = map(
      p_m_tm_all_path,
      ~ read_csv(.x) %>%
        select(meta_ID = ...1, everything()) %>%
        mutate(meta_ID = meta_ID + 1) %>%
        gather("meta_topic", "p", -meta_ID) %>%
        mutate(meta_topic = as.numeric(meta_topic) + 1) %>%
        filter(p > 0)
    )
  ) %>%
  ungroup() %>%
  arrange(Level) %>%
  unnest(mat) %>%
  select(-p_m_tm_all_path) %>%
  left_join(meta_all, by = "meta_ID")

# Save processed emotions | emotion topic probabilities
write_csv(tidy_topics_meta, paste(clean_results_path, "/tidy_topics_meta.csv", sep = ""))

# Process topic | document probabilities
tidy_topic_docs <- tibble(p_tw_d_all_path = p_tw_d_all_path) %>%
  mutate(Level = str_extract(p_tw_d_all_path, "(?<=p_tw_d)\\d{1,}")) %>%
  map_at("Level", as.double) %>%
  as_tibble() %>%
  mutate(
    mat = map(
      p_tw_d_all_path,
      ~ read_csv(.x) %>%
        select(topic = ...1, everything()) %>%
        mutate(topic = topic + 1) %>%
        gather("doc_ID", "p", -1) %>%
        mutate(doc_ID = as.numeric(doc_ID) + 1) %>%
        full_join(docs_all, by = "doc_ID") %>%
        select(topic, doc_ID, p, document)
    )
  ) %>%
  select(-p_tw_d_all_path) %>%
  unnest(mat)

# Save processed topic | document probabilities
write_csv(tidy_topic_docs, paste(clean_results_path, "/tidy_topics_docs.csv", sep = ""))

# Process emotion-topic | document probabilities
tidy_topic_meta_docs <- tibble(p_tm_d_all_path = p_tm_d_all_path) %>%
  mutate(Level = str_extract(p_tm_d_all_path, "(?<=p_tm_d)\\d{1,}")) %>%
  map_at("Level", as.double) %>%
  as_tibble() %>%
  mutate(
    mat = map(
      p_tm_d_all_path,
      ~ read_csv(.x) %>%
        select(meta_topic = ...1, everything()) %>%
        mutate(meta_topic = meta_topic + 1) %>%
        gather("doc_ID", "p", -1) %>%
        mutate(doc_ID = as.numeric(doc_ID) + 1) %>%
        full_join(docs_all, by = "doc_ID") %>%
        select(meta_topic, doc_ID, p, document)
    )
  ) %>%
  select(-p_tm_d_all_path) %>%
  unnest(mat)

# Save processed emotion-topic | document probabilities
write_csv(tidy_topic_docs, paste(clean_results_path, "/tidy_topics_meta_docs.csv", sep = ""))
