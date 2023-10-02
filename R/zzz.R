.onLoad <- function(libname, pkgname) {
 assign(x = ".malariaAtlasHidden", value = new.env(), pos = parent.env(environment()))
  
  workspaces <- c("Malaria", "Interventions", "Blood_Disorders", "Accessibility", "Vector_Occurrence", "Explorer", "Admin_Units")
  .malariaAtlasHidden$workspaces <- workspaces
  .malariaAtlasHidden$geoserver <- "https://data.malariaatlas.org/geoserver/"
}
