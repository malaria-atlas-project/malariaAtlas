## Changes

The package downloads data from a server. I was asked to make the package behave better when the server was unavailable.

* I have made all functions return error information as a message and return value, rather than actually erroring.
* I have made the vignette be able to not error if the server is down.
* The checks should not error if the server is down.
* I have tested this locally by running check with my internet disconnected.


## Test environments

Local Ubuntu 16.04 Stable R version 3.6.1 (2019-07-05)
Local Ubuntu 16.04 Stable R version 3.6.1 (2019-07-05) (with internet disconnected)

Travis Ubuntu 16.04 Stable R version 3.6.1 (2019-07-05)
Travis Ubuntu 16.04 Devel R (unstable) (2019-11-25 r77460)
Travis Ubuntu 16.04 Stable R version 3.6.1 (2019-07-05) with env: NOT_CRAN=true

Winbuilder Stable R version 3.6.1 (2019-07-05)
Winbuilder Devel R (unstable) (2019-11-25 r77460)


## R CMD check results

No warnings, no errors, no notes.


I have a number of examples that are slow:
   Examples with CPU or elapsed time > 5s
                            user system elapsed
   getRaster              56.926  1.404  61.087
   as.MAPraster           45.419  2.207  56.088
   autoplot_MAPraster     44.269  1.672  46.122
   autoplot.MAPraster     43.226  1.736  45.171
   autoplot.vector.points  6.783  0.056   7.568
   getPR                   3.546  0.380   5.436
   listData                0.059  0.000   5.605

On a previous release I was told to change all tests from dontrun to donttest. I am happy to switch them back if that is preferred.



