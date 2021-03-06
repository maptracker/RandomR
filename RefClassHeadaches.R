## Quickly source this code:
## source("https://github.com/maptracker/RandomR/raw/master/RefClassHeadaches.R")

## The objects below have just two functions, one of which calls the
## other. The challenge is understanding the conditions needed for the
## called function to be "visible" to the calling one.

## If the object is not set up properly, the calling function can not
## find it, and the following message will be thrown:
## could not find function "mult3"

## When a class is working, it will print:
## Class <nameOfClass> | in 7 | out 21

## Thanks to John Chambers (ReferenceClass author) for helping out with this!

## Global functions to make the code a bit more readable:
globalMult3 <- function (x) x * 3
globalPrint <- function (x) message(sprintf("  Class %s | in %s | out %s",
                                            class(.self), x, mult3(x)))
## A try() block to aid in evaluation and reporting of each class
tryClass    <- function (cName) {
    outcome <- "Failure"
    try({
        message(sprintf("%s\n%s : %s (class=%s)", hr, Res, desc, cName))
        tmp <- new(cName)    # Make a new cName object
        tmp$printMult3( 7 )  # Try out the printMult3 method
        outcome <- "Success" # Will only evaluate if no errors above
    })
    message("  ", outcome)
}

message("\n\n\n")
hr <- paste(rep("- ", 30), collapse = "") # Separator text

## Different scenarios follow:
## Res   <- execution result
## desc  <- brief description of the test
## cName <- class name, as string

## ----------------------------
Res   <- "Success"
desc  <- "Define both methods in a single call to setRefClass()"
cName <- "singleDefinition"
singleDefinition <-
    setRefClass(cName, methods = list(printMult3 = globalPrint,
                                      mult3      = globalMult3 ))
tryClass("singleDefinition")

## ----------------------------
Res   <- "Success"
desc  <- "Define both methods in a single object call to $methods()"
cName <- "singleMethodsCall"
singleMethodsCall <- setRefClass(cName)
singleMethodsCall$methods(
    printMult3 = globalPrint,
    mult3      = globalMult3 
)
tryClass("singleMethodsCall")

## ----------------------------
Res   <- "Success"
desc  <- "Define each method in its own $methods() call, mult3 first"
cName <- "twoMethodsMultFirst"
twoMethodsMultFirst <- setRefClass(cName)
twoMethodsMultFirst$methods( mult3      = globalMult3 )
twoMethodsMultFirst$methods( printMult3 = globalPrint )
tryClass("twoMethodsMultFirst")

## ----------------------------
Res   <- "Failure"
desc  <- "Define each method in its own $methods() call, printMult3 first"
cName <- "twoMethodsPrintFirst"
twoMethodsPrintFirst <- setRefClass(cName)
twoMethodsPrintFirst$methods( printMult3 = globalPrint )
twoMethodsPrintFirst$methods( mult3      = globalMult3 )
tryClass("twoMethodsPrintFirst")

## ----------------------------
Res   <- "Success"
desc  <- "A call to .self$mult3() seems to always work"
cName <- "callWithSelf"
callWithSelf <- setRefClass(cName)
callWithSelf$methods( printMult3 = function(x) {
    message(sprintf("  Class %s | in %s | out %s",
                    class(.self), x, .self$mult3(x)))
})
callWithSelf$methods( mult3      = globalMult3 )
tryClass("callWithSelf")

## ----------------------------
Res   <- "Success"
desc  <- "If '.self$mult3' is called inside printMult3, it can then be found"
cName <- "tickledPrintFirst"
tickledPrintFirst <- setRefClass(cName)
tickledPrintFirst$methods( printMult3 = function(x) {
    .self$mult3 # Not called! just "looked at"
    message(sprintf("  Class %s | in %s | out %s",
                    class(.self), x, mult3(x)))
})
tickledPrintFirst$methods( mult3      = globalMult3 )
tryClass("tickledPrintFirst")

## ----------------------------
Res   <- "Failure"
desc  <- "$usingMethods() 'alerts' one method to another, but does not seem to work in this context"
cName <- "withUsingMethods"
withUsingMethods <- setRefClass(cName)
withUsingMethods$methods( printMult3 = function(x) {
    usingMethods("mult3")
    message(sprintf("  Class %s | in %s | out %s",
                    class(.self), x, mult3(x)))
})
withUsingMethods$methods( mult3      = globalMult3 )
tryClass("withUsingMethods")

## ----------------------------
if (require("data.table")) {
    message("\n\n## Interaction of RefClass with data.table\n\n")
    ## data.table is itself a reference-based package, with objects
    ## being handled by reference rather than lexically. I have
    ## encountered some problems trying to use data.table objects in
    ## RefClass fields. In particular, the copy() method does not seem
    ## to generate a 'clean' break between the original object and the
    ## copy. My guess is that behind-the-scenes C data structures
    ## aren't recognizing each other between the RefClass/data.table
    ## packages.

    ## This use case may be stretching the pass-by-reference paradigm
    ## too far for lexically-minded R?

    message("## All of the code below should work fine, up until the last few lines...\n\n")
    
    message("## Generating a 'stand-alone' data.table, copying it, adding column")
    simpleDT   <- data.table(x=1:3, y=letters[4:6]) # 3x2 DT
    simpleCopy <- copy(simpleDT)
    simpleCopy[ , z := 7:9 ] # Add a third column by reference
    print(simpleCopy)

    ## http://www.cyclismo.org/tutorial/R/s3Classes.html
    message("## As above, but for a data.table held by an S3 object")
    s3dt <- function( dt ) {
        sEnv <- environment()
        DT   <- dt
        self <- list(table = function() { get("DT",sEnv) },
                     copy  = function() { copy(get("DT", sEnv) ) } )
        class(self) <- append(class(self), 's3dt')
        self
    }
    s3DT <- s3dt( data.table(x=1:3, y=letters[4:6]) )
    s3Copy <- s3DT$copy()
    s3Copy[ , z := 7:9 ] # Add a third column by reference
    print(s3Copy)

    message("## Listing the data.tables currently in the environment:")
    tables()
    
    message("## Generating a DT stored in a RefClass field")
     cName <- "unhappyDataTable"
    unhappyDataTable <- setRefClass(cName, fields = list( DT = 'data.table' ))
    unhappyDataTable$methods( copydt = function() { copy( DT ) } )
    udt <- new(cName)
    udt$DT <- data.table(x=1:3, y=letters[4:6]) # Same table as above

    message("\n\n## Strangeness starts here - Generating and printing a copy of the DT")
    message("## The copy appears to still be associated as a field of the RefClass object")
    message("## It ('refClassCopy') is also not visible in the tables() call for this environment - perhaps this is expected? But the S3 copy was ...")
    refClassCopy <- udt$copy()
    print(refClassCopy)
    tables()
    message("## Attempt to add a new column to the refClassCopy fails with odd class-check error:")
    refClassCopy[ , z := 7:9 ]
}
