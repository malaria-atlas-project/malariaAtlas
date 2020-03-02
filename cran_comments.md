## Changes

The Malaria Atlas Project server is moving. We have updated the package
to reflect this. The old domain will still work for a fair while though.

## Test environments

Local Ubuntu 18.04 Stable R 3.6.2 (2019-12-12)
Local Ubuntu 18.04 Stable 3.6.2 (2019-12-12) (with internet disconnected)

Travis Ubuntu 16.04 Stable R version 3.6.2 (2017-01-27)
Travis Ubuntu 16.04 Devel (unstable) (2020-02-24 r77850)
Travis Ubuntu 16.04 Stable R version 3.6.2 (2017-01-27) with env: NOT_CRAN=true

Winbuilder Stable  R version 3.6.2 (2019-12-12)
Winbuilder R Under development (unstable) (2020-01-28 r77738)


## R CMD check results

No warnings, no errors.

I get one note when running check locally with the internet disconnected.
> checking for future file timestamps ... NOTE
  unable to verify current time

This seems to be as expected.




