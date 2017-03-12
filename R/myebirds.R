#' Calculate species totals gouped by year, country, and/or month.
#'
#' \code{myebirds} calculates species totals based on data dumped by eBird
#' (Download page: \url{http://ebird.org/ebird/downloadMyData}) after it has been cleaned with \code{ebirdclean}.
#'
#' @param mydata Data frame provided by \code{ebirdclean}.
#' @param years Range of years to calculate across, default is between 1900 and current year.
#' @param grouping Character vector specifying how the data should be grouped for counting.
#'   Must be composed of "Year", "Country", and/or "Month". This vector is passed on directly to \code{group_by_}.
#' @param wide String specifying whether different values should be returned in wide format and how.
#'   Must be one of the strings included in \code{grouping}. Defaults to FALSE.
#'
#' @return A data frame containing total counts divided into specified groups. If \code{wide = FALSE}
#'   then it returns a combination of the following columns, depending on grouping specified:
#' @return "Year" Year
#' @return "Country" Country using two letter codes.
#' @return "Month" Month, using full month name (from month.name()).
#' @return "n" Total species count for the specified Year, Country, and Month.
#' @return If in wide format, then the first column(s) consist of the values in grouping that
#' are not equal to wide, while the remaining columns are unique values of the argument specified in wide.
#'
#' @import dplyr
#' @export
#'
#' @examples \dontrun{
#' mylist <- ebirdclean() # CSV must be in working directory
#' myebirds(mylist, grouping = c("Year"))
#' myebirds(mylist, grouping = c("Country", "Month"))
#' myebirds(mylist, grouping = c("Year", "Country", "Month"))
#' myebirds(mylist, grouping = c("Year", "Country", "Month"), wide = "Month")
#' myebirds(mylist, grouping = c("Year", "Country", "Month"), wide = "Country")
#' }
#' @author Sebastian Pardo \email{sebpardo@gmail.com}

myebirds <- function (mydata, years = 1900:format(Sys.Date(), "%Y"),
                      grouping = c("Year", "Country", "Month"),
                     wide = FALSE) {
  wide.options <- c("Year", "Country", "Month", FALSE)
  #grouping <- match.arg(grouping, wide.options, several.ok = TRUE)
  if (!all(grouping %in% wide.options) || length(grouping) > 3 ||
      length(grouping) != length(unique(grouping))) stop("grouping specified incorrectly")
  else
    if (wide %in% wide.options != TRUE) stop("wide specified incorrectly")
  else
    if (wide != FALSE && wide %in% grouping != TRUE) stop("wide not in grouping")
  else

    mydata <- group_by_(mydata, .dots = lazyeval::all_dots(grouping)) %>%  # Groupings, can be Year, Month, and/or country
      filter(Year %in% years) %>% # Select year range
      summarise(n = n_distinct(comName)) # Select distinct species after removing types
  if (wide != FALSE && wide %in% grouping) {
    tidyr::spread_(mydata, wide, "n", fill = "0")
  } else
    mydata
}
