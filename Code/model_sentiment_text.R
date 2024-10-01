#' Find the posterior probability of sentiment, either positive or negative, of an input text
#'
#' @param text Text to find the sentiment of
#'
#' @return
#' @export
#'
#' @examples
#' model_sentiment_text("The food was cold and bland")
#' model_sentiment_text("I can't thank the nurses enough")

model_sentiment_text <- function(text){
  tibble(text = text) %>%
    model_sentiment_tbl("text")
}
