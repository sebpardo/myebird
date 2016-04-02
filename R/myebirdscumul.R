
myebirdscumul <- function (mydata, years = 1900:format(Sys.Date(), "%Y"),
                        grouping = c("Year", "Country"),
                        cum.across = "Month",
                        wide = TRUE) {
  group.options <- c("Year", "Country", NULL)
  if (!all(grouping %in% group.options) || length(grouping) > 2 ||
      length(grouping) != length(unique(grouping))) stop("grouping specified incorrectly")
  else
    if (!is.logical(wide)) stop("wide specified incorrectly, must be logical")
  else

    # Groupings, can be Year, Month, and/or country
    mydata2 <- group_by_(mydata, .dots = all_dots(grouping)) %>%
      filter(Year %in% years)

  if (is.null(grouping)) {
    md3 <- data.frame(location = "World")
  } else {
    md3 <- summarise(mydata2, n = n_distinct(comName)) %>%
      select_(.dots = all_dots(grouping))
  }

  if (length(cum.across) == 1 && cum.across == "Month") {
    for (i in 1:12) {
      t2 <- mydata2 %>%
        filter(Month %in% month.name[1:i]) %>%
        summarise(cumul = n_distinct(comName)) %>%
        rename_(.dots = setNames("cumul", month.name[i]))
      md3 <- left_join(md3, t2, by = grouping)
    }
  } else
    if (length(cum.across) == 1 && cum.across == "Year") {
      for (i in intersect(years, mydata2$Year)) {
        t2 <-
          mydata2 %>%
          filter(Year %in% min(years):i) %>%
          summarise(cumul = n_distinct(comName)) %>%
          rename_(.dots = setNames("cumul", i))
        if (is.null(grouping)) {
          md3 <- cbind(md3, t2)
        } else {
          md3 <- left_join(md3, t2, by = grouping)
        }
      }
    } else
      if (length(cum.across) == 2 && cum.across == c("Year","Month")) {
        year.range <- sort(intersect(years, mydata2$Year))
        for (i in min(year.range):max(year.range)) {
          for (k in 1:12) {
            t2 <-
              mydata2 %>%
              filter(Year < i | (Year == i & Month %in% month.name[1:k])) %>%
              #ungroup %>%
              summarise(cumul = n_distinct(comName)) %>%
              rename_(.dots = setNames("cumul", paste(i,month.name[k], sep = ".")))
            if (is.null(grouping)) {
              md3 <- cbind(md3, t2)
            } else {
              md3 <- left_join(md3, t2, by = grouping)
            }
          }
        }
      } else stop("Incorrect cum.across")

  md3[is.na(md3)] <- 0

  if (wide) {
    md3
  } else

    if (setequal(grouping, c("Year","Country"))) {
      lcum <- gather(md3, Month, cumul, -Year, -Country)
      lcum
    } else
      if (setequal(grouping, c("Year"))) {
        lcum <- gather(md3, Month, cumul, -Year)
        lcum
      } else
        if (setequal(grouping, c("Country"))) {
          lcum <- gather(md3, Month, cumul, -Country)
          if (setequal(cum.across, c("Year","Month"))) {
            lcum <- rename(lcum, Year.Month = Month)
            yml <- as.data.frame(do.call(rbind, strsplit(as.vector(lcum$Year.Month), "[.]")),
                                 stringsAsFactors = FALSE)
            colnames(yml) <- cum.across
            cbind(lcum, yml) %>%
              tbl_df %>%
              select(Country, Year, Month, cumul) %>%
              mutate(Month = factor(Month, levels = month.name)) %>%
              arrange(Country, Year, Month)
          } else
            lcum
        } else
          if (is.null(grouping) && length(cum.across) == 1 && cum.across == "Year") {
            browser()
            lcum <- gather(md3, Year, cumul, -location)
            lcum
          } else
            if (setequal(cum.across, c("Year","Month")) && is.null(grouping)) {
              lcum <- gather(md3, Year.Month, cumul, -location)
              yml <- as.data.frame(do.call(rbind, strsplit(as.vector(lcum$Year.Month), "[.]")),
                                   stringsAsFactors = FALSE)
              colnames(yml) <- cum.across
              cbind(lcum, yml) %>%
                tbl_df %>%
                select(Year, Month, cumul) %>%
                mutate(Month = factor(Month, levels = month.name)) %>%
                arrange(Year, Month)
            } else stop("no grouping")

  #mutate(Year = as.character(Year), Month = factor(Month, levels = month.name)) %>%
  #%>%
  #  arrange(Year, Country, Month) %>% tbl_df %>%
  #  mutate(cumul = ifelse(is.na(cumul), 0, cumul))
}
