# This script plots the mosaic for Cerrado and Amazon land cover maps 2024 from TerraClass.
# Fror the full workflow to generate the mosaic, refer to Explore_TerraClass.Rmd

# Organize class codes -------------

# Update class codes according to the reclassification
classes_ce_mosaic <- classes_ce
idx <- match(classes_ce_mosaic$class_code, new_classes$from)

classes_ce_mosaic$class_code[!is.na(idx)] <-
  new_classes$becomes[idx[!is.na(idx)]]

# combine the two tables with class names
classes_mosaic <- rbind(
  classes_am,
  classes_ce_mosaic
)

# Remove the origin information, not needed for the legend
classes_mosaic <- unique(
  classes_mosaic[, c("class_code", "class_name")]
)


# Ensure class_code is numeric
classes_mosaic$class_code <- as.numeric(
  as.character(classes_mosaic$class_code)
)

# Personalize ordering to set natural formations first
class_order <- c(1, 2, 26, 27, 51, 9, 28, 10,
                 11:17, 20,21,23,22,25) # set natural vegetation first, then agriculture and pasture, then anthropogenic, water, deforestation, not observed.


# Check which codes are missing
setdiff(class_order, classes_mosaic$class_code) # all match

# Reorder the table
idx <- match(class_order, classes_mosaic$class_code)

# Remove codes not found in the table
idx <- idx[!is.na(idx)]

classes_mosaic <- classes_mosaic[
  idx,
  ,
  drop = FALSE
]

# Check the resulting order
classes_mosaic$class_code


# Make sure the mosaic raster layer is categorical
AmCe24 <- terra::as.factor(AmCe24)

# Assign names to the categories
levels(AmCe24) <- data.frame(
  ID = classes_mosaic$class_code,
  Class = classes_mosaic$class_name
)



## Setup a color scheme --------------


# Define colors following class_order
class_colors <- c(
  # Vegetation: primary, secondary, non-forest and silviculture
  "#00441B", # 1
  "#238B45", # 2
  "#006D5B", # 26
  "#41AB8D", # 27
  "#556B2F", # 51
  "#8A9A5B", # 9
  
  # Pasture and agriculture
  "#754421", # 28
  "#A6611A", # 10
  "#B88635", # 11
  "#D1A64A", # 12
  "#E2C36B", # 13
  "#FEE08B", # 14
  "#FFF2B2", # 15
  
  # Mining, urban and other anthropogenic uses
  "#E78AC3", # 16
  "#C51B8A", # 17
  "#9E77B5", # 20
  "#542788", # 21
  
  # Water
  "#56B4E9", # 23
  
  # Deforestation for the year
  "#D7191C", # 22
  
  # Not observed
  "#A6A6A6"  # 25
)


## Assign color to class code ----------------


# Create plotting table
plot_classes <- data.frame(
  class_code = class_order,
  class_name = classes_mosaic$class_name[
    match(class_order, classes_mosaic$class_code)
  ],
  color = class_colors
)

print(plot_classes)


# To ensure the classes are shown in the correct order, create a reclassified raster with the codes in the correct order.

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

# Verify color assignment
plot_colors_check <- data.frame(
  ID = seq_along(class_order),
  Original_code = class_order,
  Class = plot_classes$Class,
  Color = class_colors
)

print(plot_colors_check)



# Plot mosaic and legend --------------


layout(
  matrix(c(1, 2), nrow = 1),
  widths = c(3.5, 2)
)

# Map
par(mar = c(4, 4, 3, 1))

terra::plot(
  AmCe24_plot,
  type = "classes",
  col = class_colors,
  legend = FALSE,
  main = "Land cover classes"
)

# Custom legend
par(mar = c(1, 0, 1, 0))
plot.new()

legend(
  "topleft",
  legend = plot_classes$Class,
  fill = class_colors,
  title = "Land cover classes",
  cex = 0.75,
  bty = "n",
  y.intersp = 1.2,
  x.intersp = 0.8
)

layout(1)

