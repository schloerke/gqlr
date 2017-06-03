
## Comments

### 2017-6-3

New package: gqlr.

Please let me know if there is anything I can do.  Thank you for your time.

Best,
Barret


## R CMD check results

* local OS X install
  * R version 3.4.0 (2017-04-21)
    Platform: x86_64-apple-darwin15.6.0 (64-bit)
    Running under: macOS Sierra 10.12.4
    * 0 errors | 0 warnings | 1 note
      * checking installed package size ... NOTE
        installed size is  5.5Mb
        sub-directories of 1Mb or more:
          R   5.4Mb

* travis-ci
  * R version 3.4.0 (2017-04-21)
    Platform: x86_64-pc-linux-gnu (64-bit)
    Running under: Ubuntu precise (12.04.5 LTS)
    * 0 errors | 0 warnings | 1 notes
      * checking installed package size ... NOTE
        installed size is  8.1Mb
        sub-directories of 1Mb or more:
          R   8.0Mb

* win-builder (devel and release)
  * R version 3.4.0 (2017-04-21)
  * R Under development (unstable) (2017-06-01 r72753)

    * 0 errors | 0 warnings | 2 notes
      * checking CRAN incoming feasibility ... NOTE
        Maintainer: 'Barret Schloerke <schloerke@gmail.com>'

        New submission

        Possibly mis-spelled words in DESCRIPTION:
          GraphQL (2:8, 9:32)
      * checking installed package size ... NOTE
        installed size is  5.4Mb
        sub-directories of 1Mb or more:
          R   5.4Mb

    * Rebuttle to NOTEs
      * GraphQL is spelled correctly
      * The code is small, but it is comprised of many R6 objects. This could easily be why the code is larger than what is in the raw code.




## Reverse dependencies

This is a new release, so there are no reverse dependencies.
