#' @param test_dataset test dataset to use
#' @param d_t dbl incubation time in days
#' @param f_label strength of the SIP label to highlight in at%
#' @param xlimits character vector: of x axis limits for plot
#' @param include_legend logical: does the plot include the legend? Yes by default
#' @param include_caption logical: does the plot include the descriptive caption? Yes by default

require(tidyverse)

plotly_rel_error_at2H <- function(test_dataset, d_t, xlimits = c(0, 50)) {
  
  plot <- test_dataset %>%
    # Argument input here to filter dataset to correct incubation time:
    filter(dt == d_t) |> 
    filter(FL > 15) |> 
    ggplot() +
    aes(
      x = F2,
      y = rel_error,
      color = as.factor(FL)
    ) +
    geom_line(linewidth = 1) +
    geom_hline(yintercept = 0.5, linetype = "dotted") +
    scale_color_viridis_d(end = 0.9) +
    # Set axis labels here. Labs will cause it to crash.
    scale_x_continuous(name = "Biomass (D at. %)") +
    scale_y_continuous(name = "Relative Error (σµ/µ) (%)", labels = scales::percent) + 
    coord_cartesian(
      ylim = c(0, 0.5),
      xlim = xlimits,
      expand = FALSE
    ) +
    labs(
      color = "Tracer Strength (D at. %)",
      title = paste("Range of CD% Quantification:"),
      subtitle = paste(d_t, "day incubation time")) +
    theme_bw() +
    theme(
    )
    
    
  ggplotly(plot) |> 
    layout(
      title = list(text = paste0('Range of CD% Quantification:',
                                 '<br>',
                                 '<sup>',
                                 'Note that CD% precision does not depend on incubation time',
                                 '</sup>')),
      xaxis = list(
        title = TeX("^2F_{Biomass}")),
      yaxis = list(
        title = TeX("\\text{Relative Error } \\left(\\frac{\\sigma_{\\mu}}{\\mu} \\right)"))
    ) |> 
    config(
      mathjax = "cdn"
    )
}




