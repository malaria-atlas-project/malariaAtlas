.onLoad <- function(libname, pkgname) {
 assign(x = ".malariaAtlasHidden", value = new.env(), pos = parent.env(environment()))
  
  workspaces <- c("Malaria", "Interventions", "Blood_Disorders", "Accessibility", "Vector_Occurrence", "Explorer", "Admin_Units")
  .malariaAtlasHidden$workspaces <- workspaces
  .malariaAtlasHidden$geoserver <- "https://data-dev.malariaatlas.org/geoserver/"

  options("workspaces" = workspaces)
  wms_clients_by_workspace <- list()
  for (workspace in workspaces) {
    wms_client <- ows4R::WMSClient$new(paste0("https://data-dev.malariaatlas.org/geoserver/", workspace, "/ows"), "1.3.0")
    wms_clients_by_workspace[[workspace]] <- wms_client
  }
  options("malariaatlas.workspaces" = workspaces)
  options("malariaatlas.wms_clients" = wms_clients_by_workspace)
}
