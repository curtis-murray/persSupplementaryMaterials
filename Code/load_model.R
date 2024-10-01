library(tidyverse)
library(tidytext)

source("config")

model_path <- paste0(base_path, "/Results/Model/model.rda")
load(model_path)

emotion_clustering <- read_csv(paste0(base_path, "/emotion_clustering.csv"))

source("Code/model_emotions_tbl.R")
source("Code/model_emotions_text.R")
source("Code/model_sentiment_tbl.R")
source("Code/model_sentiment_text.R")
