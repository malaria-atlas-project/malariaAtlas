# Code by Nick Golding and Dave Smith.

# Function file for Dave's modified Pull & Grab model for age standardisation


#' convert prevalences from one age range to another
#'
#' @references Smith, D. L. et al. Standardizing estimates of the
#'   Plasmodium falciparum parasite rate. Malaria Journal 6, 131 (2007).
#'
#'   Gething, Peter W., et al. "A long neglected world malaria map:
#'   Plasmodium vivax endemicity in 2010." PLoS neglected tropical
#'   diseases 6.9 (2012): e1814.
#'
#'
#'   Code written by Nick Golding and Dave Smith
#'
#' @param prevalence Vector of prevalence values
#' @param age_min_in Vector of minimum ages sampled
#' @param age_max_in Vector maximum ages sampled.
#' @param age_min_out Length 1 numeric or vector of same length as prevalence given the required age range upper bound
#' @param age_max_out Length 1 numeric or vector of same length as prevalence given the required age range lower bound
#' @param parameters Specifies the set of parameters to use in the
#'   model. This can either be "Pf_Smith2007" to use the parameters
#'   for *Plasmodium falciparum* defined in that paper,
#'   "Pv_Gething2012" for the *P. vivax* parameters used in that paper,
#'    or a user-specified vector givng the values of parameters `b`,
#'     `s`, `c` and `alpha`, in that order. If specified,
#' @param sample_weights Must be a vector of length 85 giving the
#'     sample weights for each age category (the proportion of the
#'     population in that age category) . If `NULL`, The sample
#'     weights used in Smith et al. 2007 are used.
#' @export
#' @examples
#' # Convert from prevalence 2 to 5 to prevalence 2 to 10
#' pr2_10 <- convertPrevalence(0.1, 2, 5, 2, 10)
#'
#' # Convert many surveys all to 2 to 10.
#' pr <- runif(20, 0.1, 0.15)
#' min_in <- sample(1:5, 20, replace = TRUE)
#' max_in <- rep(8, 20)
#' min_out <- rep(2, 20)
#' max_out <- rep(10, 20)
#' pr_standardised <- convertPrevalence(pr, min_in, max_in,
#'                                      min_out, max_out)
#'
#' plot(pr_standardised, pr)

convertPrevalence <- function (prevalence,
                               age_min_in,
                               age_max_in,
                               age_min_out = rep(2, length(prevalence)),
                               age_max_out = rep(9, length(prevalence)),
                               parameters = "Pf_Smith2007",
                               sample_weights = NULL) {

  # get the correct parameters (either the Pf, Pv or user-specified parameters)

  # if it's one of the existing parameter sets
  if (class(parameters) == "character" &&
      length(parameters) == 1 &&
      parameters %in% c("Pf_Smith2007",
                        "Pv_Gething2012")) {

    # get the correct set
    parameters <- switch(parameters,
                         Pf_Smith2007 = c(b = 1.807675,
                                          s = 0.446326,
                                          c = 0.070376,
                                          alpha = 9.422033),
                         Pv_Gething2012 = c(b = 0.947,
                                            s = 0.773,
                                            c = 0.208,
                                            alpha = 6.66))

    # otherwise check it's a length 4 numeric, user-specified set of parameters
  } else if (class(parameters) != 'numeric' ||
             length(parameters) != 4) {

    # and throw an error if not
    stop('The argument "parameters" must be one of either "Pf_Smith2007",\
         "Pv_Gething2012" or a numeric vector of length 4 giving the values of parameters\
         b, s, c and alpha (in that order!)')

  }

  # if sample weights aren't specified, use Dave's
  if (is.null(sample_weights)) {

    sample_weights <- c(0.03916203, 0.04464933, 0.0464907, 0.04703639,
                        0.04468962, 0.04430289, 0.04088593, 0.04048751,
                        0.0385978, 0.03586601, 0.03665516, 0.02850493,
                        0.03038655, 0.02493861, 0.02169105, 0.01506840,
                        0.01481482, 0.01519726, 0.01474023, 0.01553814,
                        0.01193805, 0.01220409, 0.01202119, 0.01202534,
                        0.01283806, 0.01083728, 0.01095784, 0.01092874,
                        0.01067932, 0.01137331, 0.01035001, 0.01035001,
                        0.01035001, 0.01035001, 0.01035001, 0.008342426,
                        0.008342426, 0.008342426, 0.008342426, 0.008342426,
                        0.00660059, 0.00660059, 0.00660059, 0.00660059,
                        0.00660059, 0.004597861, 0.004597861, 0.004597861,
                        0.004597861, 0.004597861, 0.003960774, 0.003960774,
                        0.003960774, 0.003960774, 0.003960774, 0.003045687,
                        0.003045687, 0.003045687, 0.003045687, 0.003045687,
                        0.002761077, 0.002761077, 0.002761077, 0.002761077,
                        0.002761077, 0.001275367, 0.001275367, 0.001275367,
                        0.001275367, 0.001275367, 0.001275367, 0.001275367,
                        0.001275367, 0.001275367, 0.001275367, 0.001275367,
                        0.001275367, 0.001275367, 0.001275367, 0.001275367,
                        0.001275367, 0.001275367, 0.001275367, 0.001275367,
                        0.001275367)

  }

  # how many prevalences are there to do?
  N <- length(prevalence)

  # check the vectors all have the same length
  stopifnot(length(age_min_in) == length(prevalence) )
  stopifnot(length(age_max_in) == length(prevalence))
  stopifnot(length(age_min_out) %in% c(length(prevalence), 1))
  stopifnot(length(age_max_out) %in% c(length(prevalence), 1))

  if(length(age_min_out) == 1) age_min_out <- rep(age_min_out, length(prevalence))
  if(length(age_max_out) == 1) age_max_out <- rep(age_max_out, length(prevalence))
  
  # set ages greater than 85 to 85
  age_min_in <- pmin(age_min_in, 85)
  age_max_in <- pmin(age_max_in, 85)
  age_min_out <- pmin(age_min_out, 85)
  age_max_out <- pmin(age_max_out, 85)

  # check the output age range is sensible
  # (NB incoming age range will be checked in lower-level functions)
  stopifnot(age_min_out >= 0)
  stopifnot(age_max_out >= 0)
  stopifnot(age_min_out < age_max_out)

  # if there are multiple prevalences to convert, recursively call this
  # function, converting them one at a time
  if (N > 1) {

    # assign an empty vector of the correct length
    ans <- vector(mode = 'numeric',
                  length = N)

    # loop through them
    for (i in 1:N) {

      # suppress warnigns so you don't get one for every missing datapoint
      ans[i] <- suppressWarnings(convertPrevalence(prevalence = prevalence[i],
                                                   age_min_in = age_min_in[i],
                                                   age_max_in = age_max_in[i],
                                                   age_min_out = age_min_out[i],
                                                   age_max_out = age_max_out[i],
                                                   parameters = parameters,
                                                   sample_weights = sample_weights))
    }

    # See how many of these are NA
    nmissing <- sum(is.na(ans))

    # if any of these are NA, give a warning
    if (nmissing == 1) {
      warning(paste0('One of the output prevalence estimates is NA,\
                     probably because some input data was missing'))
    } else if (nmissing > 1) {
      warning(paste0(nmissing,
                     ' of the output prevalence estimates are NA,\
                     probably because some input data was missing'))
    }

    # jump out of the function and return this vector
    return (ans)

    } else {

      # otherwise, do just the one prevalence given

      # if any of the arguments are NA, return NA and issue a warning
      if (is.na(prevalence) |
          is.na(age_min_in) |
          is.na(age_max_in) |
          is.na(age_min_out) |
          is.na(age_max_out)) {

        ans <- NA

        warning('One of the input arguments was NA,\
                so the output returned is an NA too')

      } else {

        # otherwise do the calculation

        # find the optimal value of P_prime
        P_prime <- invertPF(prevalence = prevalence,
                            age_min = age_min_in,
                            age_max = age_max_in,
                            sample_weights = sample_weights,
                            parameters = parameters)

        # calculate the expected weighted prevalence in the required age range
        ans <- PFw(P_prime,
                   age_min = age_min_out,
                   age_max = age_max_out,
                   sample_weights = sample_weights,
                   parameters = parameters)

      }

      # return the corrected prevalence

      return (ans)

   }
}



# true prevalence as a function of age
# using Dave's optimal parameters
P <- function(A,
              P_prime,
              b) {

  # check the age is sensible
  stopifnot(all(A >= 0) && all(A <= 85))

  # check P_prime is sensible
  stopifnot(P_prime >= 0 && P_prime <= 1)

  # calculate the expected true prevalence
  ans <- P_prime * (1 - exp(-b * A))

  return (ans)

}

# test sensitivity as a function of age
# using Dave's optimal parameters
F <- function(A,
              s,
              c,
              alpha) {

  # check the age is sensible
  stopifnot(all(A >= 0) && all(A <= 85) )

  # calculate expected true test sensitivity
  ans <- 1 - s * (1 - pmin(1, exp(-c * (A - alpha))))

  return (ans)

}

# observed prevalence as a function of age.
# `P_prime` is a variable which must be specified
# (the true equilibrium prevalence)
PF <- function(A,
               P_prime,
               parameters) {

  # calculate true age-specific prevalence
  P_A <- P(A = A,
           P_prime = P_prime,
           b = parameters[1])

  # calculate age-specific senstivity
  F_A <- F(A = A,
           s = parameters[2],
           c = parameters[3],
           alpha = parameters[4])

  # calculate observed age-specific prevalence
  PF_A <- P_A * F_A

  return (PF_A)

}

# The expected observed prevalence over the age range given by
# `age_min` and `age_max`. `P_prime` must be specified (as in `PF`)
# as must `sample_weights` - a vector of length 85.
PFw <- function(P_prime,
                sample_weights,
                age_min = 1,
                age_max = 85,
                parameters) {

  # check the age range is sensible
  stopifnot(age_min >= 0 && age_min <= 85)
  stopifnot(age_max >= 0 && age_max <= 85)
  stopifnot(age_min <= age_max)

  # get range of ages
  age <- (age_min:(age_max - 1)) + 0.5

  # get expected observed prevalences for age bands
  P <- PF(age,
          P_prime,
          parameters)

  # get indices corresponding to ages
  idx <- ceiling(age)

  # throw an error if the indexing is out
  stopifnot(max(idx) <= length(sample_weights))

  # weight these prevalences
  PF_Aw  <- stats::weighted.mean(P,
                          sample_weights[idx])

  return(PF_Aw)

}

# invert the function `PF` to find the optimal value of P_prime
# `prevalence` is the observed prevalence
# `sample_weights` is a vector of sample weights of length 85
# `age_min` and `age_max` are the age range of the sample
invertPF <- function(prevalence,
                     sample_weights,
                     age_min,
                     age_max,
                     parameters) {

  # define the loss function for `P_prime`
  # squared error of the prediction
  loss <- function(P_prime,
                   sample_weights,
                   age_min,
                   age_max,
                   prevalence,
                   parameters) {

    # get the expected weighted mean for given `P_prime`
    PF_Aw <- PFw(P_prime = P_prime,
                 sample_weights = sample_weights,
                 age_min = age_min,
                 age_max = age_max,
                 parameters = parameters)

    # calculate and return the squared error
    squared_error <- (prevalence - PF_Aw) ^ 2

    return (squared_error)

  }

  # find the optimal value of `P_prime`
  PF_A <- stats::optimize(f = loss,
                   interval = c(0, 1),
                   sample_weights = sample_weights,
                   age_min = age_min,
                   age_max = age_max,
                   prevalence = prevalence,
                   parameters = parameters)$min

  return(PF_A)

}
