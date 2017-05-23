MAPdata
=======

A package that enables users to download publicly available Parasite
Rate Data from the Malaria Atlas Project geoserver.

Overview
--------

### PR Data Source

*blurb re what the data is and where it comes from*

### listAll

`listAll()` retrieves a list of countries for which Parasite Rate data
is available to download.

    available_countries <- MAPdata::listAll()

    print(available_countries)

    ##  [1] "Afghanistan"                      "Angola"                          
    ##  [3] "Bangladesh"                       "Benin"                           
    ##  [5] "Bhutan"                           "Bolivia"                         
    ##  [7] "Botswana"                         "Brazil"                          
    ##  [9] "Burkina Faso"                     "Burundi"                         
    ## [11] "Cambodia"                         "Cameroon"                        
    ## [13] "Cape Verde"                       "Central African Republic"        
    ## [15] "Chad"                             "China"                           
    ## [17] "Colombia"                         "Comoros"                         
    ## [19] "Congo"                            "Costa Rica"                      
    ## [21] "Côte d'Ivoire"                    "Democratic Republic of the Congo"
    ## [23] "Djibouti"                         "Ecuador"                         
    ## [25] "Equatorial Guinea"                "Eritrea"                         
    ## [27] "Ethiopia"                         "French Guiana"                   
    ## [29] "Gabon"                            "Ghana"                           
    ## [31] "Guatemala"                        "Guinea"                          
    ## [33] "Guinea-Bissau"                    "Haiti"                           
    ## [35] "Honduras"                         "India"                           
    ## [37] "Indonesia"                        "Iraq"                            
    ## [39] "Kenya"                            "Lao People's Democratic Republic"
    ## [41] "Liberia"                          "Madagascar"                      
    ## [43] "Malawi"                           "Malaysia"                        
    ## [45] "Mali"                             "Mauritania"                      
    ## [47] "Mayotte"                          "Mexico"                          
    ## [49] "Morocco"                          "Mozambique"                      
    ## [51] "Myanmar"                          "Namibia"                         
    ## [53] "Nepal"                            "Nicaragua"                       
    ## [55] "Niger"                            "Nigeria"                         
    ## [57] "Pakistan"                         "Papua New Guinea"                
    ## [59] "Peru"                             "Philippines"                     
    ## [61] "Rwanda"                           "São Tomé and Príncipe"           
    ## [63] "Saudi Arabia"                     "Senegal"                         
    ## [65] "Sierra Leone"                     "Solomon Islands"                 
    ## [67] "Somalia"                          "South Africa"                    
    ## [69] "South Sudan"                      "Sri Lanka"                       
    ## [71] "Sudan"                            "Suriname"                        
    ## [73] "Swaziland"                        "Tajikistan"                      
    ## [75] "Tanzania (United Republic of)"    "Thailand"                        
    ## [77] "The Gambia"                       "Timor-Leste"                     
    ## [79] "Togo"                             "Turkey"                          
    ## [81] "Uganda"                           "Vanuatu"                         
    ## [83] "Venezuela"                        "Viet Nam"                        
    ## [85] "Yemen"                            "Zambia"                          
    ## [87] "Zimbabwe"

### getPR

`getPR()` downloads all publicly available PR data points for a
specified country and plasmodium species (Pf, Pv or BOTH) and returns
this as a dataframe with the following format:

    pr_data <- MAPdata::getPR(country = "Kenya", species = "Pf")
    str(pr_data)

    ## 'data.frame':    4073 obs. of  24 variables:
    ##  $ month_start  : int  9 9 1 11 9 3 11 9 2 9 ...
    ##  $ year_start   : int  1976 2008 1985 2009 1976 1979 1979 1981 2006 2008 ...
    ##  $ month_end    : int  9 9 1 11 9 3 11 9 2 9 ...
    ##  $ year_end     : int  1976 2008 1985 2009 1976 1979 1979 1981 2006 2008 ...
    ##  $ lower_age    : num  0 5 5 5 0 0 0 0 6 5 ...
    ##  $ upper_age    : int  15 15 17 17 15 14 14 15 8 15 ...
    ##  $ examined     : int  100 109 80 110 100 315 276 100 100 106 ...
    ##  $ pf_pr        : num  NA NA NA NA NA NA NA NA NA NA ...
    ##  $ pf_positive  : num  0 0 29 0 2 172 93 9 1 0 ...
    ##  $ method       : Factor w/ 4 levels "Microscopy","PCR",..: 1 3 1 3 1 1 1 1 1 3 ...
    ##  $ rdt_type     : Factor w/ 11 levels "","ICT","ICT diagnostics",..: 1 7 1 9 1 1 1 1 1 7 ...
    ##  $ pcr_type     : logi  NA NA NA NA NA NA ...
    ##  $ site_id      : int  817 5467 21595 4554 13493 7716 5413 7444 20970 11101 ...
    ##  $ latitude     : num  -3.175 -3.5395 0.0552 -0.6937 -3.2085 ...
    ##  $ longitude    : num  40.1 39.5 34.3 37.1 40.1 ...
    ##  $ name         : Factor w/ 2790 levels "Abakore Primary School",..: 1326 1819 60 468 1722 698 2390 1714 2389 1241 ...
    ##  $ country_id   : Factor w/ 1 level "KEN": 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ rural_urban  : Factor w/ 5 levels "","Peri-urban",..: 3 1 5 3 3 3 3 3 1 5 ...
    ##  $ country      : Factor w/ 1 level "Kenya": 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ continent_id : Factor w/ 1 level "Africa": 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ who_region_id: Factor w/ 1 level "AFRO": 1 1 1 1 1 1 1 1 1 1 ...
    ##  $ citation1    : Factor w/ 476 levels " (2015). Kenya Malaria Indicator Survey 2015 . DHS Survey ID 493. Nairobi: National Malaria Control Programme / Ministry of Hea"| __truncated__,..: 45 342 195 457 45 70 70 93 357 342 ...
    ##  $ citation2    : Factor w/ 25 levels "","(2010). http://mara-database.org/mara/.: MARA/ARMA. 31 Aug 2010.",..: 1 1 1 10 1 1 1 1 1 1 ...
    ##  $ citation3    : Factor w/ 2 levels "","Le Sueur, D., Binka, F., Lengeler, C., De Savigny, D., Snow, B., Teuscher, T. and Toure, Y. (1997).  An atlas of malaria in Afr"| __truncated__: 1 1 1 1 1 1 1 1 1 1 ...
