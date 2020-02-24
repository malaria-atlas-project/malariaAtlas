## Changes

The Malaria Atlas Project server is moving. We have updated the package
to reflect this. The old domain will still work for a fair while though.

## Test environments

Local Ubuntu 18.04 Stable R 3.6.2 (2019-12-12)
Local Ubuntu 18.04 Stable 3.6.2 (2019-12-12) (with internet disconnected)

Travis Ubuntu 16.04 Stable R version 3.6.2 (2017-01-27)
Travis Ubuntu 16.04 Devel (unstable) (2020-02-24 r77850)
Travis Ubuntu 16.04 Stable R version 3.6.2 (2017-01-27) with env: NOT_CRAN=true

Winbuilder Stable R version 3.6.1 (2019-07-05)
Winbuilder Devel R (unstable) (2019-11-25 r77460)


## R CMD check results

No warnings, no errors.

I get one note when running check locally with the internet disconnected.
> checking for future file timestamps ... NOTE
  unable to verify current time

This seems to be as expected.


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



