.onLoad <- function(libname, pkgname){
 assign(x = ".MAPdataHidden", value = new.env(), pos = parent.env(environment()))
}
