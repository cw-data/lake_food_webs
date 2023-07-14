secchi <- function(){
    secchi_data <- readxl::read_excel('data/source/secchi.xlsx')
    secchi_data <- secchi_data %>%
        rename(
            latitude = lat
            ,longitude = lon
        ) %>%
        mutate(
            date = as.character(date)
            ,time = as.character(strftime(time, "%H:%M:%S"))
            ,datetime = as.POSIXct(paste(date, time))
        ) %>%
        filter(
            !is.na(secchi_m)
        ) %>%
        select(-c(date, time))
    return(secchi_data)
}