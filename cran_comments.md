## Test environments

Local Ubuntu 16.04 Stable R version 3.4.4 (2018-03-15)
Travis Ubuntu 14.04 Stable R version 3.5.0 (2017-01-27)
Travis Ubuntu 14.04 Devel R (2018-09-10 r75281)
Winbuilder R version 3.5.0 beta (2018-04-08 r74552)
Winbuilder R version Devel (2018-09-10 r75281)


## R CMD check results

No warnings, no errors, no notes.

We do however have some long running examples.

Examples with CPU or elapsed time > 5s
                         user system elapsed
getRaster              69.853  0.955  72.566
as.MAPraster           26.251  2.994  34.519
autoplot.MAPraster     20.658  0.968  22.081
autoplot_MAPraster     20.401  0.980  21.646
autoplot.vector.points 16.908  0.081  17.801
getPR                   8.489  0.439  11.516
autoplot.pr.points      4.847  0.044   5.364

On our previous submission we were instructed to enclose these in `\donttest` rather than `\dontrun`. This is what we still have.


