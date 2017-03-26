#' Total phylogenetic distance of species in your eBird lists.
#'
#' \code{mypd} provides the evolutionary time encompassed by your eBird checklist
#' based on Jetz et al. (2014).
#'
#' Phylogenetic distance (PD) is simply the sum of all branch lengths of a tree,
#' and represents the total evolutionary time covered by the species in the tree.
#' Values returned by \code{mypd} are in million years of evolution, and are based
#' in a subset of 20 trees from Jetz et al. (2014) using the full taxonomy and
#' Hackett "structure". See \code{raw-data/load-bird-trees.R} for more info on
#' how the trees were extracted from the original source.#'
#'
#' @param mydata Data frame created with \code{\link{ebirdclean}}.
#' @param ntrees Integer indicating the number of phylogenetic trees to use for
#'  calculating PD. Value must be between 1 and 20. Defaults to 20. Lower this
#'  number if computation of PD is taking too long.
#'
#' @return A tibble containing the mean ("mean_pd"), median ("median_pd"), and standard
#'  deviation ("sd_pd") vaules; units are in million years.
#'
#' @references
#' Jetz, W., Thomas, G. H., Joy, J. B., Redding, D. W.,
#'   Hartmann, K. & Mooers, A. O. (2014) Global Distribution and Conservation
#'   of Evolutionary Distinctness in Birds. Current Biology 24, 919–930.
#'   \url{http://www.cell.com/current-biology/fulltext/S0960-9822(14)00270-X}
#'
#' @import dplyr
#' @export
#'
#' @examples
#' \dontrun{
#' mylist <- ebirdclean("MyEBirdData.csv")
#' # Estimate PD for your whole eBird checklist:
#' mypd(mylist)
#'
#' # Estimate PD by country (using dplyr):
#' mylist %>%
#'   group_by(Country) %>%
#'   do(mypd(.))}
#'
#' @author Sebastian Pardo \email{sebpardo@gmail.com}

mypd <- function(mydata, ntrees = 20) {
  # need to figure out how to load trees properly
  #load("trees.rdata")
  myedgebirds <- myedge(mydata)

  # From Liam Revell's blog
  #keep.tip <- function(tree, tip) drop.tip(tree, setdiff(tree$tip.label, tip))
  #pds <- lapply(jetz20trees, keep.tip, tip = myedgebirds$sciName.edge) %>%

  # object jetz20trees is loaded internally from R/sysdata.rda
  pds <- lapply(jetz20trees[1:ntrees], function (x) {
    ape::drop.tip(x, setdiff(x$tip.label, myedgebirds$sciName.edge))
    }) %>%
    lapply(function (x) sum(x$edge.length)) %>%
    unlist
  tibble::data_frame(mean_pd = mean(pds), median_pd = median(pds),
                     sd_pd = sd(pds))
}

