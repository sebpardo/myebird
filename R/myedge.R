#' EDGE scores of species in your eBird lists.
#'
#' \code{myedge} provides Evolutionarily Distinct (ED) and Globally Endangered (EDGE)
#' species scores and rankings based on Jetz et al. (2014).
#'
#' EDGE scores are calculated from a species evolutionary distinctiveness (ED)
#' and Global IUCN Red List status (GE) using the following equation:
#'
#' \deqn{EDGE = ln(ED + 1) + GE * ln(2)}
#'
#' Where ED is defined as species-level measure representing the weighted sum of
#' the branch lengths along the path from the root of a tree to a given
#' tip/species, and GE is a rank scalar ranging from 0 (IUCN Red List
#' designation “Least Concern”) to 4 (IUCN Red List designation “Critically
#' Endangered”). See Jetz et al. (2014) for more details.
#'
#' It's important to note a few issues with the EDGE metric and the values
#' provided by this function. The EDGE score can be strongly influenced by the
#' taxonomy being used. This is particularly important if species with
#' relatively high ED values are considered multiple species by other authors;
#' this can considerably change evolutionary distinctiveness estimates.
#' Furthermore, the EDGE taxonomy is considerably different to that in eBird
#' (the latter includes many recent splits and other revisions), and thus the
#' matching of species between EDGE species and eBird species is imperfect, thus
#' EDGE scores and rankings based on eBird might not be accurate.
#'
#' @param mydata Data frame created with \code{\link{ebirdclean}}.
#' @param edge.cutoff Cutoff for EDGE rankings to be returned. Defaults to
#'   \code{9999}, which returns all species in the EDGE list.

#' @return A data frame containing the following six columns:
#' @return "sciName": Scientific name. Most of these have been updated using
#'   eBird's taxonomy (see \code{raw-data/edge-data-clean.R} for more info).
#' @return "comName": Common name.
#' @return "ED.Score": Evolutionary distinctiveness as it appears in
#'   \url{http://www.edgeofexistence.org/birds/default.php}.
#' @return "EDGE.Score": EDGE score calculated using the equation above, as it appears in
#'   \url{http://www.edgeofexistence.org/birds/default.php}.
#' @return "EDGE.Rank": Ranking based on EDGE score, as it appears in
#'   \url{http://www.edgeofexistence.org/birds/default.php}.
#'@return "sciName.edge": Scientific name as they appear in the Jetz et al. (2014)
#'   phylogeny.
#'
#' @references
#' Jetz, W., Thomas, G. H., Joy, J. B., Redding, D. W.,
#'   Hartmann, K. & Mooers, A. O. (2014) Global Distribution and Conservation
#'   of Evolutionary Distinctness in Birds. Current Biology 24, 919–930.
#'   \url{http://www.cell.com/current-biology/fulltext/S0960-9822(14)00270-X}
#'
#'@source \url{http://www.edgeofexistence.org/birds/default.php}.
#'
#' @import dplyr
#' @export
#'
#' @examples
#' \dontrun{
#' mylist <- ebirdclean("MyEBirdData.csv")
#' myedge <- myedge(mylist, edge.cutoff = 500)}
#'
#' @author Sebastian Pardo \email{sebpardo@gmail.com}
myedge <- function(mydata, edge.cutoff = 9999) {

  data(edge)

  spp <- select(mydata, sciName, comName) %>%
    group_by(sciName) %>%
    summarise(n = n(), comName = unique(comName)) %>%
    select(sciName, comName)

  left_join(spp, edge, by = "sciName") %>%
    select(-comName.y) %>%
    rename(comName = comName.x) %>%
    arrange(-EDGE.Score) %>%
    filter(EDGE.Rank <= edge.cutoff)
}
