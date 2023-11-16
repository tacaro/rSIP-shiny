FROM analythium/shinyproxy-demo:latest

# packages
USER root
RUN install2.r -r http://cran.rstudio.com/ remotes

# install CRAN packages
RUN install2.r -r http://cran.rstudio.com/ \
  dplyr \
  tidyr \
  stringr \
  readr \
  forcats \
  ggplot2 \
  ggthemes \
  plotly \
  cowplot \
  latex2exp \
  shiny \
  shinydashboard

# markdown
RUN install2.r -r http://cran.rstudio.com/ markdown

# provide an argument to be set from built to restart build from here
ARG refresh=unknown

# app
RUN rm -rf /home/app/*
ARG app
COPY $app /home/app
LABEL app="$app"
USER app
