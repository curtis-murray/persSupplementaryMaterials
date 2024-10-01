#' Find the posterior probability of emotions of an input text
#'
#' @param text Input text
#'
#' @return
#' @export
#'
#' @examples
#' model_emotions_text("The food was cold and bland")
#' model_emotions_text("I can't thank the nurses enough")

model_emotions_text <- function(text){
  tibble(text = text) %>%
    model_emotions_tbl("text")
}
