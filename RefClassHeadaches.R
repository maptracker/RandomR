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
