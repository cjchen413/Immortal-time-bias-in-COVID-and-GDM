# Packages: Install and load the forestplot package
library(forestploter)
library(tidyverse)
library(ggpubr)

# 1. Case control ----
# Read data and process
results <- read_csv("cc_adj_results.csv")
results$`OR (95% CI)` <- gsub("to", "—", results$`OR (95% CI)`)
# replace NA in the first column
results <- results |> mutate(Factors=ifelse(is.na(Factors),"    ", Factors))


# assign a blank column
results$`Forest plot` <- "                         "
results <- results |> relocate(`OR (95% CI)`, .after = `Forest plot`  )

# Set up the back ground theme
tm <- forest_theme(
      core = list(
            bg_params = list(fill = "#FFFFFF"),
            fg_params = list(
                  fontfamily = "Calibri",   # set your font family
                  fontsize = 12,          # set your font size
                  fontface = "plain"       # set font style (plain, bold, italic, etc.)
            )
      ),
      header = list(
            fg_params = list(
                  fontfamily = "Arial",
                  fontsize = 14,
                  fontface = "bold"
            )
      )
)


plot <- forest(
      data = results[,c(1:2,6:7)], # These are columns to be displayed
      est = results$or, # the main effect
      lower = results$lci, # lower bound
      upper = results$hci, # upper bound
      ci_column = 3,  # The order of the forest plot column. This is the second. 
      xlim = c(0.7, 1.65), # the x-axial limits
      ticks_at = c(0.8, 1, 1.2, 1.4, 1.6), # the ticks on x axial
      ref_line = 1,  # reference line
      theme = tm)
plot


# Combine ---

ggsave(
      filename = "main_results.svg",   # your filename
      plot = plot,                     # your plot object (ggplot or ggarrange result)
      width = 20,                     # adjust width as needed (in inches)
      height =11,                     # adjust height as needed
      units = "cm",                   # units: "in", "cm", or "mm"
      dpi = 300,                      # not necessary for svg, but harmless
      device = "svg"                  # ensures svg output
)
