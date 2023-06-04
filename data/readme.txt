Readme for food_web_2020.csv

Description: A flat-file containing data on all biological specimens collected between 2017 and 2020 to examine the food web structure of Northwestern Montana lakes. One row is one `Tube_ID`, which is either (a) one individual fish (b) all individuals of a macroinvertebrate taxon from a unique combination of lake, transect, depth, date (c) bulk periphyton from a unique combination of lake, date (d) bulk zooplankton from a unique combination of lake, date (e) other (e.g., a handful of larch needles). A subset of the specimens in this flat-file were analyzed for d13C and d15N. As of June 2020, samples were frozen for long-term storage at Flathead Lake Biological Station, Polson, MT.

Variable abbreviation definitions:
str: string
int: integer
float: floating point number
bool: boolean

Metadata:

Data fields for all specimens: data that were collected for all specimens, regardless of whether they underwent stable isotope analyses.

tube_id: str. The unique identifier for a sample specimen.
collected_datetime: str. Datetime the specimen was collected. yyyy-mm-dd hh:mm. A date of 1900-01-01 is an unknown or missing date. A time of 00:00 is an unknown or missing time.
lake: str. Name of the lake from which the specimen was collected.
latitude: float. Latitude at which the specimen was collected. Decimal degrees north.
longitude: float. Longitude at which the specimen was collected. Decimal degrees east.
individuals_count: int. Count of individual specimens preserved in this `Tube_ID`.
scientific_name: str. Latin name of specimen. Fish species, macroinvertebrate family, bulk zooplankton, bulk periphyton.
common_name: str. Common name of specimen. Fish species, macroinvertebrate family, bulk zooplankton, bulk periphyton.
total_length_mm: int. The total length of the fish. Millimeters.
weight_g: float. The mass of the fish. Grams.
depth: float. The depth below the lake water surface from which the specimen was collected. Meters.
tube_box: str. The unique identifier for the box or bag in which the specimen tubes are are stored.
tube_size_ml: float. The size of the tube in which the specimen was stored. Milliliters. Usually 1.5 ml flip-cap eppendorfs or 15 ml or 50 ml screw-cap falcon tubes.
preservative: str. The method by which the specimen was preserved while afield.
method_of_take: str. The method by which the specimen was captured afield.
in_oven_datetime: str. The datetime when the specimen was placed into the drying oven. yyyy-mm-dd hh:mm
oven_temperature_c: int. The oven temperature at which the specimens were held for drying. Degrees celsius.
out_oven_datetime: str. The datetime when the specimen was removed from the drying oven. yyyy-mm-dd hh:mm
empty: bool. TRUE indicates the tube contains no more biological material for the specimen. FALSE indicates that the tube contained a non-zero amount of specimen biological material after preparing isotope caps.

Data fields for isotope samples: lab results from the subset of specimens that were analyzed for d13C and d15N.

isotope_id: str. The unique identifier for an isotope sample. Naming convention: `Tray name`-`Row letter`-`column number`. NA indicates that the `Tube_ID` was not analyzed for d13C and d15N.
sample_weight_mg: float. The mass of biological material sent to the lab for isotope analysis.
d13c: float. delta 13C of the specimen. Permille.
d15n: float. delta 15N of the specimen. Permille.
total_c: float. Total carbon of the specimen. Micrograms.
total_n: float. Total nitrogen of the specimen. Micrograms.
c_comment: str. Comments about the carbon in a specimen from the lab.
n_comment: str. Comments about the nitrogen in a specimen from the lab.
type_of_material: str. Description of the biological material.
analysis_number: str. A specimen id from the lab.
lab_id: str. Another specimen id from the lab.

Derived fields for isotope samples: values calculated from the lab's d13C and d15N and used to make inferences. 

d13c_baseline_mean: float. Mean d13C of the lake's trophic baseline. Permille.
d13c_baseline_se: float. Standard error d13C of the lake's trophic baseline. Permille.
d15n_baseline_mean: float. Mean d13C of the lake's trophic baseline. Permille.
d15n_baseline_se: float. Standard error d13C of the lake's trophic baseline. Permille.
d13c_corr: float. The baseline-corrected d13C of the specimen. Permille.
d15n_corr: float. The baseline-corrected d15N of the specimen. Permille.