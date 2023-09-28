---
output: 
  md_document:
    preserve_yaml: false
---

[![Build Status](https://travis-ci.org/malaria-atlas-project/malariaAtlas.svg)](https://travis-ci.org/malaria-atlas-project/malariaAtlas)
[![codecov.io](https://codecov.io/gh/malaria-atlas-project/malariaAtlas/coverage.svg?branch=master)](https://codecov.io/gh/malaria-atlas-project/malariaAtlas?branch=master)




# malariaAtlas 
### An R interface to open-access malaria data, hosted by the Malaria Atlas Project. 

*The gitlab version of the malariaAtlas package has some additional bugfixes over the stable CRAN package. If you have any issues, try installing the latest github version. See below for instructions.*

# Overview 

This package allows you to download parasite rate data (*Plasmodium falciparum* and *P. vivax*), survey occurrence data of the 41 dominant malaria vector species, and modelled raster outputs from the [Malaria Atlas Project](https://malariaatlas.org/).

More details and example analyses can be found in the [published paper)[(https://malariajournal.biomedcentral.com/articles/10.1186/s12936-018-2500-5).

## Available Data: 
The data can be explored at [https://data.malariaatlas.org/maps](https://data.malariaatlas.org/maps).



### List Versions Functions

The list version functions are used to list the available versions of different datasets, and all return a data.frame with a single column for version. These versions can be passed to functions such as `listShp`, `listSpecies`, `listPRPointCountries`, `listVecOccPointCountries`, `getPR`, `getVecOcc` and `getShp`.

Use: 

* `listPRPointVerions()` to see the available versions for PR point data, which can then be used in `listPRPointCountries` and `getPR`.

* `listVecOccPointVersions()` to see the available versions for vector occurrence data, which can then be used in `listSpecies`, `listVecOccPointCountries` and `getVecOcc`.

* `listShpVersions()` to see the available versions for admin unit shape data, which can then be used in `listShp` and `getShp`.


```r
listPRPointVerions()
```

```
## Error in listPRPointVerions(): could not find function "listPRPointVerions"
```


```r
listVecOccPointVersions()
```

```
## Versions available for vector occurrence point data: 
##  201201
```


```r
listShpVersions()
```

```
##   version
## 1  202206
```

### List Countries and Species Functions

To list the countries where there is available data for PR points or vector occurrence points, use:

* `listPRPointCountries()` for PR points
* `listVecOccPointCountries()` for vector occurrence points

To list the species available for vector point data use `listSpecies()`

All three of these functions can optionally take a version parameter (which can be found with the list versions functions). If you choose not to provide a version, the most recent version of the relevant dataset will be selected by default. 


```r
listPRPointCountries(version = "202206")
```

```
## Creating list of countries for which MAP data is available, please wait...
```

```
## Versions available for PR point data: 
##  202206
```

```
## Countries with PR point data: 
##  Kenya (KEN) 
##  Afghanistan (AFG) 
##  Somalia (SOM) 
##  Indonesia (IDN) 
##  Zimbabwe (ZWE) 
##  Ethiopia (ETH) 
##  Burkina Faso (BFA) 
##  Madagascar (MDG) 
##  India (IND) 
##  Yemen (YEM) 
##  Tanzania (TZA) 
##  Cambodia (KHM) 
##  Malawi (MWI) 
##  Zambia (ZMB) 
##  Senegal (SEN) 
##  Uganda (UGA) 
##  Bangladesh (BGD) 
##  Central African Republic (CAF) 
##  Colombia (COL) 
##  Togo (TGO) 
##  Sudan (SDN) 
##  Vietnam (VNM) 
##  Mozambique (MOZ) 
##  Burundi (BDI) 
##  Papua New Guinea (PNG) 
##  Venezuela (VEN) 
##  Comoros (COM) 
##  Solomon Islands (SLB) 
##  Pakistan (PAK) 
##  Ghana (GHA) 
##  Guinea (GIN) 
##  Bolivia (BOL) 
##  Philippines (PHL) 
##  Gambia (GMB) 
##  Niger (NER) 
##  Nigeria (NGA) 
##  Eritrea (ERI) 
##  Guinea-Bissau (GNB) 
##  Côte d'Ivoire (CIV) 
##  Nepal (NPL) 
##  Thailand (THA) 
##  South Africa (ZAF) 
##  Djibouti (DJI) 
##  Democratic Republic of the Congo (COD) 
##  Namibia (NAM) 
##  Vanuatu (VUT) 
##  China (CHN) 
##  Tajikistan (TJK) 
##  Botswana (BWA) 
##  Swaziland (SWZ) 
##  Brazil (BRA) 
##  Congo (COG) 
##  Cameroon (CMR) 
##  Equatorial Guinea (GNQ) 
##  Suriname (SUR) 
##  Liberia (LBR) 
##  Haiti (HTI) 
##  Morocco (MAR) 
##  Myanmar (MMR) 
##  Mayotte (MYT) 
##  Benin (BEN) 
##  Cape Verde (CPV) 
##  Laos (LAO) 
##  Malaysia (MYS) 
##  Peru (PER) 
##  Mali (MLI) 
##  Gabon (GAB) 
##  Sri Lanka (LKA) 
##  French Guiana (GUF) 
##  Iraq (IRQ) 
##  Saudi Arabia (SAU) 
##  Honduras (HND) 
##  Sao Tome And Principe (STP) 
##  Turkey (TUR) 
##  Ecuador (ECU) 
##  South Sudan (SSD) 
##  Timor-Leste (TLS) 
##  Sierra Leone (SLE) 
##  Chad (TCD) 
##  Mauritania (MRT) 
##  Mexico (MEX) 
##  Costa Rica (CRI) 
##  Angola (AGO) 
##  Nicaragua (NIC) 
##  Rwanda (RWA) 
##  Bhutan (BTN)
```


```r
listVecOccPointCountries(version = "201201")
```

```
## Creating list of countries for which MAP vector occurrence point data is available, please wait...
```

```
## Versions available for vector occurrence point data: 
##  201201
```

```
## Countries with vector occurrence point data: 
##  Sudan (SSD) 
##  Benin (BEN) 
##  Philippines (PHL) 
##  Viet Nam (VNM) 
##  Thailand (THA) 
##  Malaysia (MYS) 
##  Sudan (SDN) 
##  Myanmar (MMR) 
##  Lao People's Democratic Republic (LAO) 
##  Spain (ESP) 
##  Comoros (COM) 
##  France (FRA) 
##  Indonesia (IDN) 
##  United Kingdom (GBR) 
##  Costa Rica (CRI) 
##  Nicaragua (NIC) 
##  Kenya (KEN) 
##  South Africa (ZAF) 
##  Tanzania (United Republic of) (TZA) 
##  Cambodia (KHM) 
##  Democratic Republic of the Congo (COD) 
##  Ethiopia (ETH) 
##  Cameroon (CMR) 
##  Guinea (GIN) 
##  Burkina Faso (BFA) 
##  Senegal (SEN) 
##  Uganda (UGA) 
##  Mozambique (MOZ) 
##  Mali (MLI) 
##  India (IND) 
##  Madagascar (MDG) 
##  Guinea-Bissau (GNB) 
##  China (CHN) 
##  Niger (NER) 
##  The Gambia (GMB) 
##  Brazil (BRA) 
##  Côte d'Ivoire (CIV) 
##  Venezuela (VEN) 
##  French Guiana (GUF) 
##  São Tomé and Príncipe (STP) 
##  Nigeria (NGA) 
##  Turkey (TUR) 
##  Eritrea (ERI) 
##  Sri Lanka (LKA) 
##  Pakistan (PAK) 
##  Bolivia (BOL) 
##  Peru (PER) 
##  Colombia (COL) 
##  Guatemala (GTM) 
##  Suriname (SUR) 
##  Burundi (BDI) 
##  Gabon (GAB) 
##  Sierra Leone (SLE) 
##  Timor-Leste (TLS) 
##  Ghana (GHA) 
##  Belize (BLZ) 
##  Azerbaijan (AZE) 
##  Iran (IRN) 
##  Saudi Arabia (SAU) 
##  Armenia (ARM) 
##  Zimbabwe (ZWE) 
##  Equatorial Guinea (GNQ) 
##  Angola (AGO) 
##  Netherlands (NLD) 
##  Egypt (EGY) 
##  Trinidad and Tobago (TTO) 
##  Malawi (MWI) 
##  Italy (ITA) 
##  Greece (GRC) 
##  Papua New Guinea (PNG) 
##  Liberia (LBR) 
##  Romania (ROU) 
##  Namibia (NAM) 
##  Mauritania (MRT) 
##  Belgium (BEL) 
##  Zambia (ZMB) 
##  Cuba (CUB) 
##  Mexico (MEX) 
##  El Salvador (SLV) 
##  United States of America (USA) 
##  Dominican Republic (DOM) 
##  Guyana (GUY) 
##  Grenada (GRD) 
##  Ecuador (ECU) 
##  Argentina (ARG) 
##  Swaziland (SWZ) 
##  Montenegro (MNE) 
##  Haiti (HTI) 
##  Honduras (HND) 
##  Vanuatu (VUT) 
##  Botswana (BWA) 
##  Korea, Republic of (KOR) 
##  Solomon Islands (SLB) 
##  Australia (AUS) 
##  Singapore (SGP) 
##  Nepal (NPL) 
##  Korea, Democratic People's Republic of (PRK) 
##  Japan (JPN) 
##  Bangladesh (BGD) 
##  Macau (MAC) 
##  Austria (AUT) 
##  Afghanistan (AFG) 
##  Réunion (REU) 
##  Yemen (YEM) 
##  Somalia (SOM) 
##  Jordan (JOR) 
##  Paraguay (PRY) 
##  Sweden (SWE) 
##  Congo (COG) 
##  Albania (ALB) 
##  Iraq (IRQ) 
##  Russian Federation (RUS) 
##  Central African Republic (CAF) 
##  Israel (ISR) 
##  Morocco (MAR) 
##  Tajikistan (TJK) 
##  Uzbekistan (UZB) 
##  Togo (TGO) 
##  United Arab Emirates (ARE) 
##  Panama (PAN) 
##  Chad (TCD) 
##  Macedonia, the former Yugoslav Republic of (MKD) 
##  Switzerland (CHE) 
##  Hungary (HUN) 
##  Serbia (SRB) 
##  Bulgaria (BGR) 
##  Croatia (HRV) 
##  Bosnia and Herzegovina (BIH) 
##  Czech Republic (CZE) 
##  Germany (DEU) 
##  Poland (POL) 
##  Slovakia (SVK) 
##  Lithuania (LTU) 
##  Denmark (DNK) 
##  Norway (NOR) 
##  Estonia (EST) 
##  Finland (FIN) 
##  Slovenia (SVN) 
##  Latvia (LVA) 
##  Portugal (PRT) 
##  Ukraine (UKR) 
##  Moldova, Republic of (MDA) 
##  Georgia (GEO)
```


```r
listSpecies(version = "201201")
```

```
## Downloading list of available species, please wait...
```

```
## Versions available for vector occurrence point data: 
##  201201
```

```
## Species with availale data: 
##  Anopheles gambiae  (Sudan) 
##  Anopheles arabiensis (Sudan) 
##  Anopheles coluzzii (Benin) 
##  Anopheles flavirostris (Philippines) 
##  Anopheles maculatus (Philippines) 
##  Anopheles minimus (Viet Nam) 
##  Anopheles minimus (Thailand) 
##  Anopheles maculatus (Malaysia) 
##  Anopheles dirus (Thailand) 
##  Anopheles barbirostris (Thailand) 
##  Anopheles maculatus (Thailand) 
##  Anopheles dirus (Myanmar) 
##  Anopheles aconitus (Thailand) 
##  Anopheles sinensis (Thailand) 
##  Anopheles annularis (Thailand) 
##  Anopheles sinensis (Lao People's Democratic Republic) 
##  Anopheles aconitus (Lao People's Democratic Republic) 
##  Anopheles minimus (Lao People's Democratic Republic) 
##  Anopheles annularis (Lao People's Democratic Republic) 
##  Anopheles barbirostris (Lao People's Democratic Republic) 
##  Anopheles aconitus (Malaysia) 
##  Anopheles sinensis (Malaysia) 
##  Anopheles barbirostris (Malaysia) 
##  Anopheles culicifacies (Thailand) 
##  Anopheles stephensi (Myanmar) 
##  Anopheles subpictus (Thailand) 
##  Anopheles sinensis (Myanmar) 
##  Anopheles atroparvus (Spain) 
##  Anopheles subpictus (Myanmar) 
##  Anopheles barbirostris (Myanmar) 
##  Anopheles gambiae (Comoros) 
##  Anopheles annularis (Myanmar) 
##  Anopheles culicifacies (Myanmar) 
##  Anopheles atroparvus (France) 
##  Anopheles aconitus (Myanmar) 
##  Anopheles koliensis (Indonesia) 
##  Anopheles punctulatus (Indonesia) 
##  Anopheles farauti (Indonesia) 
##  Anopheles sinensis (Indonesia) 
##  Anopheles sundaicus (Indonesia) 
##  Anopheles balabacensis (Malaysia) 
##  Anopheles minimus (Myanmar) 
##  Anopheles atroparvus (United Kingdom) 
##  Anopheles barbirostris (Indonesia) 
##  Anopheles subpictus (Indonesia) 
##  Anopheles aconitus (Indonesia) 
##  Anopheles maculatus (Myanmar) 
##  Anopheles messeae (United Kingdom) 
##  Anopheles sundaicus (Myanmar) 
##  Anopheles albimanus (Costa Rica) 
##  Anopheles albimanus (Nicaragua) 
##  Anopheles pseudopunctipennis (Costa Rica) 
##  Anopheles funestus (Kenya) 
##  Anopheles merus (South Africa) 
##  Anopheles gambiae  (Benin) 
##  Anopheles melas (Benin) 
##  Anopheles dirus (Lao People's Democratic Republic) 
##  Anopheles maculatus (Lao People's Democratic Republic) 
##  Anopheles culicifacies (Lao People's Democratic Republic) 
##  Anopheles funestus (Tanzania (United Republic of)) 
##  Anopheles dirus (Cambodia) 
##  Anopheles minimus (Cambodia) 
##  Anopheles dirus (Viet Nam) 
##  Anopheles sundaicus (Viet Nam) 
##  Anopheles arabiensis (Democratic Republic of the Congo) 
##  Anopheles arabiensis (Ethiopia) 
##  Anopheles funestus (Ethiopia) 
##  Anopheles moucheti (Cameroon) 
##  Anopheles funestus (Guinea) 
##  Anopheles gambiae  (Guinea) 
##  Anopheles nili (Burkina Faso) 
##  Anopheles funestus (Burkina Faso) 
##  Anopheles arabiensis (Senegal) 
##  Anopheles gambiae  (Senegal) 
##  Anopheles funestus (Uganda) 
##  Anopheles funestus (Mozambique) 
##  Anopheles funestus (Mali) 
##  Anopheles arabiensis (Mali) 
##  Anopheles gambiae  (Mali) 
##  Anopheles minimus (India) 
##  Anopheles funestus (Senegal) 
##  Anopheles melas (Senegal) 
##  Anopheles funestus (Madagascar) 
##  Anopheles gambiae (Madagascar) 
##  Anopheles funestus (Sudan) 
##  Anopheles arabiensis (Tanzania (United Republic of)) 
##  Anopheles melas (Guinea-Bissau) 
##  Anopheles gambiae  (Guinea-Bissau) 
##  Anopheles funestus (Cameroon) 
##  Anopheles sinensis (China) 
##  Anopheles nili (Niger) 
##  Anopheles arabiensis (Uganda) 
##  Anopheles gambiae  (Uganda) 
##  Anopheles nili (Ethiopia) 
##  Anopheles arabiensis (Kenya) 
##  Anopheles nili (Cameroon) 
##  Anopheles gambiae  (Cameroon) 
##  Anopheles melas (The Gambia) 
##  Anopheles arabiensis (The Gambia) 
##  Anopheles darlingi (Brazil) 
##  Anopheles gambiae  (The Gambia) 
##  Anopheles merus (Kenya) 
##  Anopheles gambiae (Kenya) 
##  Anopheles annularis (India) 
##  Anopheles funestus (Côte d'Ivoire) 
##  Anopheles maculatus (India) 
##  Anopheles darlingi (Venezuela) 
##  Anopheles darlingi (French Guiana) 
##  Anopheles gambiae (Tanzania (United Republic of)) 
##  Anopheles arabiensis (Burkina Faso) 
##  Anopheles gambiae  (Côte d'Ivoire) 
##  Anopheles lesteri (China) 
##  Anopheles gambiae  (São Tomé and Príncipe) 
##  Anopheles arabiensis (Madagascar) 
##  Anopheles culicifacies (India) 
##  Anopheles arabiensis (Mozambique) 
##  Anopheles barbirostris (India) 
##  Anopheles gambiae  (Nigeria) 
##  Anopheles sacharovi (Turkey) 
##  Anopheles arabiensis (Eritrea) 
##  Anopheles superpictus (Turkey) 
##  Anopheles annularis (Sri Lanka) 
##  Anopheles maculatus (Sri Lanka) 
##  Anopheles aconitus (Sri Lanka) 
##  Anopheles subpictus (Sri Lanka) 
##  Anopheles culicifacies (Sri Lanka) 
##  Anopheles barbirostris (Sri Lanka) 
##  Anopheles stephensi (India) 
##  Anopheles stephensi (Pakistan) 
##  Anopheles culicifacies (Pakistan) 
##  Anopheles aconitus (India) 
##  Anopheles subpictus (India) 
##  Anopheles fluviatilis (India) 
##  Anopheles dirus (India) 
##  Anopheles subpictus (Pakistan) 
##  Anopheles darlingi (Bolivia) 
##  Anopheles fluviatilis (Sri Lanka) 
##  Anopheles maculatus (Pakistan) 
##  Anopheles fluviatilis (Pakistan) 
##  Anopheles superpictus (Pakistan) 
##  Anopheles darlingi (Peru) 
##  Anopheles nuneztovari (Colombia) 
##  Anopheles albimanus (Colombia) 
##  Anopheles albimanus (Guatemala) 
##  Anopheles pseudopunctipennis (Peru) 
##  Anopheles albimanus (Peru) 
##  Anopheles darlingi (Suriname) 
##  Anopheles dirus (China) 
##  Anopheles minimus (China) 
##  Anopheles gambiae  (Democratic Republic of the Congo) 
##  Anopheles nili (Democratic Republic of the Congo) 
##  Anopheles funestus (Democratic Republic of the Congo) 
##  Anopheles funestus (Burundi) 
##  Anopheles gambiae  (Burundi) 
##  Anopheles gambiae  (Burkina Faso) 
##  Anopheles arabiensis (Nigeria) 
##  Anopheles melas (Nigeria) 
##  Anopheles moucheti (Nigeria) 
##  Anopheles funestus (Gabon) 
##  Anopheles moucheti (Gabon) 
##  Anopheles nili (Gabon) 
##  Anopheles merus (Madagascar) 
##  Anopheles gambiae  (Sierra Leone) 
##  Anopheles funestus (Sierra Leone) 
##  Anopheles merus (Tanzania (United Republic of)) 
##  Anopheles albitarsis (Brazil) 
##  Anopheles nuneztovari (Brazil) 
##  Anopheles gambiae (Cameroon) 
##  Anopheles subpictus (Timor-Leste) 
##  Anopheles gambiae  (Ghana) 
##  Anopheles darlingi (Belize) 
##  Anopheles arabiensis (South Africa) 
##  Anopheles sacharovi (Azerbaijan) 
##  Anopheles sacharovi (Iran) 
##  Anopheles arabiensis (Saudi Arabia) 
##  Anopheles sacharovi (Armenia) 
##  Anopheles arabiensis (Zimbabwe) 
##  Anopheles funestus (Ghana) 
##  Anopheles funestus (Equatorial Guinea) 
##  Anopheles funestus (South Africa) 
##  Anopheles merus (Mozambique) 
##  Anopheles nili (Senegal) 
##  Anopheles gambiae (Senegal) 
##  Anopheles superpictus (Iran) 
##  Anopheles darlingi (Colombia) 
##  Anopheles funestus (Angola) 
##  Anopheles gambiae (Burkina Faso) 
##  Anopheles albitarsis (Venezuela) 
##  Anopheles coluzzii (Senegal) 
##  Anopheles aquasalis (Venezuela) 
##  Anopheles gambiae (Mali) 
##  Anopheles atroparvus (Netherlands) 
##  Anopheles sergentii (Saudi Arabia) 
##  Anopheles coluzzii (Mali) 
##  Anopheles gambiae (Nigeria) 
##  Anopheles coluzzii (Nigeria) 
##  Anopheles sergentii (Egypt) 
##  Anopheles darlingi (Guatemala) 
##  Anopheles aquasalis (Trinidad and Tobago) 
##  Anopheles arabiensis (Malawi) 
##  Anopheles aquasalis (Brazil) 
##  Anopheles arabiensis (Burundi) 
##  Anopheles labranchiae (Italy) 
##  Anopheles gambiae  (Gabon) 
##  Anopheles superpictus (Greece) 
##  Anopheles arabiensis (Cameroon) 
##  Anopheles gambiae (Malawi) 
##  Anopheles funestus (Malawi) 
##  Anopheles funestus (Nigeria) 
##  Anopheles sacharovi (Greece) 
##  Anopheles coluzzii (São Tomé and Príncipe) 
##  Anopheles nili (Equatorial Guinea) 
##  Anopheles coluzzii (Burkina Faso) 
##  Anopheles stephensi (Iran) 
##  Anopheles punctulatus (Papua New Guinea) 
##  Anopheles arabiensis (Ghana) 
##  Anopheles nili (Ghana) 
##  Anopheles melas (Ghana) 
##  Anopheles coluzzii (Angola) 
##  Anopheles melas (Angola) 
##  Anopheles gambiae (Angola) 
##  Anopheles gambiae  (Equatorial Guinea) 
##  Anopheles melas (Equatorial Guinea) 
##  Anopheles gambiae  (Liberia) 
##  Anopheles atroparvus (Romania) 
##  Anopheles messeae (Romania) 
##  Anopheles arabiensis (Namibia) 
##  Anopheles arabiensis (Mauritania) 
##  Anopheles gambiae  (Mauritania) 
##  Anopheles atroparvus (Belgium) 
##  Anopheles messeae (Belgium) 
##  Anopheles coluzzii (Cameroon) 
##  Anopheles gambiae (Democratic Republic of the Congo) 
##  Anopheles gambiae (Gabon) 
##  Anopheles coluzzii (Ghana) 
##  Anopheles gambiae (Zambia) 
##  Anopheles funestus (Comoros) 
##  Anopheles atroparvus (Italy) 
##  Anopheles nili (Kenya) 
##  Anopheles nili (Nigeria) 
##  Anopheles superpictus (Italy) 
##  Anopheles funestus (Zimbabwe) 
##  Anopheles gambiae  (Zimbabwe) 
##  Anopheles moucheti (Equatorial Guinea) 
##  Anopheles gambiae (Ghana) 
##  Anopheles melas (Cameroon) 
##  Anopheles gambiae (Equatorial Guinea) 
##  Anopheles albitarsis (Bolivia) 
##  Anopheles marajoara (Trinidad and Tobago) 
##  Anopheles marajoara (Venezuela) 
##  Anopheles marajoara (Colombia) 
##  Anopheles pseudopunctipennis (Belize) 
##  Anopheles albimanus (Belize) 
##  Anopheles albimanus (Cuba) 
##  Anopheles albimanus (Mexico) 
##  Anopheles albimanus (El Salvador) 
##  Anopheles quadrimaculatus (United States of America) 
##  Anopheles pseudopunctipennis (Mexico) 
##  Anopheles albimanus (Dominican Republic) 
##  Anopheles marajoara (Brazil) 
##  Anopheles nuneztovari (Venezuela) 
##  Anopheles aquasalis (Guyana) 
##  Anopheles darlingi (Guyana) 
##  Anopheles pseudopunctipennis (Grenada) 
##  Anopheles albimanus (Venezuela) 
##  Anopheles albimanus (Ecuador) 
##  Anopheles pseudopunctipennis (Venezuela) 
##  Anopheles pseudopunctipennis (Nicaragua) 
##  Anopheles subpictus (Malaysia) 
##  Anopheles aquasalis (Grenada) 
##  Anopheles pseudopunctipennis (United States of America) 
##  Anopheles pseudopunctipennis (Guatemala) 
##  Anopheles albitarsis (Argentina) 
##  Anopheles pseudopunctipennis (Colombia) 
##  Anopheles pseudopunctipennis (Ecuador) 
##  Anopheles pseudopunctipennis (Argentina) 
##  Anopheles nuneztovari (Suriname) 
##  Anopheles freeborni (United States of America) 
##  Anopheles albitarsis (Trinidad and Tobago) 
##  Anopheles gambiae (Mozambique) 
##  Anopheles nuneztovari (Bolivia) 
##  Anopheles arabiensis (Swaziland) 
##  Anopheles merus (Swaziland) 
##  Anopheles messeae (Montenegro) 
##  Anopheles albimanus (Haiti) 
##  Anopheles messeae (Greece) 
##  Anopheles darlingi (Mexico) 
##  Anopheles aquasalis (Suriname) 
##  Anopheles albimanus (Honduras) 
##  Anopheles farauti (Vanuatu) 
##  Anopheles nuneztovari (Peru) 
##  Anopheles sundaicus (India) 
##  Anopheles arabiensis (Botswana) 
##  Anopheles koliensis (Papua New Guinea) 
##  Anopheles farauti (Papua New Guinea) 
##  Anopheles sinensis (Korea, Republic of) 
##  Anopheles farauti (Solomon Islands) 
##  Anopheles punctulatus (Solomon Islands) 
##  Anopheles fluviatilis (Iran) 
##  Anopheles culicifacies (Iran) 
##  Anopheles sergentii (Iran) 
##  Anopheles farauti (Australia) 
##  Anopheles koliensis (Solomon Islands) 
##  Anopheles maculatus (China) 
##  Anopheles minimus (Indonesia) 
##  Anopheles maculatus (Singapore) 
##  Anopheles subpictus (Philippines) 
##  Anopheles annularis (Philippines) 
##  Anopheles balabacensis (Philippines) 
##  Anopheles balabacensis (Indonesia) 
##  Anopheles leucosphyrus (Indonesia) 
##  Anopheles subpictus (Nepal) 
##  Anopheles aconitus (Nepal) 
##  Anopheles maculatus (Nepal) 
##  Anopheles sinensis (Nepal) 
##  Anopheles annularis (Nepal) 
##  Anopheles culicifacies (Nepal) 
##  Anopheles fluviatilis (Nepal) 
##  Anopheles barbirostris (Nepal) 
##  Anopheles subpictus (Cambodia) 
##  Anopheles sinensis (Korea, Democratic People's Republic of) 
##  Anopheles sinensis (Japan) 
##  Anopheles aconitus (China) 
##  Anopheles aconitus (Viet Nam) 
##  Anopheles dirus (Bangladesh) 
##  Anopheles leucosphyrus (Malaysia) 
##  Anopheles leucosphyrus (Thailand) 
##  Anopheles sinensis (Macau) 
##  Anopheles lesteri (Korea, Republic of) 
##  Anopheles aconitus (Bangladesh) 
##  Anopheles annularis (Bangladesh) 
##  Anopheles barbirostris (Bangladesh) 
##  Anopheles sundaicus (Thailand) 
##  Anopheles sundaicus (Malaysia) 
##  Anopheles culicifacies (Eritrea) 
##  Anopheles sinensis (Cambodia) 
##  Anopheles messeae (Austria) 
##  Anopheles sinensis (Viet Nam) 
##  Anopheles maculatus (Viet Nam) 
##  Anopheles barbirostris (Viet Nam) 
##  Anopheles culicifacies (Viet Nam) 
##  Anopheles aconitus (Cambodia) 
##  Anopheles culicifacies (Cambodia) 
##  Anopheles maculatus (Indonesia) 
##  Anopheles stephensi (Afghanistan) 
##  Anopheles flavirostris (Indonesia) 
##  Anopheles barbirostris (Cambodia) 
##  Anopheles atroparvus (Austria) 
##  Anopheles maculatus (Cambodia) 
##  Anopheles annularis (Viet Nam) 
##  Anopheles subpictus (Viet Nam) 
##  Anopheles messeae (Italy) 
##  Anopheles arabiensis (Réunion) 
##  Anopheles nili (Côte d'Ivoire) 
##  Anopheles gambiae (Côte d'Ivoire) 
##  Anopheles funestus (Niger) 
##  Anopheles arabiensis (Yemen) 
##  Anopheles nuneztovari (Argentina) 
##  Anopheles aquasalis (French Guiana) 
##  Anopheles nili (Uganda) 
##  Anopheles arabiensis (Zambia) 
##  Anopheles funestus (Zambia) 
##  Anopheles gambiae  (Niger) 
##  Anopheles coluzzii (Côte d'Ivoire) 
##  Anopheles arabiensis (Niger) 
##  Anopheles pseudopunctipennis (Bolivia) 
##  Anopheles subpictus (Papua New Guinea) 
##  Anopheles culicifacies (Yemen) 
##  Anopheles arabiensis (Somalia) 
##  Anopheles annularis (China) 
##  Anopheles barbirostris (China) 
##  Anopheles culicifacies (China) 
##  Anopheles funestus (Somalia) 
##  Anopheles sergentii (Jordan) 
##  Anopheles coluzzii (Equatorial Guinea) 
##  Anopheles funestus (Eritrea) 
##  Anopheles minimus (Japan) 
##  Anopheles albitarsis (Paraguay) 
##  Anopheles messeae (Sweden) 
##  Anopheles gambiae  (Congo) 
##  Anopheles coluzzii (The Gambia) 
##  Anopheles gambiae (Guinea) 
##  Anopheles gambiae (Benin) 
##  Anopheles superpictus (Albania) 
##  Anopheles stephensi (Iraq) 
##  Anopheles sacharovi (Albania) 
##  Anopheles funestus (Guinea-Bissau) 
##  Anopheles messeae (Russian Federation) 
##  Anopheles gambiae  (Central African Republic) 
##  Anopheles sergentii (Israel) 
##  Anopheles superpictus (Israel) 
##  Anopheles arabiensis (Benin) 
##  Anopheles gambiae (Central African Republic) 
##  Anopheles gambiae (Zimbabwe) 
##  Anopheles sergentii (Morocco) 
##  Anopheles superpictus (Tajikistan) 
##  Anopheles superpictus (Uzbekistan) 
##  Anopheles gambiae  (Togo) 
##  Anopheles labranchiae (Morocco) 
##  Anopheles merus (Zimbabwe) 
##  Anopheles nuneztovari (French Guiana) 
##  Anopheles gambiae (Guinea-Bissau) 
##  Anopheles funestus (Botswana) 
##  Anopheles albitarsis (Colombia) 
##  Anopheles moucheti (Democratic Republic of the Congo) 
##  Anopheles moucheti (Uganda) 
##  Anopheles funestus (Benin) 
##  Anopheles sundaicus (Cambodia) 
##  Anopheles stephensi (United Arab Emirates) 
##  Anopheles minimus (Bangladesh) 
##  Anopheles albimanus (Panama) 
##  Anopheles annularis (Indonesia) 
##  Anopheles gambiae (The Gambia) 
##  Anopheles arabiensis (Chad) 
##  Anopheles coluzzii (Chad) 
##  Anopheles gambiae (Chad) 
##  Anopheles coluzzii (Niger) 
##  Anopheles gambiae (Niger) 
##  Anopheles aquasalis (Costa Rica) 
##  Anopheles aquasalis (Panama) 
##  Anopheles pseudopunctipennis (Panama) 
##  Anopheles albitarsis (Panama) 
##  Anopheles gambiae (Uganda) 
##  Anopheles melas (Côte d'Ivoire) 
##  Anopheles messeae (Macedonia, the former Yugoslav Republic of) 
##  Anopheles superpictus (Macedonia, the former Yugoslav Republic of) 
##  Anopheles atroparvus (Switzerland) 
##  Anopheles atroparvus (Hungary) 
##  Anopheles messeae (Hungary) 
##  Anopheles atroparvus (Russian Federation) 
##  Anopheles superpictus (Serbia) 
##  Anopheles messeae (Serbia) 
##  Anopheles atroparvus (Serbia) 
##  Anopheles messeae (Bulgaria) 
##  Anopheles superpictus (Bulgaria) 
##  Anopheles atroparvus (Bulgaria) 
##  Anopheles sacharovi (Bulgaria) 
##  Anopheles superpictus (Romania) 
##  Anopheles labranchiae (Croatia) 
##  Anopheles messeae (Bosnia and Herzegovina) 
##  Anopheles superpictus (Bosnia and Herzegovina) 
##  Anopheles labranchiae (Bosnia and Herzegovina) 
##  Anopheles atroparvus (Bosnia and Herzegovina) 
##  Anopheles messeae (Czech Republic) 
##  Anopheles atroparvus (Czech Republic) 
##  Anopheles messeae (Switzerland) 
##  Anopheles atroparvus (Germany) 
##  Anopheles superpictus (Czech Republic) 
##  Anopheles messeae (Germany) 
##  Anopheles atroparvus (Poland) 
##  Anopheles messeae (Slovakia) 
##  Anopheles atroparvus (Slovakia) 
##  Anopheles messeae (Lithuania) 
##  Anopheles atroparvus (Lithuania) 
##  Anopheles sacharovi (Romania) 
##  Anopheles atroparvus (Denmark) 
##  Anopheles messeae (Denmark) 
##  Anopheles atroparvus (Norway) 
##  Anopheles atroparvus (Sweden) 
##  Anopheles messeae (Poland) 
##  Anopheles labranchiae (Spain) 
##  Anopheles atroparvus (Estonia) 
##  Anopheles messeae (Estonia) 
##  Anopheles messeae (Finland) 
##  Anopheles messeae (France) 
##  Anopheles sacharovi (France) 
##  Anopheles labranchiae (France) 
##  Anopheles superpictus (France) 
##  Anopheles messeae (Croatia) 
##  Anopheles messeae (Slovenia) 
##  Anopheles atroparvus (Slovenia) 
##  Anopheles sacharovi (Slovenia) 
##  Anopheles superpictus (Slovenia) 
##  Anopheles atroparvus (Croatia) 
##  Anopheles sacharovi (Croatia) 
##  Anopheles superpictus (Croatia) 
##  Anopheles sacharovi (Bosnia and Herzegovina) 
##  Anopheles atroparvus (Montenegro) 
##  Anopheles superpictus (Montenegro) 
##  Anopheles atroparvus (Greece) 
##  Anopheles sacharovi (Italy) 
##  Anopheles atroparvus (Latvia) 
##  Anopheles messeae (Latvia) 
##  Anopheles messeae (Netherlands) 
##  Anopheles messeae (Norway) 
##  Anopheles atroparvus (Portugal) 
##  Anopheles sacharovi (Ukraine) 
##  Anopheles superpictus (Moldova, Republic of) 
##  Anopheles atroparvus (Moldova, Republic of) 
##  Anopheles messeae (Moldova, Republic of) 
##  Anopheles messeae (Turkey) 
##  Anopheles atroparvus (Turkey) 
##  Anopheles atroparvus (Ukraine) 
##  Anopheles messeae (Ukraine) 
##  Anopheles superpictus (Russian Federation) 
##  Anopheles superpictus (Georgia) 
##  Anopheles sacharovi (Russian Federation) 
##  Anopheles sacharovi (Serbia) 
##  Anopheles arabiensis (Angola) 
##  Anopheles coluzzii (Zimbabwe) 
##  Anopheles coluzzii (Guinea-Bissau) 
##  Anopheles coluzzii (Guinea) 
##  Anopheles coluzzii (Democratic Republic of the Congo) 
##  Anopheles coluzzii (Central African Republic)
```

### List Administrative Units

To list administrative units for which shapefiles are stored on the MAP geoserver, use `listShp()`. Similar to the list countries and species functions, this function can optionally take a version.


```r
listShp(version = "202206")
```

```
## Shapefiles Available to Download for: 
##  Afghanistan 
##  Albania 
##  Algeria 
##  American Samoa 
##  Andorra 
##  Angola 
##  Anguilla 
##  Antarctica 
##  Antigua and Barbuda 
##  Argentina 
##  Armenia 
##  Aruba 
##  Australia 
##  Austria 
##  Azerbaijan 
##  Bahamas 
##  Bahrain 
##  Bangladesh 
##  Barbados 
##  Belarus 
##  Belgium 
##  Belize 
##  Benin 
##  Bermuda 
##  Bhutan 
##  Bolivia 
##  Bosnia and Herzegovina 
##  Botswana 
##  Bouvet Island 
##  Brazil 
##  British Indian Ocean Territory 
##  British Virgin Islands 
##  Brunei Darussalam 
##  Bulgaria 
##  Burkina Faso 
##  Burundi 
##  Cambodia 
##  Cameroon 
##  Canada 
##  Cape Verde 
##  Cayman Islands 
##  Central African Republic 
##  Chad 
##  Chile 
##  China 
##  Christmas Island 
##  Clipperton Island 
##  Cocos (Keeling) Islands 
##  Colombia 
##  Comoros 
##  Congo 
##  Cook Islands 
##  Costa Rica 
##  Côte d'Ivoire 
##  Croatia 
##  Cuba 
##  Cyprus 
##  Czech Republic 
##  Democratic Republic of the Congo 
##  Denmark 
##  Dhekelia and Akrotiri SBA 
##  Djibouti 
##  Dominica 
##  Dominican Republic 
##  Ecuador 
##  Egypt 
##  El Salvador 
##  Equatorial Guinea 
##  Eritrea 
##  Estonia 
##  Ethiopia 
##  Falkland Islands 
##  Faroe Islands 
##  Fiji 
##  Finland 
##  France 
##  French Guiana 
##  French Polynesia 
##  French Southern and Antarctic Territories 
##  Gabon 
##  Gambia 
##  Georgia 
##  Germany 
##  Ghana 
##  Gibraltar 
##  Greece 
##  Greenland 
##  Grenada 
##  Guadeloupe 
##  Guam 
##  Guatemala 
##  Guernsey 
##  Guinea 
##  Guinea-Bissau 
##  Guyana 
##  Haiti 
##  Heard Island and McDonald Islands 
##  Honduras 
##  Hong Kong 
##  Hungary 
##  Iceland 
##  India 
##  Indonesia 
##  Iran 
##  Iraq 
##  Ireland 
##  Isle of Man 
##  Israel 
##  Italy 
##  Jamaica 
##  Japan 
##  Jersey 
##  Jordan 
##  Kazakhstan 
##  Kenya 
##  Kiribati 
##  Kuwait 
##  Kyrgyzstan 
##  Laos 
##  Latvia 
##  Lebanon 
##  Lesotho 
##  Liberia 
##  Libya 
##  Liechtenstein 
##  Lithuania 
##  Luxembourg 
##  Macau 
##  Macedonia 
##  Madagascar 
##  Malawi 
##  Malaysia 
##  Maldives 
##  Mali 
##  Malta 
##  Marshall Islands 
##  Martinique 
##  Mauritania 
##  Mauritius 
##  Mayotte 
##  Mexico 
##  Micronesia 
##  Moldova 
##  Monaco 
##  Mongolia 
##  Montenegro 
##  Montserrat 
##  Morocco 
##  Mozambique 
##  Myanmar 
##  Namibia 
##  Nauru 
##  Nepal 
##  Netherlands 
##  Netherlands Antilles 
##  New Caledonia 
##  New Zealand 
##  Nicaragua 
##  Niger 
##  Nigeria 
##  Niue 
##  Norfolk Island 
##  North Korea 
##  Northern Mariana Islands 
##  Norway 
##  Oman 
##  Pakistan 
##  Palau 
##  Palestinian Territories 
##  Panama 
##  Papua New Guinea 
##  Paracel Islands 
##  Paraguay 
##  Peru 
##  Philippines 
##  Pitcairn 
##  Poland 
##  Portugal 
##  Puerto Rico 
##  Qatar 
##  Réunion 
##  Romania 
##  Russia 
##  Rwanda 
##  Saint Helena 
##  Saint Kitts and Nevis 
##  Saint Lucia 
##  Saint Pierre et Miquelon 
##  Saint Vincent and the Grenadines 
##  Samoa 
##  San Marino 
##  Sao Tome And Principe 
##  Saudi Arabia 
##  Scarborough Reef 
##  Senegal 
##  Serbia 
##  Seychelles 
##  Sierra Leone 
##  Singapore 
##  Slovakia 
##  Slovenia 
##  Solomon Islands 
##  Somalia 
##  South Africa 
##  South Georgia and the South Sandwich Islands 
##  South Korea 
##  South Sudan 
##  Spain 
##  Spratly Islands 
##  Sri Lanka 
##  Sudan 
##  Suriname 
##  Svalbard and Jan Mayen Islands 
##  Swaziland 
##  Sweden 
##  Switzerland 
##  Syria 
##  Taiwan 
##  Tajikistan 
##  Tanzania 
##  Thailand 
##  Timor-Leste 
##  Togo 
##  Tokelau 
##  Tonga 
##  Trinidad and Tobago 
##  Tunisia 
##  Turkey 
##  Turkmenistan 
##  Turks and Caicos islands 
##  Tuvalu 
##  Uganda 
##  Ukraine 
##  United Arab Emirates 
##  United Kingdom 
##  United States Minor Outlying Islands 
##  United States of America 
##  United States Virgin Islands 
##  Uruguay 
##  Uzbekistan 
##  Vanuatu 
##  Vatican City 
##  Venezuela 
##  Vietnam 
##  Wallis and Futuna 
##  Western Sahara 
##  Yemen 
##  Zambia 
##  Zimbabwe
```

### List Raster Function

`listRaster()` gets minimal information on all available rasters. It returns a data.frame with several columns for each raster such as dataset_id, title, abstract, min_raster_year and max_raster_year. The dataset_id can then be used in `getRaster` and `extractRaster`.


```r
listRaster()
```

```
## Downloading list of available rasters...
```

```
## Rasters Available for Download: 
##  Malaria__202206_Global_Pf_Mortality_Count 
##  Malaria__202206_Global_Pf_Mortality_Rate 
##  Malaria__202206_Global_Pf_Incidence_Rate 
##  Malaria__202206_Global_Pf_Incidence_Count 
##  Malaria__202206_Global_Pv_Incidence_Rate 
##  Malaria__202206_Global_Pv_Incidence_Count 
##  Malaria__202206_Global_Pf_Parasite_Rate 
##  Malaria__202206_Global_Pv_Parasite_Rate 
##  Malaria__202202_Global_Pf_Reproductive_Number 
##  Interventions__202106_Global_Antimalarial_Effective_Treatment 
##  Interventions__202106_Africa_Insecticide_Treated_Net_Use_Rate 
##  Interventions__202106_Africa_Insecticide_Treated_Net_Access 
##  Interventions__202106_Africa_IRS_Coverage 
##  Interventions__202106_Africa_Insecticide_Treated_Net_Use 
##  Blood_Disorders__201201_Global_Duffy_Negativity_Phenotype_Frequency 
##  Blood_Disorders__201201_Global_G6PDd_Allele_Frequency 
##  Blood_Disorders__201201_Africa_HbC_Allele_Frequency 
##  Blood_Disorders__201201_Global_Sickle_Haemoglobin_HbS_Allele_Frequency 
##  Accessibility__202001_Global_Motorized_Friction_Surface 
##  Accessibility__202001_Global_Walking_Only_Friction_Surface 
##  Accessibility__201501_Global_Friction_Surface 
##  Accessibility__201501_Global_Travel_Time_to_Cities 
##  Accessibility__202001_Global_Motorized_Travel_Time_to_Healthcare 
##  Accessibility__202001_Global_Walking_Only_Travel_Time_To_Healthcare 
##  Vector_Occurrence__201201_Global_Dominant_Vector_Species 
##  Explorer__2010_Anopheles_aconitus 
##  Explorer__2010_Anopheles_albimanus 
##  Explorer__2010_Anopheles_albitarsis 
##  Explorer__2010_Anopheles_annularis 
##  Explorer__2010_Anopheles_aquasalis 
##  Explorer__2010_Anopheles_arabiensis 
##  Explorer__2010_Anopheles_atroparvus 
##  Explorer__2010_Anopheles_balabacensis 
##  Explorer__2017_Anopheles_coluzzii.Mean_Decompressed 
##  Explorer__2010_Anopheles_culicifacies 
##  Explorer__2010_Anopheles_darlingi 
##  Explorer__2010_Anopheles_dirus_complex 
##  Explorer__2016_Anopheles_dirus 
##  Explorer__2010_Anopheles_farauti 
##  Explorer__2010_Anopheles_flavirostris 
##  Explorer__2010_Anopheles_fluviatilis 
##  Explorer__2010_Anopheles_freeborni 
##  Explorer__2010_Anopheles_funestus 
##  Explorer__2017_Anopheles_funestus_group.Mean_Decompressed 
##  Explorer__2017_Anopheles_funestus_subgroup.Mean_Decompressed 
##  Explorer__2017_Anophele_funestus.Mean_Decompressed 
##  Explorer__2017_Anopheles_gambiae.Mean_Decompressed 
##  Explorer__2017_Anopheles_gambiae_complex.Mean_Decompressed 
##  Explorer__2010_Anopheles_gambiae_ss 
##  Explorer__2010_Anopheles_koliensis 
##  Explorer__2010_Anopheles_labranchiae 
##  Explorer__2010_Anopheles_lesteri 
##  Explorer__2010_Anopheles_leuco_latens 
##  Explorer__2016_Anopheles_leucosphyrus_complex 
##  Explorer__2016_Anopheles_leucosphyrus_group 
##  Explorer__2010_Anopheles_maculatus 
##  Explorer__2010_Anopheles_marajoara 
##  Explorer__2010_Anopheles_melas 
##  Explorer__2017_Anopheles_merus.Mean_Decompressed 
##  Explorer__2010_Anopheles_merus 
##  Explorer__2010_Anopheles_messeae 
##  Explorer__2010_Anopheles_minimus 
##  Explorer__2010_Anopheles_moucheti 
##  Explorer__2010_Anopheles_nili 
##  Explorer__2010_Anopheles_nuneztovari 
##  Explorer__2010_Anopheles_pseudopuncti 
##  Explorer__2010_Anopheles_punctulatus 
##  Explorer__2010_Anopheles_quadrimacul 
##  Explorer__2010_Anopheles_sacharovi 
##  Explorer__2010_Anopheles_sergentii 
##  Explorer__2010_Anopheles_sinensis 
##  Explorer__2010_Anopheles_stephensi 
##  Explorer__2010_Anopheles_subpictus 
##  Explorer__2010_Anopheles_sundaicus 
##  Explorer__2010_Anopheles_superpictus 
##  Explorer__2016_Macaca_fascicularis 
##  Explorer__2016_Macaca_leonina 
##  Explorer__2016_Macaca_nemestrina 
##  Explorer__2019_Global_Pf_Incidence 
##  Explorer__2020_Global_Pf_Incidence 
##  Explorer__2015_Nature_Africa_Incidence 
##  Explorer__2019_Global_Pf_Mortality_Rate 
##  Explorer__2019_Global_PfPR 
##  Explorer__2020_Global_PfPR 
##  Explorer__2015_Nature_Africa_PR 
##  Explorer__2020_Global_Pf_Reproductive_Number 
##  Explorer__2010_Pf_Limits_Decompressed 
##  Explorer__2010_TempSuitability.Pf.AnnualInfectiousDays.1k.global_Decompressed 
##  Explorer__2010_TempSuitability.Pf.Index.1k.global_Decompressed 
##  Explorer__2016_Pk_SEAsia_masked 
##  Explorer__2019_Global_Pv_Cases 
##  Explorer__2020_Global_Pv_Cases 
##  Explorer__2019_Global_Pv_Incidence 
##  Explorer__2020_Global_Pv_Incidence 
##  Explorer__2019_Global_PvPR 
##  Explorer__2020_Global_PvPR 
##  Explorer__2013_Pv_Relapse_Incidence_Decompressed 
##  Explorer__2010_Pv_limits_5k_Decompressed 
##  Explorer__2010_TempSuitability.Pv.AnnualInfectiousDays.1k.global_Decompressed 
##  Explorer__2010_TempSuitability.Pv.Index.1k.global_Decompressed 
##  Explorer__2015_friction_surface_v1_Decompressed 
##  Explorer__2015_accessibility_to_cities_v1.0 
##  Explorer__2017_All_Cause_Fever 
##  Explorer__2015_Nature_Africa_ACT 
##  Explorer__2010_Dominant_Vector_Species_Global_5k 
##  Explorer__2011_Duffy_Negativity_Phenotype_Frequency_5k_Decompressed 
##  Explorer__2020_Global_AM_Effective_Treatment 
##  Explorer__2012_G6PDd_Allele_Frequency_Global_5k_Decompressed 
##  Explorer__2013_HbC_Allele_Freq_Africa_5k 
##  Explorer__2013_Sickle_Haemoglobin_HbS_Allele_Freq_Global_5k_Decompressed 
##  Explorer__2020_Africa_IRS_Coverage 
##  Explorer__2015_Nature_Africa_IRS 
##  Explorer__2015_Nature_Africa_ITN 
##  Explorer__2017_Malaria_Attributable_Prop_All_Fever 
##  Explorer__2017_Malaria_Attributable_Prop_Malaria_Positive 
##  Explorer__2017_Malaria_Positive_Prop_All_Fever 
##  Explorer__2017_Non_Malarial_Fever 
##  Explorer__2020_Global_Pf_Mortality_Rate 
##  Explorer__2019_Nature_Africa_Housing_2000 
##  Explorer__2019_Nature_Africa_Housing_2015 
##  Explorer__2010_Secondary-Dominant_Vector_Species_Africa
```

### Is Available Functions

`isAvailable_pr` confirms whether or not PR survey point data is available to download for a specified country, ISO3 code or continent. 

Check whether PR data is available for Madagascar:

```r
isAvailable_pr(country = "Madagascar")
```

```
## Creating list of countries for which MAP data is available, please wait...
```

```
## Versions available for PR point data: 
##  202206
```

```
## Please Note: Because you did not provide a version, by default the version being used is 202206 (This is the most recent version of PR data. To see other version options use function listPRPointVersions)
```

```
## Confirming availability of PR data for: Madagascar...
```

```
## PR points are available for Madagascar.
```

Check whether PR data is available for the United States of America by ISO code:

```r
isAvailable_pr(ISO = "USA")
```

```
## Creating list of countries for which MAP data is available, please wait...
```

```
## Versions available for PR point data: 
##  202206
```

```
## Please Note: Because you did not provide a version, by default the version being used is 202206 (This is the most recent version of PR data. To see other version options use function listPRPointVersions)
```

```
## Confirming availability of PR data for: USA...
```

```
## Specified location not found, see below comments: 
##  
## Data not found for 'USA', did you mean UGA OR SAU?
```

Check whether PR data is available for Asia:

```r
isAvailable_pr(continent = "Asia")
```

```
## Creating list of countries for which MAP data is available, please wait...
```

```
## Versions available for PR point data: 
##  202206
```

```
## Please Note: Because you did not provide a version, by default the version being used is 202206 (This is the most recent version of PR data. To see other version options use function listPRPointVersions)
```

```
## Confirming availability of PR data for: Asia...
```

```
## PR points are available for Asia.
```

`isAvailable_vec` confirms whether or not vector survey point data is available to download for a specified country, ISO3 code or continent. 

Check whether vector data is available for Myanmar:

```r
isAvailable_vec(country = "Myanmar")
```

```
## Creating list of countries for which MAP vector occurrence point data is available, please wait...
```

```
## Versions available for vector occurrence point data: 
##  201201
```

```
## Please Note: Because you did not provide a version, by default the version being used is 201201 (This is the most recent version of vector data. To see other version options use function listVecOccPointVersions)
```

```
## Confirming availability of Vector data for: Myanmar...
```

```
## Vector points are available for Myanmar.
```

Check whether vector data is available for multiple countries:

```r
isAvailable_vec(country = c("Nigeria", "Ethiopia"))
```

```
## Creating list of countries for which MAP vector occurrence point data is available, please wait...
```

```
## Versions available for vector occurrence point data: 
##  201201
```

```
## Please Note: Because you did not provide a version, by default the version being used is 201201 (This is the most recent version of vector data. To see other version options use function listVecOccPointVersions)
```

```
## Confirming availability of Vector data for: Nigeria, Ethiopia...
```

```
## Vector points are available for Nigeria, Ethiopia.
```

You can also pass these functions a dataset version. If you don't they will default to using the most recent version.


```r
isAvailable_pr(country = "Madagascar", version = "202206")
```

```
## Creating list of countries for which MAP data is available, please wait...
```

```
## Versions available for PR point data: 
##  202206
```

```
## Confirming availability of PR data for: Madagascar...
```

```
## PR points are available for Madagascar.
```


## Downloading & Visualising Data: 
### get* functions & autoplot methods

### Parasite Rate Survey Points
`getPR()` downloads all publicly available PR data points for a specified location (country, ISO, continent or extent) and plasmodium species (Pf, Pv or BOTH) and returns this as a dataframe with the following format: 


```r
MDG_pr_data <- getPR(country = "Madagascar", species = "both")
```

```
## Warning: The `sourcedata` argument of `isAvailable_pr()` is deprecated as of malariaAtlas 1.5.0.
## ℹ The argument 'sourcedata' has been deprecated. It will be removed in the next version. It has no meaning.
## ℹ The deprecated feature was likely used in the malariaAtlas package.
##   Please report the issue at <https://github.com/malaria-atlas-project/malariaAtlas/issues>.
## This warning is displayed once every 8 hours.
## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was generated.
```

```
## Rows: 395
## Columns: 29
## $ dhs_id                    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ site_id                   <int> 8689, 6221, 18093, 6021, 15070, 15795, 7374, 13099, 9849, 11961, 21475, 11572, 15943, 7930, 13748, 16323, 19003, 10839, 2790, 15260…
## $ site_name                 <chr> "Vodivohitra", "Andranomasina", "Ankazobe", "Andasibe", "Ambohimarina", "Antohobe", "Ambohimazava", "Ankeribe", "Alatsinainy", "Sah…
## $ latitude                  <dbl> -16.21700, -18.71700, -18.31600, -19.83400, -18.73400, -19.76990, -25.03230, -18.70100, -18.71920, -19.36667, -19.58300, -17.59400,…
## $ longitude                 <dbl> 49.68300, 47.46600, 47.11800, 47.85000, 47.25200, 46.68700, 46.99600, 47.16600, 47.49050, 48.16667, 47.46600, 46.92600, 46.91600, 4…
## $ rural_urban               <chr> "RURAL", "UNKNOWN", "RURAL", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "UNKNOWN", "RURAL", "UNKN…
## $ country                   <chr> "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Mada…
## $ country_id                <chr> "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG"…
## $ continent_id              <chr> "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "…
## $ month_start               <int> 11, 1, 11, 3, 1, 7, 4, 1, 1, 2, 7, 11, 4, 7, 11, 4, 9, 7, 7, 3, 7, 7, 7, 11, 3, 4, 6, 3, 11, 11, 7, 7, 7, 7, 4, 11, 11, 11, 1, 11, …
## $ year_start                <int> 1989, 1987, 1989, 1987, 1987, 1995, 1986, 1987, 1987, 2003, 1995, 1989, 1986, 1995, 1997, 1986, 1991, 1995, 1995, 2005, 1994, 1987,…
## $ month_end                 <int> 11, 1, 12, 3, 1, 8, 6, 1, 1, 2, 8, 12, 4, 8, 11, 6, 9, 8, 8, 6, 7, 7, 7, 12, 3, 6, 6, 6, 11, 11, 7, 8, 8, 8, 4, 11, 11, 11, 1, 11, …
## $ year_end                  <int> 1989, 1987, 1989, 1987, 1987, 1995, 1986, 1987, 1987, 2003, 1995, 1989, 1986, 1995, 1997, 1986, 1991, 1995, 1995, 2005, 1994, 1987,…
## $ lower_age                 <dbl> 5, 0, 5, 0, 0, 2, 7, 0, 0, 0, 2, 5, 6, 2, 2, 7, 0, 2, 2, 0, 2, 0, 0, 5, 0, 7, 0, 0, 6, 5, 0, 2, 2, 2, 13, 2, 2, 6, 0, 2, 2, 0, 2, 0…
## $ upper_age                 <int> 15, 99, 15, 99, 99, 9, 22, 99, 99, 99, 9, 15, 12, 9, 9, 22, 99, 9, 9, 5, 9, 99, 99, 15, 99, 22, 99, 5, 12, 15, 99, 9, 9, 9, 56, 9, …
## $ examined                  <int> 165, 50, 258, 246, 50, 50, 119, 50, 50, 210, 50, 340, 20, 50, 61, 156, 104, 50, 50, 147, 147, 944, 541, 92, 115, 67, 123, 60, 202, …
## $ positive                  <dbl> 144.0, 7.5, 139.0, 126.0, 2.5, 6.0, 37.0, 13.5, 4.5, 34.0, 11.5, 255.0, 8.0, 7.0, 3.0, 97.0, 24.0, 33.0, 0.0, 70.0, 72.0, 137.0, 23…
## $ pr                        <dbl> 0.87272727, 0.15000000, 0.53875969, 0.51219512, 0.05000000, 0.12000000, 0.31092437, 0.27000000, 0.09000000, 0.16190476, 0.23000000,…
## $ species                   <chr> "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falcipar…
## $ method                    <chr> "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Micr…
## $ rdt_type                  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ pcr_type                  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ malaria_metrics_available <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,…
## $ location_available        <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,…
## $ permissions_info          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ citation1                 <chr> "Lepers, J.P. (1989). <i>Rapport sur la situation du paludisme dans la région de Mananara Nord.</i> . Antananarivo. Institut Pasteu…
## $ citation2                 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ citation3                 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ geometry                  <POINT [°]> POINT (49.683 -16.217), POINT (47.466 -18.717), POINT (47.118 -18.316), POINT (47.85 -19.834), POINT (47.252 -18.734), POINT …
```


```r
Africa_pvpr_data <- getPR(continent = "Africa", species = "Pv")
```

```
## Error in `[.data.frame`(available_countries_pr, , location_cql_col): undefined columns selected
```

```
## Error in tibble::glimpse(Africa_pvpr_data): object 'Africa_pvpr_data' not found
```


```r
Extent_pfpr_data <- getPR(extent = rbind(c(-2.460181, 13.581921), c(-3.867188, 34.277344)), species = "Pf")
```

```
## Rows: 2,174
## Columns: 29
## $ dhs_id                    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ site_id                   <int> 2247, 3638, 13900, 16864, 16833, 16907, 13201, 13431, 13924, 13197, 13124, 13101, 13122, 13193, 13895, 13096, 21565, 9668, 15368, 1…
## $ site_name                 <chr> "Kuiti", "Basare Section Kpandai", "Akarana", "GS Kuke Mbomo", "Nyankpala", "Kumasi (Bantama)", "Limbe", "Prampram", "Igbanda", "Ny…
## $ latitude                  <dbl> 12.44770, 8.47000, 15.93300, 4.45490, 9.40630, 6.70000, 4.01500, 5.70400, 7.29000, 2.81000, 12.31300, 12.18330, 12.57000, 2.66400, …
## $ longitude                 <dbl> -1.30920, -0.01000, 5.56800, 9.24630, -0.99000, -1.63400, 9.19300, 0.10100, 3.82000, 10.11800, -1.14300, -1.38330, -1.34000, 12.668…
## $ rural_urban               <chr> "RURAL", "RURAL", "RURAL", "UNKNOWN", "RURAL", "URBAN", "URBAN", "RURAL", "RURAL", "RURAL", "RURAL", "RURAL", "RURAL", "URBAN", "RU…
## $ country                   <chr> "Burkina Faso", "Ghana", "Niger", "Cameroon", "Ghana", "Ghana", "Cameroon", "Ghana", "Nigeria", "Cameroon", "Burkina Faso", "Burkin…
## $ country_id                <chr> "BFA", "GHA", "NER", "CMR", "GHA", "GHA", "CMR", "GHA", "NGA", "CMR", "BFA", "BFA", "BFA", "CMR", "NER", "BEN", "CMR", "NGA", "CMR"…
## $ continent_id              <chr> "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "Africa", "…
## $ month_start               <int> 6, 3, 9, 10, 2, 10, 8, 7, 6, 3, 10, 7, 11, 3, 9, 7, 10, 7, 10, 9, 10, 3, 8, 2, 10, 2, 6, 11, 5, 1, 3, 5, 10, 4, 2, 3, 5, 10, 2, 8, …
## $ year_start                <int> 1985, 2002, 1992, 1998, 2002, 2002, 2001, 1993, 2004, 1989, 2002, 1987, 1992, 1988, 1992, 1987, 1998, 2005, 1998, 2003, 2002, 1986,…
## $ month_end                 <int> 6, 3, 9, 1, 2, 2, 8, 7, 6, 3, 11, 7, 11, 3, 9, 7, 1, 12, 1, 12, 1, 4, 9, 2, 2, 2, 6, 11, 5, 1, 3, 5, 1, 5, 2, 3, 6, 10, 2, 9, 5, 4,…
## $ year_end                  <int> 1985, 2002, 1992, 1999, 2002, 2003, 2001, 1993, 2004, 1989, 2002, 1987, 1992, 1988, 1992, 1987, 1999, 2005, 1999, 2003, 2003, 1986,…
## $ lower_age                 <dbl> 0.5, 0.5, 0.0, 5.0, 0.5, 0.5, 0.0, 6.0, 0.0, 4.0, 0.0, 1.0, 2.0, 0.0, 0.0, 1.0, 5.0, 4.0, 5.0, 2.0, 0.0, 0.0, 5.0, 4.0, 0.5, 0.5, 0…
## $ upper_age                 <int> 9, 9, 9, 16, 9, 5, 99, 15, 8, 13, 9, 5, 8, 15, 9, 12, 16, 15, 16, 9, 4, 10, 70, 13, 5, 9, 65, 10, 9, 9, 9, 13, 16, 4, 14, 9, 5, 99,…
## $ examined                  <int> 143, 70, 62, 30, 69, 189, 208, 354, 412, 284, 58, 119, 210, 310, 91, 770, 50, 216, 28, 102, 219, 47, 100, 94, 145, 71, 885, 208, 34…
## $ positive                  <dbl> 59.00, 39.00, 41.00, 17.00, 34.00, 8.00, 47.00, 115.00, 340.00, 219.00, 51.00, 77.00, 191.00, 169.00, 59.00, 155.00, 22.00, 65.00, …
## $ pr                        <dbl> 0.41258741, 0.55714286, 0.66129032, 0.56666667, 0.49275362, 0.04232804, 0.22596154, 0.32485876, 0.82524272, 0.77112676, 0.87931034,…
## $ species                   <chr> "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falciparum", "P. falcipar…
## $ method                    <chr> "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Microscopy", "Micr…
## $ rdt_type                  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ pcr_type                  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ malaria_metrics_available <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,…
## $ location_available        <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,…
## $ permissions_info          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ citation1                 <chr> "Esposito, F., Lombardi, S., Modiano, D., Zavala, F., Reeme, J., Lamizana, L., Coluzzi, M. and Nussenzweig, R.S. (1988).  <b>Preval…
## $ citation2                 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ citation3                 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,…
## $ geometry                  <POINT [°]> POINT (-1.3092 12.4477), POINT (-0.01 8.47), POINT (5.568 15.933), POINT (9.2463 4.4549), POINT (-0.99 9.4063), POINT (-1.634…
```

You can also pass this function a dataset version. If you don't it will default to using the most recent version.


```r
MDG_pr_data_202206 <- getPR(country = "Madagascar", species = "both", version = "202206")
```

`autoplot.pr.points` configures autoplot method to enable quick mapping of the locations of downloaded PR points. 


```r
autoplot(MDG_pr_data)
```

![plot of chunk unnamed-chunk-23](man/figures/unnamed-chunk-23-1.png)

A version without facetting is also available.

```r
autoplot(MDG_pr_data,
         facet = FALSE)
```

![plot of chunk unnamed-chunk-24](man/figures/unnamed-chunk-24-1.png)

### Vector Survey Points
`getVecOcc()` downloads all publicly available Vector survey points for a specified location (country, ISO, continent or extent) and species (options for which can be found with `listSpecies`) and returns this as a dataframe with the following format: 


```r
MMR_vec_data <- getVecOcc(country = "Myanmar")
```

```
## Rows: 2,866
## Columns: 25
## $ id             <int> 1945, 1946, 1951, 1952, 790, 781, 772, 791, 773, 783, 774, 776, 777, 792, 778, 779, 780, 1953, 784, 785, 786, 788, 789, 793, 795, 796, 797, 79…
## $ site_id        <int> 30243, 30243, 30243, 30243, 1000000072, 1000000071, 1000000071, 1000000072, 1000000071, 1000000071, 1000000071, 1000000071, 1000000071, 100000…
## $ latitude       <dbl> 16.2570, 16.2570, 16.2570, 16.2570, 17.3500, 17.3800, 17.3800, 17.3500, 17.3800, 17.3800, 17.3800, 17.3800, 17.3800, 17.3500, 17.3800, 17.3800…
## $ longitude      <dbl> 97.7250, 97.7250, 97.7250, 97.7250, 96.0410, 96.0370, 96.0370, 96.0410, 96.0370, 96.0370, 96.0370, 96.0370, 96.0370, 96.0410, 96.0370, 96.0370…
## $ country        <chr> "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar",…
## $ country_id     <chr> "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "M…
## $ continent_id   <chr> "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia"…
## $ month_start    <int> 2, 3, 8, 9, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, …
## $ year_start     <int> 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998…
## $ month_end      <int> 2, 3, 8, 9, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 10, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, …
## $ year_end       <int> 1998, 1998, 1998, 1998, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 1998, 2000, 2000, 2000, 2000, 2000, 2000…
## $ anopheline_id  <int> 17, 17, 17, 17, 50, 49, 17, 51, 11, 4, 15, 1, 35, 30, 50, 51, 30, 17, 17, 11, 15, 1, 35, 49, 4, 17, 11, 15, 1, 35, 51, 30, 49, 4, 17, 11, 15, …
## $ species        <chr> "Anopheles dirus species complex", "Anopheles dirus species complex", "Anopheles dirus species complex", "Anopheles dirus species complex", "A…
## $ species_plain  <chr> "Anopheles dirus", "Anopheles dirus", "Anopheles dirus", "Anopheles dirus", "Anopheles stephensi", "Anopheles sinensis", "Anopheles dirus", "A…
## $ id_method1     <chr> "unknown", "unknown", "unknown", "unknown", "morphology", "morphology", "morphology", "morphology", "morphology", "morphology", "morphology", …
## $ id_method2     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
## $ sample_method1 <chr> "man biting", "man biting", "man biting", "man biting", "man biting indoors", "man biting indoors", "man biting indoors", "man biting indoors"…
## $ sample_method2 <chr> "animal baited net trap", "animal baited net trap", "animal baited net trap", "animal baited net trap", "man biting outdoors", "man biting out…
## $ sample_method3 <chr> NA, NA, NA, NA, "animal baited net trap", "animal baited net trap", "animal baited net trap", "animal baited net trap", "animal baited net tra…
## $ sample_method4 <chr> NA, NA, NA, NA, "house resting inside", "house resting inside", "house resting inside", "house resting inside", "house resting inside", "house…
## $ assi           <chr> "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""…
## $ citation       <chr> "Oo, T.T., Storch, V. and Becker, N. (2003).  <b><i>Anopheles</i> <i>dirus</i> and its role in malaria transmission in Myanmar.</b> <i>Journal…
## $ time_start     <date> 1998-02-01, 1998-03-01, 1998-08-01, 1998-09-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-0…
## $ time_end       <date> 1998-02-01, 1998-03-01, 1998-08-01, 1998-09-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-0…
## $ geometry       <POINT [°]> POINT (97.725 16.257), POINT (97.725 16.257), POINT (97.725 16.257), POINT (97.725 16.257), POINT (96.041 17.35), POINT (96.037 17.38), …
```

You can also pass this function a dataset version. If you don't it will default to using the most recent version.


```r
MMR_vec_data_201201 <- getVecOcc(country = "Myanmar", version = "201201")
```

```
## Rows: 2,866
## Columns: 25
## $ id             <int> 1945, 1946, 1951, 1952, 790, 781, 772, 791, 773, 783, 774, 776, 777, 792, 778, 779, 780, 1953, 784, 785, 786, 788, 789, 793, 795, 796, 797, 79…
## $ site_id        <int> 30243, 30243, 30243, 30243, 1000000072, 1000000071, 1000000071, 1000000072, 1000000071, 1000000071, 1000000071, 1000000071, 1000000071, 100000…
## $ latitude       <dbl> 16.2570, 16.2570, 16.2570, 16.2570, 17.3500, 17.3800, 17.3800, 17.3500, 17.3800, 17.3800, 17.3800, 17.3800, 17.3800, 17.3500, 17.3800, 17.3800…
## $ longitude      <dbl> 97.7250, 97.7250, 97.7250, 97.7250, 96.0410, 96.0370, 96.0370, 96.0410, 96.0370, 96.0370, 96.0370, 96.0370, 96.0370, 96.0410, 96.0370, 96.0370…
## $ country        <chr> "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar", "Myanmar",…
## $ country_id     <chr> "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "MMR", "M…
## $ continent_id   <chr> "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia", "Asia"…
## $ month_start    <int> 2, 3, 8, 9, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, …
## $ year_start     <int> 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998, 1998…
## $ month_end      <int> 2, 3, 8, 9, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 10, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, …
## $ year_end       <int> 1998, 1998, 1998, 1998, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 2000, 1998, 2000, 2000, 2000, 2000, 2000, 2000…
## $ anopheline_id  <int> 17, 17, 17, 17, 50, 49, 17, 51, 11, 4, 15, 1, 35, 30, 50, 51, 30, 17, 17, 11, 15, 1, 35, 49, 4, 17, 11, 15, 1, 35, 51, 30, 49, 4, 17, 11, 15, …
## $ species        <chr> "Anopheles dirus species complex", "Anopheles dirus species complex", "Anopheles dirus species complex", "Anopheles dirus species complex", "A…
## $ species_plain  <chr> "Anopheles dirus", "Anopheles dirus", "Anopheles dirus", "Anopheles dirus", "Anopheles stephensi", "Anopheles sinensis", "Anopheles dirus", "A…
## $ id_method1     <chr> "unknown", "unknown", "unknown", "unknown", "morphology", "morphology", "morphology", "morphology", "morphology", "morphology", "morphology", …
## $ id_method2     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
## $ sample_method1 <chr> "man biting", "man biting", "man biting", "man biting", "man biting indoors", "man biting indoors", "man biting indoors", "man biting indoors"…
## $ sample_method2 <chr> "animal baited net trap", "animal baited net trap", "animal baited net trap", "animal baited net trap", "man biting outdoors", "man biting out…
## $ sample_method3 <chr> NA, NA, NA, NA, "animal baited net trap", "animal baited net trap", "animal baited net trap", "animal baited net trap", "animal baited net tra…
## $ sample_method4 <chr> NA, NA, NA, NA, "house resting inside", "house resting inside", "house resting inside", "house resting inside", "house resting inside", "house…
## $ assi           <chr> "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""…
## $ citation       <chr> "Oo, T.T., Storch, V. and Becker, N. (2003).  <b><i>Anopheles</i> <i>dirus</i> and its role in malaria transmission in Myanmar.</b> <i>Journal…
## $ time_start     <date> 1998-02-01, 1998-03-01, 1998-08-01, 1998-09-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-01, 1998-05-0…
## $ time_end       <date> 1998-02-01, 1998-03-01, 1998-08-01, 1998-09-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-01, 2000-03-0…
## $ geometry       <POINT [°]> POINT (97.725 16.257), POINT (97.725 16.257), POINT (97.725 16.257), POINT (97.725 16.257), POINT (96.041 17.35), POINT (96.037 17.38), …
```

`autoplot.vector.points` configures autoplot method to enable quick mapping of the locations of downloaded vector points. 


```r
autoplot(MMR_vec_data)
```

![plot of chunk unnamed-chunk-29](man/figures/unnamed-chunk-29-1.png)

N.B. Facet-wrapped option is also available for species stratification. 

```r
autoplot(MMR_vec_data,
         facet = TRUE)
```

![plot of chunk unnamed-chunk-30](man/figures/unnamed-chunk-30-1.png)

### Shapefiles
`getShp()` downloads a shapefile for a specified country (or countries) and returns this as a simple feature object.


```r
MDG_shp <- getShp(ISO = "MDG", admin_level = c("admin0", "admin1"))
```

```
## Rows: 23
## Columns: 17
## $ iso           <chr> "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MDG", "MD…
## $ admn_level    <int> 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
## $ name_0        <chr> "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Madagascar", "Ma…
## $ id_0          <int> 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 10000910, 100…
## $ type_0        <chr> "Country", "Country", "Country", "Country", "Country", "Country", "Country", "Country", "Country", "Country", "Country", "Country", "Country", …
## $ name_1        <chr> NA, "Analamanga", "Analanjirofo", "Androy", "Anosy", "Atsimo Andrefana", "Atsimo Atsinanana", "Atsinanana", "Betsiboka", "Boeny", "Bongolava", …
## $ id_1          <int> NA, 10022983, 10022999, 10023001, 10023002, 10023003, 10022990, 10023000, 10022994, 10022995, 10022984, 10022998, 10022989, 10022987, 10022991,…
## $ type_1        <chr> NA, "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region", "Region",…
## $ name_2        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
## $ id_2          <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
## $ type_2        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
## $ name_3        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
## $ id_3          <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
## $ type_3        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
## $ source        <chr> "Madagascar NMCP 2016", "Madagascar NMCP 2016", "Madagascar NMCP 2016", "Madagascar NMCP 2016", "Madagascar NMCP 2016", "Madagascar NMCP 2016",…
## $ country_level <chr> "MDG_0", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1", "MDG_1",…
## $ geometry      <MULTIPOLYGON [°]> MULTIPOLYGON (((44.2278 -25..., MULTIPOLYGON (((46.7425 -17..., MULTIPOLYGON (((49.8084 -17..., MULTIPOLYGON (((45.2509 -23..., MULTIPOLYGON ((…
```

`autoplot.sf` configures autoplot method to enable quick mapping of downloaded shapefiles.


```r
autoplot(MDG_shp)
```

![plot of chunk unnamed-chunk-33](man/figures/unnamed-chunk-33-1.png)

N.B. Facet-wrapped option is also available for species stratification. 


```r
autoplot(MDG_shp,
         facet = TRUE,
         map_title = "Example of facetted shapefiles.")
```

![plot of chunk unnamed-chunk-34](man/figures/unnamed-chunk-34-1.png)

### Modelled Rasters 

`getRaster()`downloads publicly available MAP rasters for a specific dataset_id & year, clipped to a given bounding box or shapefile


```r
MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
MDG_PfPR2_10 <- getRaster(dataset_id = "Explorer__2020_Global_PfPR", shp = MDG_shp, year = 2013)
```

```
## <GMLEnvelope>
## ....|-- lowerCorner: -25.6089 43.1914 "2000-01-01T00:00:00"
## ....|-- upperCorner: -11.9454 50.4838 "2019-01-01T00:00:00"
```


`autoplot.SpatRaster` & `autoplot.SpatRasterCollection` configures autoplot method to enable quick mapping of downloaded rasters.


```r
p <- autoplot(MDG_PfPR2_10, shp_df = MDG_shp)
```

![plot of chunk unnamed-chunk-36](man/figures/unnamed-chunk-36-1.png)


### Combined visualisation 

By using the above tools along with ggplot, simple comparison figures can be easily produced. 


```r
MDG_shp <- getShp(ISO = "MDG", admin_level = "admin0")
MDG_PfPR2_10 <- getRaster(dataset_id = "Explorer__2020_Global_PfPR", shp = MDG_shp, year = 2013)
```

```
## <GMLEnvelope>
## ....|-- lowerCorner: -25.6089 43.1914 "2000-01-01T00:00:00"
## ....|-- upperCorner: -11.9454 50.4838 "2019-01-01T00:00:00"
```

```r
p <- autoplot(MDG_PfPR2_10, shp_df = MDG_shp, printed = FALSE)

pr <- getPR(country = c("Madagascar"), species = "Pf")
p[[1]] +
geom_point(data = pr[pr$year_start==2013,], aes(longitude, latitude, fill = positive / examined, size = examined), shape = 21)+
scale_size_continuous(name = "Survey Size")+
 scale_fill_distiller(name = "PfPR", palette = "RdYlBu")+
 ggtitle("Raw PfPR Survey points\n + Modelled PfPR 2-10 in Madagascar in 2013")
```

![plot of chunk unnamed-chunk-37](man/figures/unnamed-chunk-37-1.png)

Similarly for vector survey data


```r
MMR_shp <- getShp(ISO = "MMR", admin_level = "admin0")
MMR_An_dirus <- getRaster(dataset_id = "Explorer:2010_Anopheles_dirus_complex", shp = MMR_shp)
```

```
## Error in getRaster(dataset_id = "Explorer:2010_Anopheles_dirus_complex", : All value(s) provided for dataset_id are not valid. All values must be from dataset_id column of listRasters()
```

```r
p <- autoplot(MMR_An_dirus, shp_df = MMR_shp, printed = FALSE)
```

```
## Error in autoplot(MMR_An_dirus, shp_df = MMR_shp, printed = FALSE): object 'MMR_An_dirus' not found
```

```r
vec <- getVecOcc(country = c("Myanmar"), species = "Anopheles dirus")
p[[1]] +
geom_point(data = vec, aes(longitude, latitude, colour = species))+
  scale_colour_manual(values = "black", name = "Vector survey locations")+
 scale_fill_distiller(name = "Predicted distribution of An. dirus complex", palette = "PuBuGn", direction = 1)+
 ggtitle("Vector Survey points\n + The predicted distribution of An. dirus complex")
```

![plot of chunk unnamed-chunk-38](man/figures/unnamed-chunk-38-1.png)


## Installation

### Latest stable version from CRAN

Just install using `install.packages("malariaAtlas")` or using the package manager in RStudio.

### Latest version from github

While this version is not as well-tested, it may include additional bugfixes not in the stable CRAN version. Install the `devtools` package and then install using `devtools::install_github('malaria-atlas-project/malariaAtlas')`

## Changes

### 1.2.0

- Removed `rgdal`, `sp`, `raster` packages dependencies and added `terra`, `sf`, `tidyterra`, `lifecycle`
- As a result `getShp` will now return `sf` objects
- Similarly, `getRaster` returns `SpatRaster` or `SpatRasterCollection`
- Some functions have been deprecated. They will still run in this version, with a warning. Please remove them from your code, they will be completely removed in the future.
  - Deprecated `as.MAPraster`, `as.MAPshp`. They are no longer required for working with `autoplot`
  - Deprecated `autoplot_MAPraster`. Use `autoplot` directly with the result of `getRaster`
