#' Generate psodds ('pdeudo odss') columns for finishing in 1st, 2nd and 3rd. Information about the math used can
#' be found here http://math.stackexchange.com/questions/842604/given-every-horses-probability-of-winning-a-race-what-is-the-probability-that.
#' If the page is gone, try googling 'trifecta bet probability math stackexchange'.
#' The odds provided by the track are not the true probability of each horse winning, and
#' cannot be expected to sum to 1 as true mutually-exclusive, exhaustive probabilities would.  As such, the calculation of the psodds of each
#' horse placing first is the fraction of the given odds divided by the sum of the given odds.  These '1st place psodds'
#' are then used to produce the second and third place psodds according to the method described in the link provided.
#' @param race_df A data.frame of the format specified
#' in the package-wide man page.
#' @return the input data.frame with the added psodds columns.
#' @export
generate_psodds <- function(race_df) {
  race_df <- add_multipliers(race_df)
  race_df <- psodds_first(race_df)
  race_df <- psodds_second(race_df)
  race_df <- psodds_third(race_df)
  race_df
}

#' Generate a column of multipliers from the odds provided by the user in the format
#' specified in the package-wide manfile
add_multipliers <- function(race_df) {
  x2y <- strsplit(race_df[,'Horse_Odds'], ":")
  for (i in 1:length(x2y)) {
    race_df$Multiplier[i] <- (as.numeric(x2y[[i]])[1] / as.numeric(x2y[[i]])[2]) + 1
  }
  race_df
}

#' Generate a column of the odds of each horse winning from the Multiplier column
psodds_first <- function(race_df) {
  race_df$psoddsFirst <- (1/race_df$Multiplier) / (sum(1/race_df$Multiplier))
  race_df
}

#' Generate a column of the odds of each horse coming in second. Same reasoning as
#' psodds_first.
psodds_second <- function(race_df){
  for (i in 1:nrow(race_df)) {
    sum <- 0
    for (j in 1:nrow(race_df)) {
      if(i != j) {
        sum <- sum + race_df$psoddsFirst[j] * (race_df$psoddsFirst[i]/(1 - race_df$psoddsFirst[j]))
      }
    }
    race_df$psoddsSecond[i] <- sum
  }
  race_df
}

#' Generate a column of the odds of each horse coming in third.
psodds_third <- function(race_df) {
  for (i in 1:nrow(race_df)) {
    sum <- 0
    for (j in (1:nrow(race_df))[-i]) {
      for (k in (1:nrow(race_df))[-i]) {
        if (j != k) {
          denom <- (1 - race_df$psoddsFirst[j]) * (1 - race_df$psoddsFirst[j] - race_df$psoddsFirst[k])
          sum <- sum + race_df$psoddsFirst[i] * race_df$psoddsFirst[j] * race_df$psoddsFirst[k] / denom
        }
      }
    }
    race_df$psoddsThird[i] <- sum
  }
  race_df
}