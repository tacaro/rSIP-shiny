#' @param test_dataset test dataset to use
#' @param d_t dbl incubation time to highlight in days
#' @param f_label strength of the SIP label to highlight in at%

tabulate_data <- function(test_dataset, d_t, f_label) {
  upper_lim <- test_dataset |> 
    filter(dt == d_t) |> 
    filter(rel_error <= 0.5) |>
    filter(FL == f_label) |> 
    pull(TD.days) |> 
    min()
  
  upper_lim_mu_d <- test_dataset |> 
    filter(dt == d_t) |> 
    filter(rel_error <= 0.5) |>
    filter(FL == f_label) |> 
    pull(mu.d) |> 
    min()
  
  lower_lim <- test_dataset |> 
    filter(dt == d_t) |> 
    filter(rel_error <= 0.5) |>
    filter(FL == f_label) |> 
    pull(TD.days) |> 
    max()
  
  lower_lim_mu_d <- test_dataset |> 
    filter(dt == d_t) |> 
    filter(rel_error <= 0.5) |>
    filter(FL == f_label) |> 
    pull(mu.d) |> 
    max()
  
  #>>>
  # find the error minima (optima)
  minimums <- test_dataset |> 
    filter(dt == d_t) |> 
    group_by(FL) |> 
    filter(rel_error == min(rel_error))
  
  minimum_label <- minimums |>
    filter(FL == f_label) |> 
    pull(TD.days)
  
  # CALCULATE at2H LIMITS
  upper_lim_at2H <- test_dataset |> 
    filter(dt == d_t) |> 
    filter(rel_error <= 0.5) |>
    filter(FL == f_label) |> 
    pull(F2) |> 
    min()
  
  lower_lim_at2H <- test_dataset |> 
    filter(dt == d_t) |> 
    filter(rel_error <= 0.5) |>
    filter(FL == f_label) |> 
    pull(F2) |> 
    max()
  
  return(
    dplyr::tibble(
      incubation_time = d_t,
      label_strength = f_label,
      a_w = test_dataset |> select(a) |> unique() |> pull(),
      lower_limit_at2H = lower_lim_at2H,
      upper_limit_at2H = upper_lim_at2H,
      upper_limit_gen_time = upper_lim,
      lower_limit_gen_time = lower_lim,
      upper_lim_mu = upper_lim_mu_d,
      lower_lim_mu = lower_lim_mu_d,
    )
  )
  
}
