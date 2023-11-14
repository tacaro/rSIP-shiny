#' @param test_dataset test dataset to use
#' @param d_t dbl incubation time in days
#' @param f_label strength of the SIP label to highlight in at%
#' @param xlimits character vector: of x axis limits for plot
#' @param include_legend logical: does the plot include the legend?

require(tidyverse)

plot_rel_error_inc <- function(test_dataset, d_t, f_label, xlimits, include_legend = TRUE) {
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
    filter(FL == f_label) |> 
    group_by(dt) |> 
    filter(rel_error == min(rel_error))
  
  minimum_dt <- minimums |>
    filter(dt == d_t) |> 
    pull(TD.days)
  #>>>
  
  test_dataset %>%
    # Argument input here to filter dataset to correct incubation time:
    filter(FL == f_label) |> 
    ggplot() +
    aes(
      x = TD.days,
      y = rel_error,
      color = as.factor(dt)
    ) +
    annotate(geom = "segment", x = lower_lim, xend = lower_lim, y = 0, yend = 0.5, color = "gray") +
    annotate(geom = "segment", x = upper_lim, xend = upper_lim, y = 0, yend = 0.5, color = "gray") +
    geom_line(linewidth = 1) +
    # Scale color and fill
    scale_color_viridis_d(option = "magma", begin = 0.1, end = 0.9) +
    # Secondary axis with ticks marked
    scale_x_continuous(
      sec.axis = dup_axis(
        breaks = c(round(upper_lim, 1), round(minimum_dt, 1), round(lower_lim, 1))
      )
    ) +
    geom_segment(
      data = minimums |> filter(dt == d_t),
      aes(
        x = TD.days,
        xend = TD.days,
        y = 0,
        yend = 50,
        color = as.factor(dt)
      ),
      alpha = 0.7
    ) +
    geom_point(
      data = minimums,
      aes(fill = as.factor(dt)),
      shape = 21,
      color = "black",
      fill = NA,
      show.legend = FALSE,
      size = 2.5,
      stroke = 1
    ) +
    scale_y_continuous(labels = scales::percent) + 
    coord_cartesian(
      ylim = c(0, 0.5),
      xlim = xlimits,
      expand = FALSE
    ) +
    labs(
      x = latex2exp::TeX("Generation Time (Days)"),
      y = latex2exp::TeX("Relative Error (%) =     $\\frac{\\sigma_{\\mu}}{\\mu}$"),
      color = "Incubation Time",
      title = paste0("Label = ", f_label, "%")
    ) +
    theme_bw() +
    theme(
      legend.position = if_else(include_legend, "bottom", "NA"),
      axis.text.x.top = element_text(angle = 45, hjust = 0),
      axis.title.x.top = element_blank(),
      panel.border = element_rect(color = "black", size = 1, fill = NA),
      axis.text = element_text(face = "bold", color = "black"),
      axis.title = element_text(face = "bold", color = "black"),
      panel.grid = element_blank()
    )
}