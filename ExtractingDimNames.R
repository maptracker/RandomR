## Confirming that pulling dimnames out of an array is not slowed by
## the number of row/col names also present

## Run from source:
## source("https://github.com/maptracker/RandomR/raw/master/ExtractingDimNames.R")$value

library("microbenchmark")

getDimNames <- function(x) names(dimnames(x))

smallMatrix <- matrix(1:10, dimnames = list(RowHeader = rep("small", 10),
                                            ColHeader = c("Things")))
bigMatrix   <- matrix(1:1e6, dimnames = list(RowHeader = rep("big", 1e6),
                                             ColHeader = c("Things")))

microbenchmark(small = getDimNames(smallMatrix),
               big   = getDimNames(bigMatrix), times = 1e3)
## Effectively identical timings, on the order of a microsecond
