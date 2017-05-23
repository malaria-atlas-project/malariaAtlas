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

    ##   month_start year_start month_end year_end lower_age upper_age examined
    ## 1           9       1976         9     1976         0        15      100
    ## 2           9       2008         9     2008         5        15      109
    ## 3           1       1985         1     1985         5        17       80
    ## 4          11       2009        11     2009         5        17      110
    ## 5           9       1976         9     1976         0        15      100
    ## 6           3       1979         3     1979         0        14      315

    ##   pf_pr pf_positive     method              rdt_type pcr_type site_id
    ## 1    NA           0 Microscopy                             NA     817
    ## 2    NA           0        RDT            OptiMAL-IT       NA    5467
    ## 3    NA          29 Microscopy                             NA   21595
    ## 4    NA           0        RDT Paracheck Pf (Device)       NA    4554
    ## 5    NA           2 Microscopy                             NA   13493
    ## 6    NA         172 Microscopy                             NA    7716

    ##   latitude longitude                      name country_id rural_urban
    ## 1 -3.17500  40.10960               Kisima Farm        KEN       rural
    ## 2 -3.53947  39.45463    Mnagoni Primary School        KEN            
    ## 3  0.05522  34.27706      Awelo Primary School        KEN       urban
    ## 4 -0.69375  37.06622 Gatunduini Primary School        KEN       rural
    ## 5 -3.20850  40.06990                  Maziwani        KEN       rural
    ## 6 -3.22054  40.00088                  Kakuyuni        KEN       rural

    ##   country continent_id who_region_id
    ## 1   Kenya       Africa          AFRO
    ## 2   Kenya       Africa          AFRO
    ## 3   Kenya       Africa          AFRO
    ## 4   Kenya       Africa          AFRO
    ## 5   Kenya       Africa          AFRO
    ## 6   Kenya       Africa          AFRO

    ##                                                                                                                                                                                                              citation1
    ## 1                                                                                              DVBD. (1976). Monthly report September 1976. Nairobi, Kenya: Division of Vector-Borne Diseases, Ministry of Health 4pg.
    ## 2 Gitonga, CW, Karanja, PN, Kihara, J, Mwanje, M, Juma, E, Snow, RW, Noor, AM and Brooker, S. (2010).  Implementing school malaria surveys in Kenya: towards a national surveillance system. Malaria Journal, 9(0):306
    ## 3                                                                                            DVBD. (1985). Monthly report for January 1985. Nairobi, Kenya: Division of Vector-Borne Diseases, Ministry of Health 2pg.
    ## 4                                                                                                   Snow, RW, Noor, A and Gitonga, C. Nairobi, KEMRI-Wellcome Trust Research Programme, (2009) personal communication.
    ## 5                                                                                              DVBD. (1976). Monthly report September 1976. Nairobi, Kenya: Division of Vector-Borne Diseases, Ministry of Health 4pg.
    ## 6                                                                                                                                 DVBD. (1979). Nairobi, Kenya: Division of Vector-Borne Diseases, Ministry of Health.
    ##                                                                                                                                                                                                              citation2
    ## 1                                                                                                                                                                                                                     
    ## 2                                                                                                                                                                                                                     
    ## 3                                                                                                                                                                                                                     
    ## 4 Gitonga, CW, Karanja, PN, Kihara, J, Mwanje, M, Juma, E, Snow, RW, Noor, AM and Brooker, S. (2010).  Implementing school malaria surveys in Kenya: towards a national surveillance system. Malaria Journal, 9(0):306
    ## 5                                                                                                                                                                                                                     
    ## 6                                                                                                                                                                                                                     
    ##   citation3
    ## 1          
    ## 2          
    ## 3          
    ## 4          
    ## 5          
    ## 6
