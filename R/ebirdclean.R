#' Clean data frame provided by eBird
#'
#' @param x CSV file provided by eBird. Defaults to the name provided by eBird: "MyEBirdData.csv".
#' @return An updated data frame, with the following changes:
#'   - Separates the Date column into two new columns, Year and Month.
#'   - Extracts country information from State.Province and converts into full name (using the countrycode package)
#'   - Removes text in parentheses in Common.name, which is used to denote subspecies or groups.
#'   - Removes all rows of species labelled as hybrids, domestic types, slashes (uncertain records between two species), or spuhs (Genus sp.).
#' @details Uses \code{read.csv} to read the .csv file, with its only argument being \code{stringsAsFactors = FALSE}.
#' @import dplyr
#' @export
#'
#' @examples
#' \dontrun{
#' mylist <- ebirdclean("MyEBirdData.csv")
#' mylist <- ebirdclean()}
#' @author Sebastian Pardo \email{sebpardo@gmail.com}

ebirdclean <- function(x = "MyEBirdData.csv") {
  mydata <- tbl_df(read.csv(x, stringsAsFactors = FALSE))
  mydata <- mydata %>%  mutate(Year = format(strptime(Date, "%m-%d-%Y"), "%Y"),
                               Month = factor(format(strptime(Date, "%m-%d-%Y"), "%B"),
                                              levels = month.name),
                               Country.code = substr(State.Province, 1, 2),
                               sciName = stringr::word(Scientific.Name, 1, 2),
                               comName = gsub("\\s*\\([^\\)]+\\)", "", Common.Name),
                  # removing text between parenthesis in common name to compare uniques
                          Country = countrycode::countrycode(Country.code,
                                                      "iso2c", "country.name")) %>%
                  # Adding full country names
  filter(!grepl("hybrid|Domestic", Common.Name)) %>% # removing hybrids and Domestic types
    # These two filters are now on sciName rather than Scientific.Name as the former
    # exludes subspecies and when using the latter slashes in ssp should were being excluded
  filter(!grepl(" sp\\.", sciName)) %>% # removing spuhs
  filter(!grepl("\\/", sciName)) # removing "slashes" (records that could be one of two species)

  mydata
}

