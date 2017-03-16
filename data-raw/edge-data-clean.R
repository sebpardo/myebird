### Clean EDGE dataset to fit (as closely as possible) with eBird's
### taxonomy

library(dplyr)
library(rebird)

espp <- ebirdtaxonomy(cat = "species")
edgeraw <- read.csv("data-raw/EDGE_birds_2014.csv", stringsAsFactors = FALSE,
                 strip.white = TRUE)

#str(edge)

ed <- edgeraw %>% tbl_df %>%
  dplyr::select(Species, EDGE.Score, EDGE.Rank, Common.Name) %>%
  rename(sciName = Species, comName = Common.Name) %>%
  mutate(sciName.edge = sub(" ", "_", sciName)) # keeping old names too for matching tree

# capitalizing after hyphen if word is a bird name
ed$comName <- sub("\\-owl", "\\-Owl", ed$comName)
ed$comName <- sub("\\-dove", "\\-Dove", ed$comName)
ed$comName <- sub("\\-tyrant", "\\-Tyrant", ed$comName)
ed$comName <- sub("\\-rail", "\\-Rail", ed$comName)
ed$comName <- sub("\\-babbler", "\\-Babbler", ed$comName)
ed$comName <- sub("\\-jay", "\\-Jay", ed$comName)
ed$comName <- sub("\\-chat", "\\-Chat", ed$comName)
ed$comName <- sub("\\-warbler", "\\-Warbler", ed$comName)
ed$comName <- sub("\\-eagle", "\\-Eagle", ed$comName)
ed$comName <- sub("\\-pigeon", "\\-Pigeon", ed$comName)
ed$comName <- sub("\\-plover", "\\-Plover", ed$comName)
ed$comName <- sub("\\-finch", "\\-Finch", ed$comName)
ed$comName <- sub("\\-petrel", "\\-Petrel", ed$comName)
ed$comName <- sub("\\-goose", "\\-Goose", ed$comName)
ed$comName <- sub("\\-heron", "\\-Heron", ed$comName)
ed$comName <- sub("\\-wren", "\\-Wren", ed$comName)
ed$comName <- sub("\\-duck", "\\-Duck", ed$comName)
ed$comName <- sub("\\-parrot", "\\-Parrot", ed$comName)
ed$comName <- sub("\\-martin", "\\-Martin", ed$comName)
ed$comName <- sub("\\-thrush", "\\-Thrush", ed$comName)
ed$comName <- sub("\\-snipe", "\\-Snipe", ed$comName)
#ed$comName <- sub("\\-flycatcher", "\\-Flycatcher", ed$comName)
ed$comName <- sub("\\-kingfisher", "\\-Kingfisher", ed$comName)

ed$comName <- sub("\\bGrey", "Gray", ed$comName)
ed$comName <- sub("Sacred Ibis", "Ibis", ed$comName)
ed$comName[ed$sciName == "Pica pica"] <- "Eurasian Magpie"

ed$sciName <- sub("Larus (cirrocephalus|maculipennis|novaehollandiae|philadelphia|ridibundus|serranus)",
                  "Chroicocephalus \\1", ed$sciName)

## These aren't needed anymore as they are corrected by matching common names
# ed$sciName[ed$sciName == "Carduelis flammea"] <- "Acanthis flammea"
# ed$sciName[ed$sciName == "Grus canadensis"] <- "Antigone canadensis"
# ed$sciName <- sub("Collocalia (brevirostris|terraereginae|vanikorensis)",
#                   "Aerodramus \\1", ed$sciName)
# ed$sciName[ed$sciName == "Puffinus griseus"] <- "Ardenna grisea"
# ed$sciName[ed$sciName == "Alcedo azurea"] <- "Ceyx azureus"
# ed$sciName[ed$sciName == "Alcedo pusilla"] <- "Ceyx pusillus"
#
# ed$sciName <- sub("Puffinus (creatopus|tenuirostris)",
#                   "Ardenna \\1", ed$sciName)
# ed$sciName <- sub("Carduelis (ambigua|chloris|sinica)",
#                   "Chloris \\1", ed$sciName)
# ed$sciName <- sub("Dendroica",
#                   "Setophaga", ed$sciName)

# updating scientific names based on matching common names with eBird
# species list
edge <- left_join(ed, espp, by = "comName") %>%
  mutate(sciName = ifelse(is.na(sciName.y) & .$sciName.x != "Pica pica",
                          sciName.x, sciName.y)) %>%
  select(sciName, comName, EDGE.Score, EDGE.Rank, sciName.edge) %>%
  arrange(EDGE.Rank)

devtools::use_data(edge, overwrite = TRUE)
