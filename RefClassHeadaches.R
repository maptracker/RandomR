hr <- paste(rep("- ", 20), collapse = "")
hr <- paste("\n", hr)

message(hr)
message("Trying to comprehend object methods in Reference Class objects")
message(hr)

bar <- setRefClass("bar",fields = list( x = "integer"))
## This will not work
bar$methods(
    initialize = function(..., x = 12L) {
        ## We have the "right" class here:
        message(.self$show())
        message("About to have an error")
        levelOne("Inside Init")
        message("  I never get here!")
        callSuper(..., x = x )
    })
## Shouldn't the method below "be available" to the object?
bar$methods( levelOne = function ( msg = "Hi") {
                message("bar$levelOne() sez: ",msg) })
try ({
    if (exists("b")) rm(b)
    b <- bar()
    message("Object was not created, we will never get here")
    b$levelOne("My L1 bar Message")
})


message(hr)
bip <- setRefClass("bip",fields = list( x = "integer"))
## It does not help to callSuper() first
bip$methods(
    initialize = function(..., x = 12L) {
        ## If we callSuper() first, the $x field gets properly set,
        ## but we still do not have any knowledge of the $levelOne()
        ## method
        callSuper(..., x = x )
        message(.self$show())
        message("About to have an error")
        levelOne("Inside Init")
        message("  I never get here!")
    })
## Shouldn't the method below "be available" to the object?
bip$methods( levelOne = function ( msg = "Hi") {
                message("bip$levelOne() sez: ",msg) })
try ({
    if (exists("bp")) rm(bp)
    bp <- bip()
    message("Object was not created, we will never get here")
    bp$levelOne("My L1 bip Message")
})


message(hr)
bipk <- setRefClass("bipk",fields = list( x = "integer"))
## Define levelOne() "before" initialize(), which makes everything
## happy. The only change from the "bip" objects is that levelOne() is
## a few lines higher in the source code.
bipk$methods( levelOne = function ( msg = "Hi") {
                message("bipk$levelOne() sez: ",msg) })
bipk$methods(
    initialize = function(..., x = 12L) {
        message("For some reason defining the *object* method 'earlier' works!")
        levelOne("Inside Init")
        message("  Success!")
        callSuper(..., x = x )
    })
try({
    if (exists("bk")) rm(bk)
    bk <- bipk()
    bk$levelOne("My L1 bipk Message")
})

message(hr)
## Defining the methods in a monolithic (and ugly) block works ok
bork <- setRefClass("bork",
  fields = list( x = "integer"),
  methods = list(initialize = function(..., x = 12L) {
                     message("Setting methods in setRefClass() works")
                     levelOne("Inside Init")
                     message("  Success!")
                     callSuper(..., x = x )
                 }, levelOne = function ( msg = "Hi") {
                     message("bork$levelOne() sez: ",msg) })
    )

try({
    if (exists("bo")) rm(bo)
    bo <- bork()
    bo$levelOne("My L1 bork Message")
})

message(hr)
baz <- setRefClass("baz",fields = list( x = "integer"))
## Directly referencing .self$levelOne() works
baz$methods(
    initialize = function(..., x = 12L) {
        message("Explicit reference to '.self' is also ok")
        .self$levelOne("Inside Init")
        message("  Success!")
        callSuper(..., x = x )
    })
baz$methods( levelOne = function ( msg = "Hi") {
                message("baz$levelOne() sez: ",msg) })
try({
    if (exists("bz")) rm(bz)
    bz <- baz()
    bz$levelOne("My L1 baz Message")
})

message(hr)
jaz <- setRefClass("jaz",fields = list( x = "integer"))
## "Peeking at .self$levelOne (with no "()"!!) somehow "preloads" the
## method, which somehow allows it to then be called without .self
## ??!?
jaz$methods(
    initialize = function(..., x = 12L) {
        message("Just *checking* the method allows it to be called w/o .self")
        chk <- .self$levelOne   # Not actually "doing" anything, "just looking"
        levelOne("Inside Init") # WHY DOES THIS NOW WORK??
        message("  Success!")
        callSuper(..., x = x )
    })
jaz$methods( levelOne = function ( msg = "Hi") {
                message("jaz$levelOne() sez: ",msg) })
try({
    if (exists("jz")) rm(jz)
    jz <- jaz()
    jz$levelOne("My L1 jaz Message")
})



## Trying (and failing) to replicate issues happening outside of
## initialize(). In a (much) more complex object, this paradigm is not
## working at all (ie zz$levelTwo() is failing because $levelOne
## appears to be suffering from the "apparently not yet defined"
## problems reflected in the examples above)...

message(hr)
zaz <- setRefClass("zaz",fields = list( x = "integer"))
zaz$methods( levelTwo = function ( msg = "Bye") {
                levelOne(paste("From levelTwo:", msg)) })
zaz$methods( levelOne = function ( msg = "Hi") {
                message("zaz$levelOne() sez: ",msg) })
try({
    if (exists("zz")) rm(zz)
    zz <- zaz()
    zz$levelOne("My L1 zaz Message")
    zz$levelTwo("My L2 zaz Message")
})

message(hr)
