MAPdata
=======

A package that enables users to download publicly available Parasite
Rate Data from the Malaria Atlas Project geoserver.

Overview
--------

### listAll

The listAll function retrieves a list of countries for which Parasite
Rate data is available to download.

    MAPdata::listAll()

    ## Creating list of countries for which PR data is available, please wait...

    ## [1] "Countries with PR Data:"
    ## Afghanistan 
    ##  Angola 
    ##  Bangladesh 
    ##  Benin 
    ##  Bhutan 
    ##  Bolivia 
    ##  Botswana 
    ##  Brazil 
    ##  Burkina Faso 
    ##  Burundi 
    ##  CÃ´te d'Ivoire 
    ##  Cambodia 
    ##  Cameroon 
    ##  Cape Verde 
    ##  Central African Republic 
    ##  Chad 
    ##  China 
    ##  Colombia 
    ##  Comoros 
    ##  Congo 
    ##  Costa Rica 
    ##  Democratic Republic of the Congo 
    ##  Djibouti 
    ##  Ecuador 
    ##  Equatorial Guinea 
    ##  Eritrea 
    ##  Ethiopia 
    ##  French Guiana 
    ##  Gabon 
    ##  Ghana 
    ##  Guatemala 
    ##  Guinea 
    ##  Guinea-Bissau 
    ##  Haiti 
    ##  Honduras 
    ##  India 
    ##  Indonesia 
    ##  Iraq 
    ##  Kenya 
    ##  Lao People's Democratic Republic 
    ##  Liberia 
    ##  Madagascar 
    ##  Malawi 
    ##  Malaysia 
    ##  Mali 
    ##  Mauritania 
    ##  Mayotte 
    ##  Mexico 
    ##  Morocco 
    ##  Mozambique 
    ##  Myanmar 
    ##  Namibia 
    ##  Nepal 
    ##  Nicaragua 
    ##  Niger 
    ##  Nigeria 
    ##  Pakistan 
    ##  Papua New Guinea 
    ##  Peru 
    ##  Philippines 
    ##  Rwanda 
    ##  SÃ£o TomÃ© and PrÃ­ncipe 
    ##  Saudi Arabia 
    ##  Senegal 
    ##  Sierra Leone 
    ##  Solomon Islands 
    ##  Somalia 
    ##  South Africa 
    ##  South Sudan 
    ##  Sri Lanka 
    ##  Sudan 
    ##  Suriname 
    ##  Swaziland 
    ##  Tajikistan 
    ##  Tanzania (United Republic of) 
    ##  Thailand 
    ##  The Gambia 
    ##  Timor-Leste 
    ##  Togo 
    ##  Turkey 
    ##  Uganda 
    ##  Vanuatu 
    ##  Venezuela 
    ##  Viet Nam 
    ##  Yemen 
    ##  Zambia 
    ##  Zimbabwe

    ## NULL

### getPR

`getPR` downloads all publicly available PR data points for a specified
country and plasmodium species (Pf, Pv or BOTH) and returns this as a
dataframe with the following format:

    pr_data <- MAPdata::getPR(country = "Kenya", species = "Pf")

    ## Confirming availability of PR data for: Kenya...

    ## Importing PR point data for Kenya ...

    head(pr_data)

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
