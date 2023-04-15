#' @param test_dataset test dataset to use
#' @param d_t dbl incubation time in days
#' @param f_label strength of the SIP label to highlight in at%
#' @param xlimits character vector: of x axis limits for plot
#' @param include_legend logical: does the plot include the legend?

require(tidyverse)
plotly_rel_error <- function(test_dataset, d_t, f_label, xlimits = c(0, 300), include_legend = TRUE) {
  
  plot <- test_dataset %>%
    # Argument input here to filter dataset to correct incubation time:
    filter(dt == d_t) |> 
    filter(FL > 15) |> 
    ggplot() +
    aes(
      x = TD.days,
      y = rel_error,
      color = as.factor(FL)
    ) +
    geom_line(linewidth = 1) +
    geom_hline(yintercept = 0.5, linetype = "dotted") +
    scale_color_viridis_d(option = "plasma", begin = 0.1, end = 0.9) +
    # Secondary axis with ticks marked
    scale_x_continuous(name = "Generation Time (Days)") +
    scale_y_continuous(name = "Relative Error (σµ/µ) (%)", labels = scales::percent) + 
    coord_cartesian(
      ylim = c(0, 0.5),
      xlim = xlimits,
      expand = FALSE
    ) +
    labs(
      color = "Tracer Strength (D at. %)",
      title = paste("Range of Growth Rate Quantification:"),
      subtitle = paste(d_t, "day incubation time")
    ) +
    theme_bw() +
    theme()
  
  ggplotly(plot) |> 
    layout(
      title = list(text = paste0('Range of Growth Rate Quantification:',
                                 '<br>',
                                 '<sup>',
                                 'Incubation Time:',
                                 d_t, " days",
                                 '</sup>'))
    ) |> 
    config(.Last.value, mathjax = 'cdn')
}