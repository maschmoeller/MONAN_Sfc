# Setting up

## The following script checks the required packages, installs missing packages and loads them into the R environment.

# Required packages
required_packages <- c(
  "sf",
  "terra",
  "stars",
  "gdalraster",
  "gstat",
  "spatstat",
  "tidyverse",
  "here",
  "rstac",
  "sits",
  "mapview"
)

# Check installed packages
installed_packages <- rownames(installed.packages())

# Identify missing packages
missing_packages <- setdiff(
  required_packages,
  installed_packages
)

# Install missing packages
if (length(missing_packages) > 0) {
  
  install.packages(
    missing_packages,
    repos = "https://cloud.r-project.org"
  )
  
  message("Missing packages successfully installed.")
  
} else {
  
  message("All required packages are already installed.")
  
}

# check versions

package_versions <- installed.packages()[
  required_packages,
  "Version"
]

print(package_versions)

# Load required packages
for (package in required_packages) {
  library(package, character.only = TRUE)
}

