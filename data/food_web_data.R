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


# step 1: standardize colnames and values from data sources
    # 1.a `a_data` --> `clean_a_data`
    # 1.b `i_data` --> `clean_i_data`
    # 1.c `p_data` --> `clean_p_data`

# step 4: add isotope columns from `clean_i_data` and `clean_p_data` to `clean_a_data` and add NA values to those columns
#   e.g., clean_a_data$d13c <- NA
#   e.g., clean_a_data$d13c_baseline_mean <- NA
# step 4: left join `clean_p_data` to `clean_i_data` by `isotope_id`
# clean_i_data <- dplyr::left_join(clean_i_data, clean_p_data, by="isotope_id")
# step 5: update colnames in clean_a_data to match clean_i_data
#   clean_a_data <- select(colnames(clean_i_data))
# step 6: filter repeated rows from clean_a_data 
#   clean_a_data <- clean_a_data %>% filter(tube_id != clean_i_data$tube_id)
# step 7: rbind clean_a_data to clean_i_data
#   f_data <- rbind(clean_i_data, clean_a_data)
# step 8: write csv of f_data

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
    rename(sample_id = Tube_ID) %>%
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
    mutate(collected_datetime = as.POSIXct(collected_datetime, format="%Y-%m-%d %H:%M", tz="MST")) %>%
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
    mutate(empty = as.logical(empty)) %>%
    mutate(individuals_count = case_when(
        individuals_count == "0" ~ NA
        ,TRUE ~ individuals_count
    )) %>%
    mutate(tube_box = case_when(
        sample_id == "BDX" ~ "Whirl pak"
        ,sample_id == "SZJ" ~ "Whirl pak"
        ,TRUE ~ tube_box
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
        ,scientific_name == "Midge" ~ "Chironomidae"
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
        ,common_name == "Chiromidae" ~ "Midge"
        ,common_name == "Mosquito" ~ "Mosquito larvae"
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
        ,method_of_take == "Electrofisher" ~ "Backpack electrofisher smith root lr-24"
        ,method_of_take == "Water" ~ "freezing"
        ,depth == 30.0 ~ "Dredge"
        ,method_of_take == "" ~ NA
        ,TRUE ~ method_of_take
    )) %>%
    mutate(oven_temperature_c = 60) %>%
    mutate(in_oven_datetime = case_when(
        in_oven_datetime == "" ~ "1/1/1900 00:00"
        ,nchar(in_oven_datetime) < 14 ~ paste0(in_oven_datetime, " 00:00")
        ,TRUE ~ in_oven_datetime
    )) %>%
    mutate(in_oven_datetime = as.POSIXct(in_oven_datetime, format="%m/%d/%Y %H:%M", tz="MST")) %>%
    mutate(out_oven_datetime = case_when(
        out_oven_datetime == "" ~ "1/1/1900 00:00"
        ,out_oven_datetime == "?" ~ "1/1/1900 00:00"
        ,out_oven_datetime == "FREEZER" ~ "1/1/1900 00:00"
        ,nchar(out_oven_datetime) < 14 ~ paste0(out_oven_datetime, " 00:00")
        ,TRUE ~ out_oven_datetime
    )) %>%
    mutate(
        sample_id = case_when(
            sample_id == 'BWA' & scientific_name == 'Periphyton' ~ 'BWA_15ml' # a 15ml and a 1.5ml sample were given the same sample_id
            ,TRUE ~ sample_id
        )
     )%>%
    mutate(
        lake = case_when(
            lake == 'Mcdonald' ~ 'McDonald' # a 15ml and a 1.5ml sample were given the same sample_id
            ,TRUE ~ lake
        )
     )%>%
    mutate(
        collected_datetime = case_when(
            sample_id == 'IACP' ~ as.POSIXct('2019-07-17 00:00', format="%Y-%m-%d %H:%M", tz="MST") # deep-water chironomids were collected on the same date as zooplankton
            ,sample_id == 'IACQ' ~ as.POSIXct('2019-06-19 00:00', format="%Y-%m-%d %H:%M", tz="MST") # deep-water chironomids were collected on the same date as zooplankton
            ,TRUE ~ collected_datetime
        )
     )%>%
    mutate(out_oven_datetime = as.POSIXct(out_oven_datetime, format="%m/%d/%Y %H:%M", tz="MST")) %>%
    mutate(total_length_mm = as.integer(total_length_mm)) %>%
    filter(sample_id != "") %>%
    filter(!is.na(sample_id)) %>%
    filter(scientific_name != "RM") %>%
    filter(scientific_name != "Unknown") %>%
    filter(common_name != "RM") %>%
    filter(tube_box != "RM") %>%
    select(
        sample_id
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
    ) %>%
    filter(
        !duplicated(sample_id)
    )

clean_i_data <-i_data[,c(
    "Tube_ID"
    ,"Davis_ID_long"
    ,'Isotope.sample.weight..mg.'
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
    rename(sample_id = Tube_ID) %>%
    rename(isotope_id = Davis_ID_long) %>%
    rename(d13c = d13C) %>%
    rename(d15n = d15N) %>%
    rename(sample_net_weight_mg = Isotope.sample.weight..mg.) %>%
    rename(total_c_ug = Total.C..µg.) %>%
    rename(total_n_ug = Total.N..µg.) %>%
    rename(c_comment = C.Comment) %>%
    rename(n_comment = N.Comment) %>%
    rename(type_of_material = Type.of.Material) %>%
    rename(analysis_number = Analysis.Number) %>%
    rename(lab_id = Internal.ID) %>%
    mutate(
        sample_id = case_when(
            sample_id == 'BWA' & isotope_id == 'GOLF-B-07' ~ 'BWA_15ml' # a 15ml and a 1.5ml sample were given the same sample_id
            ,TRUE ~ sample_id
        )
    )

# clean_i_data %>% count(sample_id) %>% filter(n>1) %>% arrange(., desc(n))

clean_p_data <- p_data[,c(
    "Davis_ID_long"
    ,"d13C_baseline"
    ,"d13C_base_se"
    ,"d15N_baseline"
    ,"d15N_base_se"
    ,"d13C_corr"
    ,"d15N_corr"
)] %>%
    rename(isotope_id = Davis_ID_long) %>%
    rename(d13c_baseline_mean = d13C_baseline) %>%
    rename(d13c_baseline_standard_error = d13C_base_se) %>%
    rename(d15n_baseline_mean = d15N_baseline) %>%
    rename(d15n_baseline_standard_error = d15N_base_se) %>%
    rename(d13c_baseline_corrected = d13C_corr) %>%
    rename(d15n_baseline_corrected = d15N_corr)
   
# join to build flattened dataset
f_data <- dplyr::left_join(clean_i_data, clean_p_data, by="isotope_id")
f_data <- dplyr::left_join(clean_a_data, f_data, by='sample_id')

# final wrangling
f_data <- f_data %>%
    mutate(individuals_count = case_when(
        type_of_material == 'Fish' & is.na(individuals_count) ~ 1
        ,TRUE ~ individuals_count
        )
    )

# lookup for f_data$type_of_material
lookup <- data.frame('name' = unique(f_data$scientific_name))
lookup$type <- NA
lookup <-lookup %>%
    mutate(
        type = case_when(
            name == "Richardsonius balteatus" ~ 'Fish'
            ,name == "Ptychocheilus oregonensis" ~ 'Fish'
            ,name == "Catostomus catostomus" ~ 'Fish'
            ,name == "Catostomus macrocheilus" ~ 'Fish'
            ,name == "Prosopium williamsoni" ~ 'Fish'
            ,name == "Salvelinus namaycush" ~ 'Fish'
            ,name == "Salvelinus confluentus" ~ 'Fish'
            ,name == "Oncorhynchus clarkii lewisi" ~ 'Fish'
            ,name == "Cottus cognatus" ~ 'Fish'
            ,name == "Chironomidae" ~ 'Invertebrate'
            ,name == "Hydrachnidia" ~ 'Invertebrate'
            ,name == "Culicidae" ~ 'Invertebrate'
            ,name == "Leptophlebiidae" ~ 'Invertebrate'
            ,name == "Betula spp." ~ 'Plant'
            ,name == "Naididae" ~ 'Invertebrate'
            ,name == "Larix occidentalis" ~ 'Plant'
            ,name == "Amphipoda" ~ 'Invertebrate'
            ,name == "Caenidae" ~ 'Invertebrate'
            ,name == "Isoetes bolanderi" ~ 'Plant'
            ,name == "Elodea canadensis" ~ 'Plant'
            ,name == "Hirudinea" ~ 'Invertebrate'
            ,name == "Notonectidae" ~ 'Invertebrate'
            ,name == "Limnephilidae" ~ 'Invertebrate'
            ,name == "Dytiscidae" ~ 'Invertebrate'
            ,name == "Egg sac" ~ NA
            ,name == "Chara spp." ~ 'Plant'
            ,name == "Allochthonous plant" ~ 'Plant'
            ,name == "Macrophyte" ~ 'Plant'
            ,name == "Allochthonous animal" ~ NA
            ,name == "Ranunculus aquatilis" ~ 'Plant'
            ,name == "Planorbidae" ~ 'Invertebrate'
            ,name == "Seston" ~ NA
            ,name == "Apocrita" ~ 'Invertebrate'
            ,name == "Muscidae" ~ 'Invertebrate'
            ,name == "Polycentropodidae" ~ 'Invertebrate'
            ,name == "Leptoceridae" ~ 'Invertebrate'
            ,name == "Ephemerellidae" ~ 'Invertebrate'
            ,name == "Picea glauca" ~ 'Plant'
            ,name == "Populus spp." ~ 'Plant'
            ,name == "Periphyton" ~ 'Periphyton'
            ,name == "Zooplankton" ~ 'Invertebrate'
            ,name == "Phryganeidae" ~ 'Invertebrate'
            ,name == "Potamogeton" ~ 'Plant'
            ,name == "Sphaeriidae" ~ 'Invertebrate'
            ,name == "Perlidae" ~ 'Invertebrate'
            ,name == "Libellulidae" ~ 'Invertebrate'
            ,name == "Rhyacophilidae" ~ 'Invertebrate'
            ,name == "Heptageniidae" ~ 'Invertebrate'
            ,name == "Simuliidae" ~ 'Invertebrate'
            ,name == "Drepandocladus spp." ~ 'Plant'
            ,name == "Mud" ~ NA
            ,name == "Tabanidae" ~ 'Invertebrate'
            ,name == "Lepidoptera" ~ 'Invertebrate'
            ,name == "Hydrophilidae" ~ 'Invertebrate'
            ,name == "Physidae" ~ 'Invertebrate'
            ,name == "Coenagrionidae" ~ 'Invertebrate'
            ,name == "Elmidae" ~ 'Invertebrate'
            ,name == "Perlodidae" ~ 'Invertebrate'
            ,name == "Ptychopteridae" ~ 'Invertebrate'
            ,name == "Cambarus" ~ 'Invertebrate'
            ,name == "Baetidae" ~ 'Invertebrate'
            ,name == "Ceratopogonidae" ~ 'Invertebrate'
            ,name == "Salvelinus confluentus" ~ 'Fish'
            ,name == "Perca flavescens" ~ 'Fish'
            ,name == "Esox lucius" ~ 'Fish'
            ,name == "Coregonus clupeaformis" ~ 'Fish'
            ,name == "Mylochelius caurinus" ~ 'Fish'
            ,name == "Oncorhynchus nerka" ~ 'Fish'
            ,name == "Prosopium coulterii" ~ 'Fish'
            ,name == "Aeshnidae" ~ 'Invertebrate'
            ,name == "Hydroptilidae" ~ 'Invertebrate'
            ,name == "Turbellaria" ~ 'Invertebrate'
            ,name == "Sialidae" ~ 'Invertebrate'
            ,name == "Dryopidae" ~ 'Invertebrate'
            ,name == "Philopotamidae" ~ 'Invertebrate'
            ,name == "Lymnaeidae" ~ 'Invertebrate'
            ,name == "Pholcidae" ~ 'Invertebrate'
            ,name == "Formicidae" ~ 'Invertebrate'
            ,name == "Apidae" ~ 'Invertebrate'
            ,name == "Ancylidae" ~ 'Invertebrate'
            ,name == "Oligochaeta" ~ 'Invertebrate'
            ,name == "Psephenidae" ~ 'Invertebrate'
            ,name == "Ephemeridae" ~ 'Invertebrate'
            ,name == "Mysis" ~ 'Invertebrate'
            ,name == "Oncorhynchus clarkii bouvieri" ~ 'Fish'
            ,name == "Gerridae" ~ 'Invertebrate'
            ,name == "Oncorhynchus mykiss" ~ 'Fish'
            ,name == "Asellidae" ~ 'Invertebrate'
            ,name == "Lepomis macrochirus" ~ 'Fish'
            ,name == "Umbra limi" ~ 'Fish'
            ,name == "Nepidae" ~ 'Invertebrate'
            ,name == "Salvelinus fontinalis" ~ 'Fish'
            ,name == "Lestidae" ~ 'Invertebrate'
            ,name == "Glossosomatidae" ~ 'Invertebrate'
            ,name == "Tipulidae" ~ 'Invertebrate'
        )
    )

f_data <- dplyr::left_join(f_data, lookup, by=c('scientific_name'='name'))
f_data$type_of_material<- NULL
f_data <- f_data %>% rename(type_of_material = type)
f_data <- f_data %>%
    mutate(individuals_count = case_when(
        is.na(individuals_count) & type_of_material == 'Fish' ~ 1
        ,TRUE ~ individuals_count
    ))
# add back individuals_count numbers that mysteriously disappeared
mysub <- f_data %>%
    filter(
        is.na(individuals_count) & type_of_material == 'Invertebrate'
    )
unique(mysub$sample_id)
myothersub <- a_data %>%
    filter(
        Tube_ID %in% unique(mysub$sample_id) &
        !is.na(Count.of.individuals) &
        Count.of.individuals != ''
    ) %>%
    select(Tube_ID, Count.of.individuals) %>%
    filter(
        !duplicated(Tube_ID)
    )
for(i in 1:nrow(f_data)){
    f_data$individuals_count[i] <- ifelse(
        is.na(f_data$individuals_count[i]) & f_data$sample_id[i] %in% myothersub$Tube_ID,
        subset(myothersub, myothersub$Tube_ID == f_data$sample_id[i])$Count.of.individuals,
        f_data$individuals_count[i]
    )
}






# write as csv
# write.csv(f_data, "data/food_web_2020.csv")