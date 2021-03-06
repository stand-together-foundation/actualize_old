---
title: "Data Imports for Project Actualize"
output: 
  rmarkdown::html_vignette: 
    keep_md: yes
vignette: >
  %\VignetteIndexEntry{Data Imports for Project Actualize}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



## Prerequisites

In order to access data as described in this tutorial, you will need 

1. Access to data stored in the impact team's Google Drive, 

2. Access to the statistical programming language R, and ideally RStudio as an IDE, and 

3. Within R, the current version of the `googledrive`, `dotenv`, `tidyverse`, and `paws` packages. 

4. The current version of the [1Password CLI](https://app-updates.agilebits.com/product_history/CLI2) installed locally. 

5. Completion of the ["Getting Started"](https://developer.1password.com/docs/cli/get-started) steps for the 1Password CLI. At a minimum, you should be able to complete the "Sign in to your account" steps on that page.

6. Access to the data science vault on Last Pass, and the actualize secure note which contains environment variable specifications for this tutorial. If you do not have access to this resource, ask Tyler Carolan or Joe Mienko to provide you with access. 

7. Run the `get-env-vars.sh` script at the root of this repository. This will use your OP credentials to assign the environment variables referenced above. 

5. The current version of the [AWS CLI]() installed locally. 

## Data Storage

For the time being all production measurement data will be stored using a Google Drive directory to allow for secured sharing with external organizations with a need to access our data. This is a temporary solution while we establish a formal database with access controls and other security protocols related to STF Impact data resources. 

Raw data are stored at the following [link](https://drive.google.com/drive/u/0/folders/1rYTPZUaRXz6j-MerITWoXaaXXVDlKDBn), with access to the data controlled by Joe Mienko or Tyler Carolan.

Within the `actualize-data` directory, data sets are stored by engagement, with the directory named after the engagement (e.g. LCLC), and the raw data stored within that top-level directory. So, for LCLC, data are stored in `My Drive\actualize-data\LCLC\60 Decibels_LCLC Stand Together Anonymized Raw Data_July 2021.csv`. 

-- The root directory (`My Drive`) is common to all Google Drive users. 

-- The shared directory (`actualize-data`) is the root of all shared data.

-- The project directory (`LCLC`) contains the data and any relevant contextual files. In this case, the data are in a file named `60 Decibels_LCLC Stand Together Anonymized Raw Data_July 2021.csv`.

## Data Access

Data can be accessed using the Google Drive UI, or programatically using R. To access using R, you will need to first obtain the "Drive file id" for use in the `drive_get()` function from within the `googledrive` package. The `drive_get()` function gathers metadata from files specified by the "Drive file id". These metadata can be used to download data for local analysis. The easiest way to accomplish this is to obtain the id from the Google Drive UI. The "Drive file id" can be parsed from the URL and passed to the `drive_get()` function, or you can just pass the entire URL to the function and `drive_get()` will parse the id out of the URL for you. 

To prevent duplication of efforts, the Impact team has created an environment file containing URLs to all files used to build the integrated impact database (IID) within the root of the current repository (`.env-file-urls`). This file can be loaded into your local environment using the `dotenv` package which has a single core function that sources environment files into a local R session. The following chunk loads the environment file. 


```r
library(dotenv)

dotenv::load_dot_env(
  file = '../.env-file-urls'
)
```

With the environment variables loaded we can load the meta data for each piece of IID source data as shown below. Before we do though, you need to either refresh your authentication token (or download a nmew token). Simply running the `googledrive::drive_auth()` should help ensure that you are properly authenticated across our many stores of data. 


```r
library(googledrive)

drive_auth()
```

From there, you should be able to load the relevant metadata for any of the files with URLs stored in the `.env-file-urls` file. If you want to add a new file to our import process, you should complete the following steps: 

1. Pull a new branch from the `actualize-import` [repository](https://github.com/stand-together-foundation/actualize-import). 

2. Update the `.env-file-urls` with the appropriate `KEY=value` pair. As of this writing, data from organizational engagements have an upper-case key followed by the sequence of the engagement. So, for an organization like Family Promise, the key for the first engagement would be `FAMILY_PROMISE1`, and the key for the second engagement would be `FAMILY_PROMISE2`, etc. The values would be the Google Drive url for the source data. Population-based data keys are named after the geographic scope of the data collection (e.g. `NATIONAL2` in the case of the YouGov data collection from the end of 2021, `NATIONAL1` in the case of the so-called "Amplify" data collection). As of the date of this writing we have three population-based sources: 

    - `NATIONAL1` *The so-called "Amplify" data*
    
    - `NATIONAL2` *National data from the How are Americans doing (HAAD) survey, collected by YouGov*
    
    - `LOCAL1` *Local data strategically chosen based on STF 2022 priorities*
    

3. Update this README to include reference to the new data as needed, and recompile the file locally so that the full import process is completed for old and new data sources. 

4. Push your changes to the remote branch, and make a new PR to a member of the STF measurement team. 

## Metadata

With the relevant URLs read as outlined above, you should be able to grab the metadata needed to complete the imports through the object assignments in the following chunk. 


```r
dbg1 <- drive_get(
  id = Sys.getenv("DBG1")
)

family_promise1 <- drive_get(
  id = Sys.getenv("FAMILY_PROMISE1")
)

yonique1 <- drive_get(
  id = Sys.getenv("YONIQUE1")
)

lclc1 <- drive_get(
  id = Sys.getenv("LCLC1")
)

dfree1 <- drive_get(
  id = Sys.getenv("DFREE1")
)

national1 <- drive_get(
  id = Sys.getenv("NATIONAL1")
)

local1 <- drive_get(
  id = Sys.getenv("LOCAL1")
)

national2<- drive_get(
  id = Sys.getenv("NATIONAL2")
)
```

## Import

The `drive_download()` function can now use the metadata objects to download the raw data locally for further analysis. The code below will download data into a `data` directory within the `actualize-import` repo. The data directory is also referenced within the `.gitignore` file so that data can be utilized locally, but not pushed to git/GitHub when attempting to merge back into the main branch, or collaborate with a colleague. 


```r
drive_download(
  dbg1,
  path = "~/actualize/data/dbg1.xlsx", 
  overwrite = TRUE, 
)

drive_download(
  family_promise1,
  path = "~/actualize/data/family_promise1.xlsx", 
  overwrite = TRUE
)

drive_download(
  yonique1,
  path = "~/actualize/data/yonique1.xlsx", 
  overwrite = TRUE
)

drive_download(
  lclc1,
  path = "~/actualize/data/lclc1.xlsx", 
  overwrite = TRUE
)

drive_download(
  dfree1,
  path = "~/actualize/data/dfree1.xlsx", 
  overwrite = TRUE
)

drive_download(
  national1,
  path = "~/actualize/data/national1.xlsx", 
  overwrite = TRUE
)

drive_download(
    local1,
    path = "~/actualize/data/local1.csv",
    overwrite = TRUE
)

drive_download(
    national2,
    path = "~/actualize/data/national2.sav", 
    overwrite = TRUE
)
```

## Tibbles

The `tidyverse` utilizes a concept known as "tibbles" instead of the traditional data.frame utilized in most of the R codebase. Tibbles are data frames, but they improve upon some obnoxious properties of data.frames and make it easier to print and subset your data. The final step in our import process will be to convert all of our data to tibbles. 

### Import from SPSS


```r
library(tidyverse)

national2 <- haven::read_sav(
  "~/actualize/data/national2.sav"
)
```

### Import from Microsoft Excel


```r
dbg1 <- readxl::read_xlsx(
  "~/actualize/data/dbg1.xlsx"
)

dfree1 <- readxl::read_xlsx(
  "~/actualize/data/dfree1.xlsx"
)

lclc1 <- readxl::read_xlsx(
  "~/actualize/data/lclc1.xlsx"
)

familypromise1 <- readxl::read_xlsx(
  "~/actualize/data/family_promise1.xlsx"
)

yonique1 <- readxl::read_xlsx(
  "~/actualize/data/yonique1.xlsx"
)

national1 <- readxl::read_xlsx(
  "~/actualize/data/national1.xlsx"
)
```

### Import from CSV (on S3)

The following chunks import data from CSV files located on an S3 bucket maintained by i360.


```r
# 
# dotenv::load_dot_env(
#   file = '.env-personal'
# )
# 
# ops <- setup_op(
#   domain = Sys.getenv("OP_DOMAIN"), 
#   email = Sys.getenv("OP_EMAIL"),
#   masterpassword = Sys.getenv("OP_MASTERPASSWORD"),
#   secretkey = Sys.getenv("OP_SECRETKEY")
# ) 
# 
# system2(
#   'op', 
#   args = c('signin', Sys.getenv("OP_DOMAIN"), Sys.getenv("OP_EMAIL"), Sys.getenv("OP_SECRETKEY"), '--raw'), 
#   input = masterpassword, 
#   stdout = TRUE, 
#   stderr = TRUE
# )
# 
# 
# system2(
#   'op', 
#   args = c('signin', Sys.getenv("OP_DOMAIN"), '--raw'), 
#   input = Sys.getenv("OP_MASTERPASSWORD"), 
#   stdout = TRUE, 
#   stderr = TRUE)
# )
```


```r
# 
# library(dplyr)
# library(paws)
# 
# get_max_file_location <- function(bucket_contents) {
#   bucket_contents_names <- paste0('X', 1:length(bucket_contents))
#   
#   names(bucket_contents) <- bucket_contents_names
#   
#   max_file_location <- as.data.frame(lapply(bucket_contents, unlist)) %>%
#     rownames_to_column() %>%
#     bind_rows() %>%
#     pivot_longer(cols = bucket_contents_names) %>%
#     filter(rowname == "LastModified") %>%
#     mutate(value = as.integer(value)) %>%
#     filter(value == max(value)) %>%
#     .$name %>%
#     readr::parse_number() 
#   
#   return(max_file_location)
# }
# 
# dotenv::load_dot_env()
# 
# # Shared Data ID
# shared_google_drive <- googledrive::drive_get(id = "1H1Q5k0CnaadKKCH1hFIZetrDLev5OlZl")
# 
# s3_i360 <- paws::s3(
#   config = list(
#     credentials = list(
#       creds = list(
#         access_key_id = Sys.getenv("I360_ACCESS_KEY_ID"),
#         secret_access_key = Sys.getenv("I360_SECRET_ACCESS_KEY")
#       )
#     ),
#     region = Sys.getenv("I360_REGION")
#   )
# )
# 
# bucket_contents <- s3_i360$list_objects(
#   Bucket = Sys.getenv("I360_S3_BUCKET")
# ) %>% 
#   .$Contents
# 
# bucket_contents %>%
#   .[[get_max_file_location(bucket_contents)]] %>%
#   .$Key %>% 
#   s3_i360$get_object(
#     Bucket = Sys.getenv("I360_S3_BUCKET"), 
#     Key = .) %>%
#   .$Body %>%
#   readr::write_file(
#     ., 
#     "i360_local_data.csv"
#   )
# 
# drive_upload(
#   media = "i360_local_data.csv",
#   path = shared_google_drive,
#   overwrite = TRUE, verbose = TRUE
# )
```


```r
# local1 <- readxl::read_xlsx(
#   "~/actualize/data/local.csv"
# )
```


