# Importing and exploring TerraClass thematic maps on Land Use and Cover for the Brazilian Amazon and Cerrado biomes
## Data obtained from https://www.terraclass.gov.br/download-de-dados

# load required packages --------------
library(terra)
library(here)
library(tidyverse)
library(mapview)


# load classified images as objects from files and inspect them ----------

# define Terraclass data directory
## this must be replaced with your own local directory path
terraclass_dir <- here::here("data","raw","terraclass")

Am24 <- terra::rast(file.path(terraclass_dir,"AMZ.2024.M","biomas_classificados","AMZ.2024.M.tif"))
Ce24 <- terra::rast(file.path(terraclass_dir,"CER.2024.M","CER.2024.M.tif"))

# inspect
summary(Am24)
Am24
Ce24
describe(Ce24)
describe(Am24)

compareGeom(Am24,Ce24) #ok, extents do not match

# view created objets
plot(Am24)
plot(Ce24)

# check frequency of values (classes) in each raster
freq_am <- terra::freq(Am24)
freq_ce <- terra::freq(Ce24)
print(freq_am)
print(freq_ce)



# reclassification before mosaic ---------
# compare Cerrado and Amazonia classes
## Extract class codes
classes_am <- freq_am$value
classes_ce <- freq_ce$value

## Compare class codes
class_comparison <- data.frame(
  class_code = sort(union(classes_am, classes_ce))
)

class_comparison$Amazonia <- 
  class_comparison$class_code %in% classes_am

class_comparison$Cerrado <- 
  class_comparison$class_code %in% classes_ce

print(class_comparison)

# create tables with class descriptions
## need to be done because the same number does not necessarily refer to
## the same land use or cover for the different biome classifications

classes_am <- data.frame(
  source_lyr = "am24",
  class_code = sort(classes_am),
  class_name = c("Primary Amazon Vegetation", "Secondary Amazon Vegetation", "Silviculture", "Vegetated pasture", "Herbaceous pasture",
                 "Perennial Agriculture", "Semi-perennial agriculture", "Single cycle agriculture", "multiple cycles agriculture",
                  "Mining", "Urban", "Other uses", "Deforestation for the year", 
                 "Water bodies", "Not observed", "Non-forest natural formations"))

classes_ce <- data.frame(
  source_lyr = "ce24",
  class_code = sort(classes_ce),
  class_name = c("Primary Cerrado Vegetation", "Secondary Cerrado Vegetation", "Silviculture", "Pastureland",
                 "Perennial Agriculture", "Semi-perennial agriculture", "Single cycle agriculture", "multiple cycles agriculture",
                 "Mining", "Urban", "Other uses", "Other built areas", "Deforestation for the year",
                 "Water bodies"))

## there are important differences between the two.
## Vegetation needs to be diferentiated between Cerrado and Amazon;
## For the Amazon, there are two pastureland classes, while only a single pastureland for Cerrado;
## Non-forest natural formations only present in the Amazon classification, and might be Cerrado.

# reclass Cerrado to assign codes not repeated in Amazon and avoid misslabeling in mosaic
new_classes <- data.frame(from = c(1,2,11),
                          to = c(1,2,11),
                          becomes = c(26,27,28)) # 26 = Primary Cerrado; 27 = Secondary Cerrado, 28 = Pasture - generic
Ce24.rcl <- classify(Ce24, rcl=as.matrix(new_classes), right = NA)
print(freq(Ce24.rcl))
# ok


# check correspondences before mosaic ---------------
terra::origin(Am24)
terra::origin(Ce24)

AmCe24 <- mosaic(Am24,Ce24.rcl, fun="max")
plot(AmCe24)



# Create a sequential reclassification matrix
rcl_plot <- cbind(
  class_order,
  seq_along(class_order)
)

# Reclassify raster for visualization
AmCe24_plot <- terra::classify(
  AmCe24,
  rcl = rcl_plot,
  right = NA,
  others = NA
)

# Convert to categorical raster
AmCe24_plot <- terra::as.factor(AmCe24_plot)

# Create category table using sequential IDs
plot_classes <- data.frame(
  ID = seq_along(class_order),
  Class = classes_mosaic$class_name[
    match(class_order, classes_mosaic$class_code)
  ]
)

levels(AmCe24_plot) <- plot_classes