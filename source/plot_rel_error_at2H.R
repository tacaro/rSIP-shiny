#' @param test_dataset test dataset to use
#' @param d_t dbl incubation time in days
#' @param f_label strength of the SIP label to highlight in at%
#' @param xlimits character vector: of x axis limits for plot
#' @param include_legend logical: does the plot include the legend? Yes by default
#' @param include_caption logical: does the plot include the descriptive caption? Yes by default

require(ggplot2)

plot_rel_error_at2H <- function(test_dataset, d_t, f_label, xlimits, include_legend = TRUE, include_caption = TRUE) {
  
  # CALCULATE LIMITS
  upper_lim <- test_dataset |> 
    dplyr::filter(dt == d_t) |> 
    dplyr::filter(rel_error <= 0.5) |>
    dplyr::filter(FL == f_label) |> 
    dplyr::pull(F2) |> 
    min()
  
  upper_lim_mu_d <- test_dataset |> 
    dplyr::filter(dt == d_t) |> 
    dplyr::filter(rel_error <= 0.5) |>
    dplyr::filter(FL == f_label) |> 
    dplyr::pull(mu.d) |> 
    min()
  
  lower_lim <- test_dataset |> 
    dplyr::filter(dt == d_t) |> 
    dplyr::filter(rel_error <= 0.5) |>
    dplyr::filter(FL == f_label) |> 
    dplyr::pull(F2) |> 
    max()
  
  lower_lim_mu_d <- test_dataset |> 
    dplyr::filter(dt == d_t) |> 
    dplyr::filter(rel_error <= 0.5) |>
    dplyr::filter(FL == f_label) |> 
    dplyr::pull(mu.d) |> 
    max()
  
  
  # find the error minima (optima)
  minimums <- test_dataset |> 
    dplyr::filter(dt == d_t) |> 
    dplyr::group_by(FL) |> 
    dplyr::filter(rel_error == min(rel_error))
  
  minimum_label <- minimums |>
    dplyr::filter(FL > 15) |> 
    dplyr::filter(FL == f_label) |> 
    dplyr::pull(F2)
  
  
  # PLOT
  test_dataset %>%
    # Argument input here to filter dataset to correct incubation time:
    dplyr::filter(dt == d_t) |> 
    ggplot() +
    aes(
      x = F2,
      y = rel_error,
      color = as.factor(FL)
    ) +
    annotate(geom = "segment", x = lower_lim, xend = lower_lim, y = 0, yend = 0.5, color = "gray") +
    annotate(geom = "segment", x = upper_lim, xend = upper_lim, y = 0, yend = 0.5, color = "gray") +
    #annotate(geom = "label", x = upper_lim, y = 0.1, color = "black", label = paste0(round(upper_lim, 1), " d")) +
    #annotate(geom = "label", x = lower_lim, y = 0.1, color = "black", label = paste0(round(lower_lim, 1), " d")) +
    geom_line(linewidth = 1) +
    scale_color_viridis_d(end = 0.9) +
    # Secondary axis with ticks marked
    scale_x_continuous(
      sec.axis = dup_axis(
        breaks = c(round(upper_lim, 1), round(lower_lim, 1))
      )
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
      x = latex2exp::TeX("$^2F$ (at. %)"),
      y = latex2exp::TeX("Relative Error (%) =     $\\frac{\\sigma_{\\mu}}{\\mu}$"),
      color = latex2exp::TeX("Tracer Strength $^{2}F$ (at. %)"),
      title = paste(d_t, "day incubation time"),
      caption = if_else(include_caption, paste(
        "Range of quantification: \n",
        "CD% values: ", round(upper_lim, 1), "-", round(lower_lim, 1), "%, \n",
        "Growth rate: ", round(lower_lim_mu_d, 3), "-", round(upper_lim_mu_d, 3), "days^-1"
      ),
      "")
    ) +
    theme_classic() +
    ggprism::annotation_ticks(sides = "trbl") +
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


