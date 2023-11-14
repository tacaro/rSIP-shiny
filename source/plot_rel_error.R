#' @param test_dataset test dataset to use
#' @param d_t dbl incubation time in days
#' @param f_label strength of the SIP label to highlight in at%
#' @param xlimits character vector: of x axis limits for plot
#' @param include_legend logical: does the plot include the legend?

require(tidyverse)

plot_rel_error <- function(test_dataset, d_t, f_label, xlimits, include_legend = TRUE) {
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
  #>>>
  
  test_dataset %>%
    # Argument input here to filter dataset to correct incubation time:
    filter(dt == d_t) |> 
    ggplot() +
    aes(
      x = TD.days,
      y = rel_error,
      color = as.factor(FL)
    ) +
    annotate(geom = "segment", x = lower_lim, xend = lower_lim, y = 0, yend = 0.5, color = "gray") +
    annotate(geom = "segment", x = upper_lim, xend = upper_lim, y = 0, yend = 0.5, color = "gray") +
    geom_line(linewidth = 1) +
    # Scale color and fill
    scale_color_viridis_d(option = "plasma", begin = 0.1, end = 0.9) +
    # Secondary axis with ticks marked
    scale_x_continuous(
      sec.axis = dup_axis(
        breaks = c(round(upper_lim, 1), round(lower_lim, 1))
      )
    ) +
    geom_segment(
      data = minimums |> filter(FL > 15) |> filter(FL == f_label),
      aes(
        x = TD.days,
        xend = TD.days,
        y = 0,
        yend = 50,
        color = as.factor(FL)
      ),
      alpha = 0.7
    ) +
    geom_point(
      data = minimums |> filter(FL > 15),
      aes(fill = as.factor(FL)),
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
      color = "Tracer Strength (D at. %)",
      title = paste(d_t, "day incubation time"),
      caption = paste(
        "Quantification of growth: \n",
        "Generation times: between", round(upper_lim, 1), "and", round(lower_lim, 1), "days, \n",
        "Growth rate: between", round(lower_lim_mu_d, 3), "and", round(upper_lim_mu_d, 3), "days ^-1"
        )
    ) +
    theme_classic() +
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