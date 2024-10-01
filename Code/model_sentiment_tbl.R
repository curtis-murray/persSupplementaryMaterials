#' Find the posterior probability of sentiment, either positive or negative, of texts in a tibble
#'
#' @param tbl Tibble with text column
#' @param input The column with the text
#' @param batch_size If needed, batching may help to speed things up. E.g. batch_size = 100
#' @param quiet When batching large data sets it may be useful to see how many batches have been processed
#'
#' @return A tibble with the original text, the sentiment, and the posterior probability of the sentiment
#' @export
#'
#' @examples
#' model_sentiment_tbl(test_data, "Report")
#' model_sentiment_tbl(tibble(text = c("The food was cold and bland", "I can't thank the nurses enough")), "text")
#'
model_sentiment_tbl <- function(tbl, input, batch_size = NULL, quiet = TRUE){

  model_emotions_tbl(tbl, input, batch_size, quiet, show_positivity = TRUE) %>%
    select(-c(Emotion, Posterior)) %>%
    group_by_all() %>%
    summarise() %>%
    ungroup() %>%
    rename(Sentiment = Cluster, Posterior = Cluster_Posterior)
}
