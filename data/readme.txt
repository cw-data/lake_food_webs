Readme for food_web_2020.csv

Description: `food_web_2020.csv` is a flat file containing data on all biological specimens collected between 2017 and 2020 to examine the food web structure of Northwestern Montana lakes. The "key field" for this flat file is (`sample_id`, `isotope_id`) (i.e., one row in the flat file is one unique combination of `sample_id` and `isotope_id`). A biological specimen in this file is either (a) one individual fish (b) all individuals of a macroinvertebrate taxon from a unique combination of lake, transect, depth, date (c) bulk periphyton from a unique combination of lake, date (d) bulk zooplankton from a unique combination of lake, date (e) other (e.g., a handful of larch needles). Not all specimens were analyzed for d13C and d15N, which means that some `sample_id`s do not have an `isotope_id` nor d13c and d15n. As of June 2020, specimens were frozen for long-term storage in the indoor/outdoor storage beside Flathead Lake Biological Station's lab (Polson, MT).

Variable-type abbreviation definitions:
str: text string
int: integer
float: floating point number
bool: boolean

Metadata:

Data collected for all specimens, regardless of whether they underwent stable isotope analyses:

sample_id: str. The unique identifier for a sample specimen (i.e., an eppendorf or falcon tube containing one or more biological samples). Note: `sample_id` is not a key field because a `sample_id` may contain multiple individuals of the same taxon (e.g., many macroinvertebrates), which could be combined to create multiple `isotope_id`s.
collected_datetime: str. Datetime the specimen was collected. yyyy-mm-dd hh:mm. A date of 1900-01-01 is an unknown or missing date. A time of 00:00 is an unknown or missing time.
lake: str. Name of the lake from which the specimen was collected.
sample_latitude: float. Latitude at which the specimen was collected. Decimal degrees north.
sample_longitude: float. Longitude at which the specimen was collected. Decimal degrees east.
individuals_count: int. Count of individual specimens preserved in this `sample_id`.
scientific_name: str. Latin name of specimen. Fish species, macroinvertebrate family, bulk zooplankton, bulk periphyton.
common_name: str. Common name of specimen. Fish species, macroinvertebrate family, bulk zooplankton, bulk periphyton.
fish_total_length_mm: int. The total length of the fish. Millimeters.
fish_weight_g: float. The mass of the fish. Grams.
depth: float. The depth below the lake water surface from which the specimen was collected. Meters.
tube_box: str. The unique identifier for the box or bag in which the specimen tubes are stored.
tube_size_ml: float. The size of the tube in which the specimen was stored. Milliliters. Usually 1.5 ml flip-cap eppendorfs or 15 ml or 50 ml screw-cap falcon tubes.
preservative: str. The method by which the specimen was preserved while afield.
method_of_collection: str. The method by which the specimen was collected afield.
in_oven_datetime: str. The datetime when the specimen was placed into the drying oven. yyyy-mm-dd hh:mm.
oven_temperature_c: int. The oven temperature at which the specimens were held for drying. Degrees celsius.
out_oven_datetime: str. The datetime when the specimen was removed from the drying oven. yyyy-mm-dd hh:mm.
empty: bool. TRUE indicates the `sample_id` tube contains no biological material for the specimen. FALSE indicates that the tube contained a non-zero amount of specimen biological material after preparing isotope caps.

Lab results from the subset of specimens that were analyzed for d13C and d15N:

isotope_id: str. The unique identifier for an isotope sample. Naming convention: `tray name`-`row letter`-`column number`. NA indicates that the `sample_id` was not analyzed for d13C and d15N.
sample_net_weight_mg: float. The mass of specimen biological material sent to UC Davis lab for isotope analysis.
d13c: float. delta 13C of the specimen, measured by UC Davis. Permille.
d15n: float. delta 15N of the specimen, measured by UC Davis. Permille.
total_c_ug: float. Total carbon of the specimen, measured by UC Davis. Micrograms.
total_n_ug: float. Total nitrogen of the specimen, measured by UC Davis. Micrograms.
c_comment: str. Comments from UC Davis lab about the carbon in a specimen.
n_comment: str. Comments from UC Davis lab about the nitrogen in a specimen.
type_of_material: str. Description of the biological material.
analysis_number: str. A specimen id from UC Davis lab.
lab_id: str. A specimen id from UC Davis lab.

Values calculated from UC Davis's `d13c` and `d15n` and used to make inferences in Northwestern Montana lake food webs: 

lake_d13c_baseline: float. Lake-specific d13C trophic baseline; used to calculate `d13c_baseline_corrected`. Permille.
lake_d15n_baseline: float. Lake-specific d15N trophic baseline; used to calculate `d15n_baseline_corrected`. Permille.
d13c_baseline_corrected: float. The baseline-corrected d13C of the specimen. Calculated via `d13c` - `lake_d13c_baseline` = `d13c_baseline_corrected`. Permille.
d15n_baseline_corrected: float. The baseline-corrected d15N of the specimen. Calculated via `d15n` - `lake_d15n_baseline` = `d15n_baseline_corrected`. Permille.