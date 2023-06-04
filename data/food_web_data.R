rm(list=ls())
graphics.off()
set.seed(1)
library(dplyr)

# readme
# this script parses all of the field and lab data collected for the 2017-2020 "food web study"

# there are three "source" data files:
# 1. a_data. All of the data, regardless of whether those samples became isotope samples.
# 2. i_data. The subset of samples in `alldata` that was sent to the lab for stable isotope analysis.
# 3. p_data. The subset of `i_data` that was analyzed. Same as `i_data` but excludes Lower Quartz lake and Grace lake.

# sources
a_data <- read.csv("data/source/a_data.csv", header = TRUE)
i_data <- read.csv("data/source/i_data.csv", header = TRUE)
p_data <- read.csv("data/source/p_data.csv", header = TRUE)

clean_a_data <- a_data[, c(
    "Tube_ID"
    ,"Collected_date"
    ,"Collected_time"
    ,"Lat"
    ,"Long"
    ,"Lake_name"
    ,"Vial_count"
    ,"Scientific_name"
    ,"Common_name"
    ,"Total_length_mm"
    ,"Weight_g"
    ,"Depth"
    ,"Tube_box"
    ,"Tube_size_ml"
    ,"Preservative"
    ,"Method_of_take"
    ,"In_oven_date"
    ,"Oven_temp_.C."
    ,"Out_oven_date"
    ,"Empty."
    )] %>%
    rename(tube_id = Tube_ID) %>%
    rename(collected_date = Collected_date) %>%
    rename(collected_time = Collected_time) %>%
    rename(latitude = Lat) %>%
    rename(longitude = Long) %>%
    rename(lake = Lake_name) %>%
    rename(individuals_count = Vial_count) %>%
    rename(scientific_name = Scientific_name) %>%
    rename(common_name = Common_name) %>%
    rename(total_length_mm = Total_length_mm) %>%
    rename(weight_g = Weight_g) %>%
    rename(depth = Depth) %>%
    rename(tube_box = Tube_box) %>%
    rename(tube_size_ml = Tube_size_ml) %>%
    rename(preservative = Preservative) %>%
    rename(method_of_take = Method_of_take) %>%
    rename(in_oven_datetime = In_oven_date) %>%
    rename(oven_temperature_c = Oven_temp_.C.) %>%
    rename(out_oven_datetime = Out_oven_date) %>%
    rename(empty = Empty.) %>%
    mutate(collected_time = case_when(
        collected_time == "" ~ "00:00"
        ,is.na(collected_time) ~ "00:00"
        ,TRUE ~ collected_time
    )) %>%
    mutate(collected_date = case_when(
        collected_date == "" ~ "1/1/1900"
        ,TRUE ~ collected_date
    )) %>%
    mutate(latitude = case_when(
        latitude == "" ~ NA
        ,latitude == "tbd" ~ NA
        ,TRUE ~ latitude
    )) %>%
    mutate(individuals_count = case_when(
        individuals_count == "" ~ NA
        ,individuals_count == "tbd" ~ NA
        ,TRUE ~ individuals_count
    )) %>%
    mutate(individuals_count = as.integer(individuals_count)) %>%
    mutate(longitude = case_when(
        longitude == "" ~ NA
        ,longitude == "tbd" ~ NA
        ,TRUE ~ longitude
    )) %>%
    mutate(collected_date = format(as.Date(collected_date, "%m/%d/%Y"), "%Y-%m-%d")) %>%
    mutate(collected_time = case_when(
        nchar(collected_time) < 5 ~ paste0("0",collected_time)
        ,TRUE ~collected_time
    )) %>%
    mutate(collected_datetime = paste0(collected_date, " ", collected_time)) %>%
    mutate(collected_date = NULL) %>%
    mutate(collected_time = NULL) %>%
    mutate(empty = case_when(
        empty == "D" ~ "TRUE"
        ,empty == "" ~ "FALSE"
        ,empty == "extra" ~ "FALSE"
        ,empty == "empty" ~ "TRUE"
        ,empty == "rm" ~ "TRUE"
        ,empty == "RM" ~ "TRUE"
        ,empty == "Y" ~ "TRUE"
        ,empty == "N" ~ "FALSE"
        ,empty == "Not enough for isotope sample 9/3/19 cw" ~ "TRUE"
        ,is.na(empty) ~ "FALSE"
        ,TRUE ~ paste(empty, "problem")
    )) %>%
    mutate(individuals_count = case_when(
        individuals_count == "0" ~ NA
        ,TRUE ~ individuals_count
    )) %>%
    mutate(tube_box = case_when(
        tube_box == "" ~ "NA"
        ,tube_box == "?" ~ "NA"
        ,TRUE ~ tube_box
    )) %>%
    mutate(tube_size_ml = case_when(
        tube_size_ml == "" ~ "NA"
        ,TRUE ~ tube_size_ml
    )) %>%
    mutate(scientific_name = case_when(
        scientific_name == "Phytoplankton" ~ "Seston"
        ,scientific_name == "Potamogeton spp." ~ "Potamogeton"
        ,common_name == "Mosquito" ~ "Culicidae"
        ,common_name == "Moth" ~ "Lepidoptera"
        ,common_name == "Spiny crawler mayfly" ~ "Ephemerellidae"
        ,common_name == "Mountain whitefish" ~ "Prosopium williamsoni"
        ,common_name == "Northern pikeminnow" ~ "Ptychocheilus oregonensis"
        ,common_name == "Bull trout" ~ "Salvelinus confluentus"
        ,common_name == "Longnose sucker" ~ "Catostomus catostomus"
        ,common_name == "Westslope cutthroat trout" ~ "Oncorhynchus clarkii lewisi"
        ,common_name == "Pygmy whitefish" ~ "Prosopium coulterii"
        ,TRUE ~ scientific_name
    )) %>%
    mutate(common_name = case_when(
        common_name == "Phytoplankton" ~ "Seston"
        ,scientific_name == "Macrophyte" ~ "Macrophyte"
        ,scientific_name == "Potamogeton" ~ "Pondweed"
        ,scientific_name == "Chironomidae" ~ "Midge"
        ,scientific_name == "Sphaeriidae" ~ "Fingernail clam"
        ,scientific_name == "Libellulidae" ~ "Skimmer dragonfly"
        ,scientific_name == "Dytiscidae" & common_name== "" ~ "Predaceous diving beetle adult"
        ,TRUE ~ common_name
    )) %>%
    mutate(preservative = case_when(
        preservative == "" ~ "95% ethanol"
        ,preservative == "Ethanol" ~ "95% ethanol"
        ,preservative == "Water" ~ "freezing"
        ,TRUE ~ preservative
    )) %>%
    mutate(method_of_take = case_when(
        method_of_take == "Gill net MFWP" ~ "Gill net MTFWP"
        ,method_of_take == "Electrofisher" ~ "Backpack electrofisher"
        ,method_of_take == "Water" ~ "freezing"
        ,depth == 30.0 ~ "Dredge"
        ,method_of_take == "" ~ "NA"
        ,TRUE ~ method_of_take
    )) %>%
    mutate(in_oven_datetime = case_when(
        in_oven_datetime == "" ~ "1/1/1900 00:00"
        ,nchar(in_oven_datetime) < 14 ~ paste0(in_oven_datetime, " 00:00")
        ,TRUE ~ in_oven_datetime
    ))
    # in_oven_datetime = format(as.POSIXct(in_oven_datetime, "%m/%d/%Y %h:%m"), "%Y-%m-%d %h:%m")) %>%
    mutate(total_length_mm = as.integer(total_length_mm)) %>%
    filter(tube_id != "") %>%
    filter(!is.na(tube_id)) %>%
    filter(scientific_name != "RM") %>%
    filter(scientific_name != "Unknown") %>%
    filter(common_name != "RM") %>%
    filter(tube_box != "RM") %>%
    select(
        tube_id
        ,collected_datetime
        ,lake
        ,latitude
        ,longitude
        ,individuals_count
        ,scientific_name
        ,common_name
        ,total_length_mm
        ,weight_g
        ,depth
        ,tube_box
        ,tube_size_ml
        ,preservative
        ,method_of_take
        ,in_oven_datetime
        ,oven_temperature_c
        ,out_oven_datetime
        ,empty
    )
wtf <- final_data %>% filter(
    method_of_take %in% c("")
)

name_check <- data.frame(common_name = unique(final_data$common_name), sci_name = NA)
for(i in 1:nrow(name_check)){
    name_check$sci_name[i] <- length(unique(subset(final_data, final_data$common_name == name_check$common_name[i])$scientific_name))
}

clean_i_data <-i_data[,c(
    "Tube_ID"
    ,"Davis_ID_long"
    ,"d13C"
    ,"d15N"
    ,"Total.C..µg."
    ,"Total.N..µg."
    ,"C.Comment"
    ,"N.Comment"
    ,"Type.of.Material"
    ,"Analysis.Number"
    ,"Internal.ID"
)] %>%
    rename(tube_id = Tube_ID) %>%
    rename(isotope_id = Davis_ID_long) %>%
    rename(d13c = d13C) %>%
    rename(d15n = d15N) %>%
    rename(total_c = Total.C..µg.) %>%
    rename(total_n = Total.N..µg.) %>%
    rename(c_comment = C.Comment) %>%
    rename(n_comment = N.Comment) %>%
    rename(type_of_material = Type.of.Material) %>%
    rename(analysis_number = Analysis.Number) %>%
    rename(lab_id = Internal.ID)

clean_p_data <- p_data[,c(
    "Tube_ID"
    ,"d13C_baseline"
    ,"d13C_base_se"
    ,"d15N_baseline"
    ,"d15N_base_se"
    ,"d13C_corr"
    ,"d15N_corr"
)] %>%
    rename(tube_id = Tube_ID) %>%
    rename(d13c_baseline_mean = d13C_baseline) %>%
    rename(d13c_baseline_standard_error = d13C_base_se) %>%
    rename(d15n_baseline_mean = d15N_baseline) %>%
    rename(d15n_baseline_standard_error = d15N_base_se) %>%
    rename(d13c_baseline_corrected = d13C_corr) %>%
    rename(d1nN_baseline_corrected = d15N_corr)
    

f_data <- dplyr::left_join(clean_a_data, clean_i_data, by="tube_id")
f_data <- dplyr::left_join(f_data, clean_p_data, by="tube_id")

#write as csv
write.csv(f_data, "data/food_web_2020.csv")