# a module to find mean and se d13c and d15n baseline for lakes in food_web_data.R

library(dplyr)

back_populate <- function(f_data){
    isotope_dataset <- f_data %>%
        select(lake, common_name, scientific_name, type_of_material, d13c, d15n) %>%
        filter(!is.na(d13c) & !is.na(d15n))
    
    # original analysis grouped taxa into "baseline candidate groups", so we re-create that here
    group_name_lookup <- data.frame(
        scientific_name = isotope_dataset$scientific_name
        ,group_name = NA
    ) %>%
        filter(
            !duplicated(scientific_name)
        )
    # program the groupings
    # these are common freshwater trophic baselines, so we evaluate them as baseline candidates in our study
    mayflies <- c("Baetidae","Leptophlebiidae","Heptageniidae","Ephemerellidae") # the study's most abundant ephemeroptera
    caddisflies <- c("Limnephilidae","Leptoceridae") # the study's most abundant trichoptera
    snails <- c("Physidae","Planorbidae","Lymnaeidae") # the study's most abundant mollusk
    zooplankton <- c("Zooplankton") # unsorted zooplankton
    periphyton <- c("Periphyton") # unsorted epiphytic algae and microbes
    # send grouped values into the lookup table
    for(i in 1:nrow(group_name_lookup)){
        if (group_name_lookup$scientific_name[i] %in% mayflies) {
            group_name_lookup$group_name[i] <- "Mayfly"
        } else if (group_name_lookup$scientific_name[i] %in% caddisflies) {
            group_name_lookup$group_name[i] <- "Caddisfly"
        } else if (group_name_lookup$scientific_name[i] %in% snails) {
            group_name_lookup$group_name[i] <- "Snail"
        } else if (group_name_lookup$scientific_name[i] %in% zooplankton) {
            group_name_lookup$group_name[i] <- "Zooplankton"
        } else if (group_name_lookup$scientific_name[i] %in% periphyton) {
            group_name_lookup$group_name[i] <- "Periphyton"
        } else if (group_name_lookup$scientific_name[i] == 'Hydrachnidia') {
            group_name_lookup$group_name[i] <- "Hydrachnidia"
        } else {
            group_name_lookup$group_name[i] <- "other"
        }
    }
    group_name_lookup <- group_name_lookup %>%
        filter(
            # "other" groups were not considered as baseline candidates for our study because literature does not use them
            group_name != 'other'
        )
    
    # add candidate groupings into dataset
    isotope_dataset <- dplyr::left_join(isotope_dataset, group_name_lookup, by='scientific_name') %>%
        filter(
            !is.na(group_name)
        )
    
    # calculate within-candidate isotopic variability for each lake
    mysummary <- isotope_dataset %>%
        group_by(lake, group_name) %>%
        summarise(
            n = n()
            ,mean_d13c = mean(d13c)
            # ,sd_d13c = round(sd(d13c),2)
            ,se_d13c = sqrt(var(d13c)/length(d13c))
            ,mean_d15n = mean(d15n)
            # ,sd_d15n = round(sd(d15n),2)
            ,se_d15n = sqrt(var(d15n)/length(d15n))
            ,total_variability = se_d13c + se_d15n
        ) %>%
        # slice(which.min(total_variability)) %>%
        arrange(., total_variability) %>%
        filter(n>1) # can't calculate standard error for n <= 1
    
    # This table summarizes within-candidate isotopic variability among-lakes, which was the criterion
    # on which our study chose its isotopic baseline. Our study used the candidate with the lowest total
    # isotopic variability (`iso_baseline_candidates$total_variability` shown below) for its trophic baseline.
    # i.e., we chose mayflies as the study's baseline because mayflies had the lowest total isotopic variability
    # of the candidates that we considered.
    iso_baseline_candidates <- mysummary %>%
        group_by(group_name) %>%
        summarize(
            n = sum(n)
            ,mean_d13c_se = round(mean(se_d13c),2)
            ,mean_d15n_se = round(mean(se_d15n),2)
            ,total_variability = mean_d13c_se + mean_d15n_se
        ) %>%
        arrange(., total_variability)
    
    # now that have reproduced the analysis showing that mayflies are the right trophic baseline for our study area,
    # we need to back-populate the baselines into f_data to then calculate the baseline-corrected d13c and d15n for each sample
    baselines <- mysummary %>%
        filter(
            lake %in% unique(mysummary$lake)
            ,group_name == 'Mayfly'
        ) %>%
        select(
            lake
            ,mean_d13c
            ,se_d13c
            ,mean_d15n
            ,se_d15n
        )
    
    # back-populate the dataset's baseline d13c and d15n for the three lakes that don't already have values
    before_columns <- colnames(f_data)
    f_data$lake_d13c_baseline_mean <- NULL
    f_data$lake_d15n_baseline_mean <- NULL
    f_data$lake_d13c_baseline_standard_error <- NULL
    f_data$lake_d15n_baseline_standard_error <- NULL
    
    f_data <- dplyr::left_join(f_data, baselines, by='lake') %>%
        rename(lake_d13c_baseline_mean = mean_d13c) %>%
        rename(lake_d15n_baseline_mean = mean_d15n) %>%
        rename(lake_d13c_baseline_standard_error = se_d13c) %>%
        rename(lake_d15n_baseline_standard_error = se_d15n) %>%
        select(all_of(before_columns))
    
    # test that the back-population worked
    # f_data %>%
    #     filter(!duplicated(lake)) %>%
    #     select(
    #         lake
    #         ,lake_d13c_baseline_mean
    #         ,lake_d13c_baseline_standard_error
    #         ,lake_d15n_baseline_mean
    #         ,lake_d15n_baseline_standard_error
    #     ) %>%
    #     arrange(., lake)
    
    return(f_data)
}
