
## Comments

### 2019-12-02

This submission is to reinstate `gqlr` on CRAN by addressing:
* the removal of `jug`
* removal of a test for an R bug that has beed addressed by R-core

This submission also removes the large compiled file and longer build checks on some systems.

(As of 2019-11-27, there is no DOI for 'GraphQL': https://github.com/graphql/graphql-spec/issues/299 .)

Please let me know if there is anything else I can do!

Thank you,
Barret


### 2017-06-03

Or is there some reference about the method you can add in the
Description field in the form Authors (year) <doi:.....>?

Best,
Uwe Ligges


## R CMD check results

Most all system checks contained the NOTE below (which is expected given `gqlr` was archived):

* checking CRAN incoming feasibility
  Maintainer: 'Barret Schloerke <schloerke@gmail.com>'

  New submission

  Package was archived on CRAN

  CRAN repository db overrides:
     X-CRAN-Comment: Archived on 2019-11-29 as check errors were not
       corrected in time.


* local OS X install - 3.6.1
  - 1 NOTE (see above)

* r-hub
  * windows-x86_64-devel
    - 1 NOTE (see above)
  * ubuntu-gcc-release
    - 1 NOTE (see above)
  * fedora-clang-devel
    - OK (did not have internet access for `CRAN incoming checks`)

* travis-ci
  * oldrel, release, devel
    - OK

* win-builder
  * oldrel, release, devel
    - OK



## Reverse dependencies

There are no reverse dependencies.
