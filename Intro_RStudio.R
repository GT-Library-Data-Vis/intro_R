# ==============================================================================
# INTRODUCTION TO R Studio
# Exploring Georgia Communities with CDC PLACES
# ==============================================================================
# Guiding question:
#   How do selected health estimates vary across Georgia counties?
#
#
# REPRODUCIBILITY GOAL
# This project is organized so that another person, including your future self,
# can locate the data, rerun the code, understand the decisions, and recreate
# the outputs.
# ==============================================================================

# ==============================================================================
# PART 0: REPRODUCIBLE PROJECT SETUP
# ==============================================================================

# ----------------------------------------------------------------------------
# 0.1 CREATE A NEW RSTUDIO PROJECT
# ----------------------------------------------------------------------------

# Complete these steps in RStudio before running the analysis:
#
# 1. Select File > New Project.
# 2. Select New Directory > Select New Project
# 3. Name the project CDC_PLACES_Workshop.
# 4. Choose a parent location such as Documents or Desktop.
# 5. Select Create Project.
#
# RStudio creates a .Rproj file and opens the project folder as the working
# directory. Reopen the project later by opening its .Rproj file.
#
# WHY USE A PROJECT?
# A project keeps related files together and supports relative paths. Relative
# paths make code more portable because they do not contain one person's user
# name or computer-specific folder location.

# ----------------------------------------------------------------------------
# 0.2 ORGANIZE THE WORKING DIRECTORY
# ----------------------------------------------------------------------------

# Recommended project structure:
#
# CDC_PLACES_Workshop/
# |-- CDC_PLACES_Workshop.Rproj
# |-- README.md
# |-- data/
# |   `-- CDC_PLACES_County_2025.csv
# |-- docs/
# |-- figures/
# |-- output/
# `-- scripts/
#     `-- CDC_PLACES_Intro_to_R_Workshop_Reproducible.R
#
# Folder purposes:
# data/    = original public data and supporting metadata
# scripts/ = R scripts used to process and analyze the data
# figures/ = charts created by code
# output/  = derived tables or cleaned data created by code
# docs/    = project documentation, reports, or presentation materials
#
# BEST PRACTICE:
# Keep the original downloaded data unchanged. Store cleaning and transformation
# steps in code rather than editing the raw CSV manually.

# If the folders do not yet exist, run these commands once from the project root.
# recursive = TRUE allows R to create a folder when needed.
dir.create("data", showWarnings = FALSE, recursive = TRUE)
dir.create("scripts", showWarnings = FALSE, recursive = TRUE)
dir.create("figures", showWarnings = FALSE, recursive = TRUE)
dir.create("output", showWarnings = FALSE, recursive = TRUE)
dir.create("docs", showWarnings = FALSE, recursive = TRUE)

# ----------------------------------------------------------------------------
# 0.3 VERIFY THE WORKING DIRECTORY AND USE RELATIVE PATHS
# ----------------------------------------------------------------------------

# getwd() displays the current working directory.
# When the RStudio Project is open, this should be the project root.
getwd()

# list.files() shows the files and folders in the project root.
list.files()




# There are over 25,000 packages that 
# folks have developed for R (and contributed to CRAN)
# These packages allow us to do specialized analysis based on 
# functions that others have coded
# You can find a list with brief descriptions here: 
# https://cran.r-project.org/web/packages/
# By clicking a link, you can find a full description of the package, 
# examples and what other packages are required
# Just as you would in the help file.

# Install a package once per R installation. Keep installation commands
# commented out during routine analysis so the script does not re-install them.

# The here package can make the project root explicit.
install.packages("here")
library(here)
# here::here("data", "CDC_PLACES_County_2025.csv")

# ----------------------------------------------------------------------------
# 0.4 ADD PROJECT DOCUMENTATION
# ----------------------------------------------------------------------------

# Create a README.md file in the project root. At minimum, document:
#
# - Project title and purpose
# - Guiding research question
# - Data source and release
# - Date the data were downloaded
# - File and folder organization
# - Required software and packages
# - Steps for reproducing the analysis
# - Known limitations and responsible-use notes
# - Contact or attribution information, when appropriate
#
# Also save dataset documentation or a data dictionary in docs/ when available.


# ==============================================================================
# PART 1: FIRST COMMANDS
# ==============================================================================

# R can be used as a calculator.
2 + 2
10 / 5
sqrt(25)

# help() opens documentation for a function in the Help pane.
help(mean)

# ==============================================================================
# PART 2: OBJECTS, VECTORS, FUNCTIONS, AND MISSING VALUES
# ==============================================================================

# The assignment operator = stores a value in an object.Can also use  <-
# Read this line as: the value 5 goes into an object named x.
x = 5
x
x <- 5
x

# Object names should be descriptive. R is case-sensitive.
county_name = "Fulton County"
county_name

# Now lets print it to the console
print(county_name) # we can also make a comment after a line

# c() combines multiple values into a vector.
# NA represents a missing or unknown value. NA is not zero.
rates = c(31.2, 34.8, NA, 29.7)
rates

# Functions have names followed by parentheses.
# Arguments inside the parentheses provide inputs or change behavior.
length(rates)
class(county_name)

# Without instructions for handling NA, mean() returns NA.
mean(rates)

# na.rm = TRUE removes missing values for this calculation.
mean(rates, na.rm = TRUE)

# ==============================================================================
# PART 3: INSTALL AND LOAD PACKAGES
# ==============================================================================

# Tidyverse
## A very popular collection of packages for data cleaning, manipulation, exploration, and visualization
## Important packages in the tidyverse are ggplot2, dpylr, tibble, and lubridate (there are several others) 

# install.packages("tidyverse")
# Load tidyverse packages for this R session.
library(tidyverse)

# ==============================================================================
# PART 4: IMPORT THE CDC PLACES CSV
# ==============================================================================

# read_csv() imports a CSV as a tibble, a modern data frame.
# places_file was defined near the beginning of this script.
places_raw = read_csv(here("data", "CDC_PLACES_County_2025.csv"), show_col_types = FALSE)

# Preserve the original imported object. Create new objects for transformed data.

# ==============================================================================
# PART 5: INSPECT BEFORE TRANSFORMING
# ==============================================================================

# Inspect structure, column names, dimensions, and initial rows.
glimpse(places_raw)
names(places_raw)
dim(places_raw)
head(places_raw)
tail(places_raw)
summary(places_raw)

# The native pipe %>% passes the result on the left to the next function.(Can also use |>)
# Check measure codes and value types available in the downloaded release.
places_raw %>%
  count(MeasureId, sort = TRUE)

places_raw %>%
  count(Data_Value_Type, sort = TRUE)

# ==============================================================================
# PART 6: FILTER AND SELECT GEORGIA DATA
# ==============================================================================


ga_selected <- places_raw %>%
  filter(StateAbbr == "GA") %>%
  filter(MeasureId %in% c("OBESITY", "DIABETES")) %>%
  filter(Data_Value_Type == "Crude prevalence") %>%
  select(
    LocationName,       # County or county-equivalent name
    MeasureId,          # Short code identifying the measure
    Data_Value,         # Numerical estimate
    Data_Value_Unit     # Unit associated with the estimate
  ) %>%
  drop_na(Data_Value)

# Inspect the transformed object. places_raw remains unchanged.
glimpse(ga_selected)
head(ga_selected)

ga_selected %>%
  count(MeasureId)

# ==============================================================================
# PART 7: ARRANGE, SUMMARIZE, AND ANSWER QUESTIONS
# ==============================================================================

# Question: Which Georgia counties have the highest modeled diabetes estimates?

ga_selected %>%
  filter(MeasureId == "DIABETES") %>%
  arrange(desc(Data_Value)) %>%
  select(LocationName, Data_Value) %>%
  slice_head(n = 10)

# CHALLENGE 1:
# Change "DIABETES" to "OBESITY" and run the pipeline again.
#
# CHALLENGE 2:
# Remove desc() to find the lowest estimates in the dataset.

# Summarize the distribution of county estimates by measure.

ga_summary <- ga_selected %>%
  group_by(MeasureId) %>% # splits data frame into subsets based on unique values of a column(s)
  summarize(
    county_count = n(), #n() gives count of observations in a group
    mean_county_estimate = mean(Data_Value, na.rm = TRUE),
    median_county_estimate = median(Data_Value, na.rm = TRUE),
    minimum_estimate = min(Data_Value, na.rm = TRUE),
    maximum_estimate = max(Data_Value, na.rm = TRUE),
    .groups = "drop" # drop the grouping to return to the original dataframe structure
  )

ga_summary

# Save a derived table without changing the raw input file.
write_csv(ga_summary, here("output","georgia_measure_summary.csv"))

# ==============================================================================
# PART 8: CREATE A BAR CHART WITH GGPLOT2
# ==============================================================================

# Create a separate object containing exactly ten rows.

diabetes_top10  = ga_selected %>%
  filter(MeasureId == "DIABETES") %>%
  slice_max(Data_Value, n = 10, with_ties = FALSE) # with_ties returns only the first n rows and breaks ties randomly

# ggplot2 resources
# ggplot2 Cheat Sheet: 
# https://rstudio.github.io/cheatsheets/html/data-visualization.html

# R Graph Gallery
# https://www.r-graph-gallery.com/

# R Colors
# https://r-graph-gallery.com/ggplot2-color.html
# 
# Safari Books Online:
# https://learning.oreilly.com/library/view/applied-data-visualization/9781789612158/
#  
# Grammar of Graphics (2005): https://bit.ly/2CCsn1j

# To better understand ggplot, one needs to understand the theory underlying the script -- The Grammar of Graphics 
# Grammar of Graphics - 7 layers
# Data - data to plot
# Aesthetics - position, size, color, shape
# Geometries - visual element to plot (points, lines, polygons)
# Facets - subsets of data
# Statistics - statistical transformation of data
# Coordinates - surface of the plot (cartesian, map, polar, ...)
# Themes - non-data elements

# Build and store the chart in an object.

diabetes_bar_chart <- ggplot(
  diabetes_top10,
  aes(
    x = reorder(LocationName, Data_Value), # automatically lists in alphabetical order. reorder() puts in value order
    y = Data_Value
  )
) +
  geom_col(fill = "#2F5597") + # bar chart
  coord_flip() +
  labs(
    title = "Georgia counties with the highest modeled diabetes estimates",
    subtitle = "CDC PLACES county-level crude prevalence estimates",
    x = NULL,
    y = "Estimated prevalence (%)",
    caption = "Source: CDC PLACES County Data, 2025 release"
  ) +
  theme_minimal(base_size = 12)

diabetes_bar_chart

# Save the figure to the figures folder.
ggsave(
  filename = here("figures","georgia_diabetes_top10.png"),
  plot = diabetes_bar_chart,
  width = 8,
  height = 5,
  dpi = 300
)

# ==============================================================================
# PART 9: SCATTERPLOT 
# ==============================================================================

# Reshape the long-form data so obesity and diabetes become separate columns.

ga_wide = ga_selected %>%
  select(LocationName, MeasureId, Data_Value) %>%
  pivot_wider(
    names_from = MeasureId,
    values_from = Data_Value
  )

glimpse(ga_wide)

# A visible association does not establish that one measure causes another.

obesity_diabetes_plot = ggplot(ga_wide, aes(x = OBESITY, y = DIABETES)) +
  geom_point(color = "#2F5597", alpha = 0.75, size = 2.5) +
  labs(
    title = "Obesity and diabetes estimates across Georgia counties",
    subtitle = "Each point represents one county",
    x = "Modeled obesity prevalence (%)",
    y = "Modeled diabetes prevalence (%)",
    caption = "Source: CDC PLACES County Data, 2025 release"
  ) +
  theme_minimal(base_size = 12)

obesity_diabetes_plot

ggsave(
  filename = here("figures", "georgia_obesity_diabetes_scatterplot.png"),
  plot = obesity_diabetes_plot,
  width = 7,
  height = 5,
  dpi = 300
)

# ==============================================================================
# PART 10: MINI CIVIC DATA INVESTIGATION
# ==============================================================================

# Complete these steps by modifying code already used above.
# 1. Choose one measure available in the current CDC release.
# 2. State a question using a geography, measure, and comparison.
# 3. Filter to Georgia, the measure, and one data-value type.
# 4. Create a sorted table or chart.
# 5. Write one observation and one limitation.

# Investigation template:
# investigation <- places_raw %>%
#   filter(StateAbbr == "GA") %>%
#   filter(MeasureId == "YOUR_MEASURE_CODE") %>%
#   filter(Data_Value_Type == "Crude prevalence") %>%
#   select(LocationName, Measure, Data_Value, Data_Value_Unit) %>%
#   drop_na(Data_Value) $>%
#   arrange(desc(Data_Value))
#
# head(investigation, 10)

# ==============================================================================
# PART 11: END-OF-SESSION REPRODUCIBILITY CHECK
# ==============================================================================

# Save all scripts before completing this checklist.
#
# PROJECT CHECKLIST
# [ ] The project opens from the .Rproj file.
# [ ] The script uses relative paths rather than personal absolute paths.
# [ ] Raw data remain unchanged in data/.
# [ ] Derived tables and figures are created by code.
# [ ] README.md documents the source, download date, workflow, and limitations.
# [ ] Package versions are recorded when long-term reproducibility is required.

# sessionInfo() records the R version, operating system, and loaded packages.
sessionInfo()

# Write session information to a text file for the project record.
writeLines(capture.output(sessionInfo()), here("output", "session-info.txt"))


# END OF WORKSHOP SCRIPT
