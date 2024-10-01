library(tibble)
library(stringr)
library(dplyr)

clean_pos_neg <- function(my_var) {
  clean <- tibble(my_var) |>
    mutate(my_var = str_to_lower(my_var)) |>
    mutate(my_var = str_remove_all(my_var, "xa0")) |>
    mutate(my_var = str_remove_all(my_var, "\\\\n")) |>
    mutate(my_var = str_replace_all(my_var, "\\\\", "")) |>
    mutate(my_var = str_remove_all(my_var, "[0-9+$]")) |>
    mutate(my_var = str_replace_all(my_var, "-", "")) |>
    mutate(my_var = str_replace_all(my_var, "'", "")) |>
    mutate(my_var = str_replace_all(my_var, "’", "")) |>
    mutate(my_var = str_replace_all(my_var, "\\[", "")) |>
    mutate(my_var = str_replace_all(my_var, "\\]", "")) |>
    mutate(my_var = str_squish(my_var)) |>
    mutate(my_var = str_split(my_var, ","))
  return(clean$my_var)
}
