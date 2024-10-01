#' Find the posterior probability of emotions of texts in a tibble
#'
#' @param tbl Tibble with text column
#' @param input The column with the text
#' @param batch_size If needed, batching may help to speed things up. E.g. batch_size = 100
#' @param quiet When batching large data sets it may be useful to see how many batches have been processed
#' @param show_prior Show the prior probabilities for each emotion
#' @param show_positivity Show the posterior density for overall positivity/negativity
#'
#' @return A tibble with the original text, the sentiment, and the posterior probability of the sentiment
#' @export
#'
#' @examples
#' model_emotions_tbl(test_data, "Report")
#' model_emotions_tbl(tibble(text = c("The food was cold and bland", "I can't thank the nurses enough")), "text")
#'
#' @import dplyr
model_emotions_tbl <- function(tbl, input, batch_size = NULL, quiet = TRUE, show_prior = FALSE, show_positivity = FALSE) {
  stopifnot("Input error: `tbl' should be a tibble" = is_tibble(tbl))
  stopifnot("Input error: `input' should be a string" = is.character(input))
  stopifnot("Input error: `input' is not a column of tbl" = input %in% names(tbl))
  stopifnot("Input error: input column should be of type character" = input %in% (select_if(tbl, is.character) %>% names()))
  tbl_len <- nrow(tbl)
  if (is.null(batch_size)) batch_size <- tbl_len
  tbl_itr <- 1
  out <- tibble()
  while ((tbl_itr - 1) * batch_size < tbl_len) {
    if (!quiet) print(paste("Processing batch: ", tbl_itr, " of ", ceiling(tbl_len / batch_size)), sep = "")
    out <- bind_rows(out, tbl[((tbl_itr - 1) * batch_size + 1):min(tbl_len, tbl_itr * batch_size), ] %>%
      mutate(DOC_ID_model_emotions_tbl = 1:n()) %>%
      mutate(Report_tmp = get(input)) %>%
      group_by(DOC_ID_model_emotions_tbl, Report_tmp) %>%
      mutate(group_id = ifelse((1:n()) == 1, 1, 0)) %>%
      ungroup() %>%
      mutate(group_id = cumsum(group_id) * group_id) %>%
      unnest_tokens(word, Report_tmp, drop = FALSE) %>%
      left_join(model, by = "word", relationship = "many-to-many") %>%
      drop_na() %>%
      group_by(DOC_ID_model_emotions_tbl, Report_tmp, Emotion, prior, group_id) %>%
      summarise(
        ls = sum(log(likelihood)),
        likelihood = prod(likelihood), .groups = "keep"
      ) %>%
      mutate(ak = ls + log(prior)) %>%
      group_by(DOC_ID_model_emotions_tbl, Report_tmp) %>%
      mutate(
        A = max(ak),
        denom = A + log(sum(exp(ak - A))),
        ll = ls + log(prior) - denom,
        post = exp(ls + log(prior) - denom)
      ) %>%
      group_by(DOC_ID_model_emotions_tbl, Report_tmp) %>%
      select(Report_tmp, Emotion, Prior = prior, Posterior = post, group_id) %>%
      left_join(emotion_clustering %>% select(-count), by = "Emotion") %>%
      group_by(DOC_ID_model_emotions_tbl, Report_tmp, Cluster) %>%
      mutate(Cluster_Posterior = sum(Posterior)) %>%
      mutate(Posterior = ifelse(is.na(Posterior), Prior, Posterior)) %>%
      group_by(DOC_ID_model_emotions_tbl, Report_tmp) %>%
      arrange(group_id, -Posterior) %>%
      ungroup() %>%
      select(-group_id, -DOC_ID_model_emotions_tbl)) %>%
      ungroup()
    tbl_itr <- tbl_itr + 1
  }
  colnames(out)[1] <- input
  if (!show_prior) out <- out %>% select(-Prior)
  if (!show_positivity) out <- out %>% select(-c(Cluster, Cluster_Posterior))
  left_join(tbl, out, by = input)
}

# Test to add:
# model_emotions_tbl(tibble(word = rep("public",10)), "word") %>% filter(Emotion == "in pain") should all have same posterior
