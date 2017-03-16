# Extract 20 trees from Jetz et al. (2014) for estimating PD
library(ape)

# You can load and unzip the first 1000 from the birdtree.org website here:
# http://litoria.eeb.yale.edu/bird-tree/archives/Stage2/HackettStage2_0001_1000.zip
# Or you can use the 20 tree subset provided in the data-raw folder

# read the first 20 lines of the text file; each line is a complete tree
treelines <- readLines("data-raw/AllBirdsHackett1.tre", n = 20)
# treelines <- readLines("data-raw/AllBirdsHackett1_subset20.tre") # same as above
jetz20trees <- read.tree(text = treelines)

# saving as internal object (not available to package users)
devtools::use_data(jetz20trees, internal = TRUE, overwrite = TRUE)
