# data_processing
Convenient data processing scripts to make life easier


# massSpec_spreadsheet_wrangling.wl

(added 2023.10.18)

```
(* Import the necessary code; ony needed once per session *)
<< "https://raw.githubusercontent.com/mfbliposome/data_processing/main/massSpec_spreadsheet_wrangling.wl"

(* set the file path: Insert>FilePath... *)
file = "~/Downloads/2023.10.18_maurer_masspec_spreadsheetwrangling/peak areas.xlsx";

(* run the function; results are not sorted *)
results = parseFile[file]

(* sort the results by the "week" column and export to a new XLSX file *)
Export[
     "2023.10.18_peak_areas_clean.xlsx",
     results[SortBy["week"]]]
```
