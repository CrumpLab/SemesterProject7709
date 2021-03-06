# Lab 1

Download the Lab1_data.xlsx data file. This file contains fake data for a 2x3x2 repeated measures design, for 10 participants. The data is in wide format. Here is the link.

<https://github.com/CrumpLab/rstatsmethods/raw/master/vignettes/Stats2/Lab1_data.xlsx>

Your task is to convert the data to long format, and store the long-format data in a data.frame or tibble. Print out some of the long-form data in your lab1.Rmd, to show that you did make the appropriate conversion. For extra fun, show two different ways to solve the problem.

If you need to modify the excel by hand to help you solve the problem that is OK, just make a note of it in your lab work.

## Solution


```r
# read in data
library(readxl)
#> Warning: package 'readxl' was built under R version 4.1.2

wide_data <- read_xlsx("data/Lab1_data.xlsx")
#> New names:
#> • `` -> `...1`
#> • `` -> `...3`
#> • `` -> `...4`
#> • `` -> `...5`
#> • `` -> `...6`
#> • `` -> `...7`
#> • `` -> `...9`
#> • `` -> `...10`
#> • `` -> `...11`
#> • `` -> `...12`
#> • `` -> `...13`

# need to handle the column headers

# input only column headers
wide_headers <- read_xlsx("data/Lab1_data.xlsx",
                          range = "B1:M3", 
                          col_names=FALSE)
#> New names:
#> • `` -> `...1`
#> • `` -> `...2`
#> • `` -> `...3`
#> • `` -> `...4`
#> • `` -> `...5`
#> • `` -> `...6`
#> • `` -> `...7`
#> • `` -> `...8`
#> • `` -> `...9`
#> • `` -> `...10`
#> • `` -> `...11`
#> • `` -> `...12`

# extract individual levels, and repeat level to fill design
IV1 <- as.character(wide_headers[1,])
IV1 <- IV1[is.na(IV1) == FALSE]
IV1 <- rep(IV1, each = 6)

IV2 <- as.character(wide_headers[2,])
IV2 <- IV2[is.na(IV2) == FALSE]
IV2 <- rep(IV2, each=2)

IV3 <- as.character(wide_headers[3,])
IV3 <- IV3[is.na(IV3) == FALSE]

# create a single row version of column headers
one_row_header <- paste(IV1,IV2,IV3, sep="_")

# read in data again, skipping unnecessary column headers

wide_data <- read_xlsx("data/Lab1_data.xlsx", skip = 2)
#> New names:
#> • `A` -> `A...2`
#> • `B` -> `B...3`
#> • `A` -> `A...4`
#> • `B` -> `B...5`
#> • `A` -> `A...6`
#> • `B` -> `B...7`
#> • `A` -> `A...8`
#> • `B` -> `B...9`
#> • `A` -> `A...10`
#> • `B` -> `B...11`
#> • `A` -> `A...12`
#> • `B` -> `B...13`

# replace names with new column headers 

names(wide_data)[2:13] <- one_row_header

# use pivot_longer to convert to long

library(tidyr)
#> Warning: package 'tidyr' was built under R version 4.1.2

long_data <- wide_data %>% pivot_longer(
  cols = 2:13,
  names_to = c("Loudness","Time","Letter"),
  names_pattern = "(.*)_(.*)_(.*)",
  values_to = "DV"
)

knitr::kable(head(long_data))
```



| Participant|Loudness |Time      |Letter | DV|
|-----------:|:--------|:---------|:------|--:|
|           1|Noisy    |Morning   |A      | 61|
|           1|Noisy    |Morning   |B      | 77|
|           1|Noisy    |Afternoon |A      | 97|
|           1|Noisy    |Afternoon |B      | 97|
|           1|Noisy    |Evening   |A      | 89|
|           1|Noisy    |Evening   |B      | 94|

## other solutions


```r
# create IVs by hand
Loudness <- rep( rep(c("Noisy","Quiet"),each=6), 10)
Time     <- rep( rep(rep(c("Morning","Afternoon","Evening"),each=2),2), 10)
Letter   <- rep( rep(c("A","B"),6), 10)
Participant <- rep(1:10, each = 12)

#load rectangle containing data
wide_data <- read_xlsx("data/Lab1_data.xlsx",
                          range = "B4:M13", 
                          col_names=FALSE)
#> New names:
#> • `` -> `...1`
#> • `` -> `...2`
#> • `` -> `...3`
#> • `` -> `...4`
#> • `` -> `...5`
#> • `` -> `...6`
#> • `` -> `...7`
#> • `` -> `...8`
#> • `` -> `...9`
#> • `` -> `...10`
#> • `` -> `...11`
#> • `` -> `...12`

# convert matrix to a single vector (concatenate)
long_dv <- c(t(as.matrix(wide_data)))

#assemble data.frame

long_data <- data.frame(Participant,
                        Loudness,
                        Time, 
                        Letter,
                        DV=long_dv)

head(long_data)
#>   Participant Loudness      Time Letter DV
#> 1           1    Noisy   Morning      A 61
#> 2           1    Noisy   Morning      B 77
#> 3           1    Noisy Afternoon      A 97
#> 4           1    Noisy Afternoon      B 97
#> 5           1    Noisy   Evening      A 89
#> 6           1    Noisy   Evening      B 94
```

Using loops and logic, and a minimum of other functions


```r
# load data

wide_data <- read_xlsx("data/Lab1_data.xlsx",col_names = FALSE)
#> New names:
#> • `` -> `...1`
#> • `` -> `...2`
#> • `` -> `...3`
#> • `` -> `...4`
#> • `` -> `...5`
#> • `` -> `...6`
#> • `` -> `...7`
#> • `` -> `...8`
#> • `` -> `...9`
#> • `` -> `...10`
#> • `` -> `...11`
#> • `` -> `...12`
#> • `` -> `...13`
wide_data <- as.data.frame(wide_data)

# Create vectors of level names for each IV
# use a for loop to process the first three rows of wide_data

Loudness <- c()
Time <- c()
Letter <- c()
for (i in 2:13) {
  
  if ( is.na(wide_data[1,i]) == FALSE ) Loudness[i-1] <- wide_data[1,i]
  if ( is.na(wide_data[1,i]) == TRUE ) Loudness[i-1] <- Loudness[i-2]
  
  if ( is.na(wide_data[2,i]) == FALSE ) Time[i-1] <- wide_data[2,i]
  if ( is.na(wide_data[2,i]) == TRUE ) Time[i-1] <- Time[i-2]
  
  if ( is.na(wide_data[3,i]) == FALSE ) Letter[i-1] <- wide_data[3,i]
  if ( is.na(wide_data[3,i]) == TRUE ) Letter[i-1] <- Letter[i-2]
}

# Create a long data frame using a for loop

long_data <-  data.frame()

for(i in 4:13){ # rows
  for(j in 2:13) { # columns
    temp_row <- data.frame(Participant = wide_data[i,1],
                           Loudness = Loudness[j-1],
                           Time = Time[j-1],
                           Letter = Letter[j-1],
                           DV = wide_data[i,j])
    long_data <- rbind(long_data,temp_row)
  }
}

head(long_data)
#>   Participant Loudness      Time Letter DV
#> 1           1    Noisy   Morning      A 61
#> 2           1    Noisy   Morning      B 77
#> 3           1    Noisy Afternoon      A 97
#> 4           1    Noisy Afternoon      B 97
#> 5           1    Noisy   Evening      A 89
#> 6           1    Noisy   Evening      B 94
```
Using the `zoo:na.locf` function to fill level names to the right. This uses only a few lines, but it comes at the expense of low readability, and lots of nested function calls that are hard to parse and understand.


```r
wide_data <- as.data.frame(read_xlsx("data/Lab1_data.xlsx",col_names = FALSE))
#> New names:
#> • `` -> `...1`
#> • `` -> `...2`
#> • `` -> `...3`
#> • `` -> `...4`
#> • `` -> `...5`
#> • `` -> `...6`
#> • `` -> `...7`
#> • `` -> `...8`
#> • `` -> `...9`
#> • `` -> `...10`
#> • `` -> `...11`
#> • `` -> `...12`
#> • `` -> `...13`
the_scores <- wide_data[4:13,1:13]
names(the_scores) <- c(wide_data[3,1],apply(zoo::na.locf(t(wide_data[1:3,2:13])),1,paste, collapse="_"))

long_data <- the_scores %>% pivot_longer(
  cols = 2:13,
  names_to = c("Loudness","Time","Letter"),
  names_pattern = "(.*)_(.*)_(.*)",
  values_to = "DV"
)

head(long_data)
#> # A tibble: 6 × 5
#>   Participant Loudness Time      Letter DV   
#>   <chr>       <chr>    <chr>     <chr>  <chr>
#> 1 1           Noisy    Morning   A      61   
#> 2 1           Noisy    Morning   B      77   
#> 3 1           Noisy    Afternoon A      97   
#> 4 1           Noisy    Afternoon B      97   
#> 5 1           Noisy    Evening   A      89   
#> 6 1           Noisy    Evening   B      94
```

