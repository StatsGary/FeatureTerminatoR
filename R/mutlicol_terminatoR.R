#' Multicollinearity TerminatoR - Feature Selection to remove highly correlated values
#'
#' @param df The data frame to pass with the x and y variables
#' @param x_cols The independent variables we want to analyse for multicollinearity
#' @param y_cols The dependent variables(s) in your predictive model
#' @param alter_df \strong{Default=TRUE} - Determines whether the underlying features are removed from the data frame, with TRUE being the default.
#' @param cor_sig \strong{Default=0.9} - A correlation significance for the cut-off in inter-feature correlation
#' @description This function looks at highly correlated features and allows for a correlation cutoff to be set.
#' Outputs from this function allow for correlations and covariance matrices to be created, alongside visuals and the
#' ability to remove highly correlated features from your statistic pipeline.
#' @return A list containing the outputs highlighted hereunder:
#' \itemize{det
#' \item{\strong{"rfe_model_fit_results"}}{ a list of the model fit results. Including the optimal features}
#' \item{\strong{"rfe_reduced_features"}}{ a data.frame object with the reduced variables and data}
#' \item{\strong{"rfe_original_data"}}{ a data.frame object with the original data passed for manual exclusion based on fit outputs}
#' \item{\strong{"rfe_reduced_data"}}{output of setting the alter_df=TRUE will remove the features / IVs from the data.frame}
#' }
#' @import caret ggplot2
#' @importFrom dplyr tibble
#' @importFrom stats cor quantile cov
#' @export
#' @examples
#' \dontrun{
#'library(caret)
#'library(FeatureTerminatoR)
#'library(tibble)
#'library(dplyr)
#'df <- iris
#'results <- mutlicol_terminator(df, 1:4,5, cor_sig = 0.90, alter_df = TRUE)
# print(results) #Prints out the full list of results
#'}

mutlicol_terminator <- function(df, x_cols, y_cols, alter_df = TRUE, cor_sig=0.9){

  #Initialise the values
  x_vals <- df[,x_cols]
  y_vals <- df[,y_cols]

  # Create correlation object
  corr <- cor(df[, x_cols])
  cov <- cov(df[,x_cols])

  # Get stats
  vec_correlation <- as.vector(corr)
  vec_correlation <- vec_correlation[vec_correlation!=1]
  quant <- quantile(vec_correlation, seq(from=0.05,to=1, by=0.05))
  # GGplot this up
  gg_len <- seq(1,length(quant))
  resultsdf <- data.frame(quantiles=quant, index=gg_len)
  resultsdf$quantile_range <- rownames(resultsdf)
  rownames(resultsdf) <- NULL
  resultsdf$corr_cut_off <- ifelse(resultsdf$quantiles > cor_sig, 1,
                                            ifelse(resultsdf$quantiles < -cor_sig,
                                                   1,0))
  # Create bar chart element
  plot_bar <- ggplot(data=resultsdf, aes(x=factor(quantile_range),
                                     y=quantiles)) +
    geom_bar(stat="identity", aes(x=quantile_range, fill=corr_cut_off))+
    scale_x_discrete(limits=c("5%", "10%", "15%",
                              "20%", "25%", "30%",
                              "35%", "40%", "45%",
                              "50%", "55%", "60%",
                              "65%", "70%", "75%",
                              "80%", "85%", "90%",
                              "95%", "100%")) +
    xlab("Quantile Proportion (%)") +
    ylab("Correlation Raw Scores") + ylim(-1,1)+ coord_flip()

  # Find correlation
  high_corr <- caret::findCorrelation(corr, cutoff = cor_sig)



  # Do if check here
  if(alter_df==TRUE){
    reduced_df <- df[, -high_corr]
    message("[INFO] Removing features as a result of highly correlated value cut off.")
    results_list <- list(
      "corr_matrix" = corr,
      "cov_matrix"= cov,
      "corr_vector"=vec_correlation,
      "corr_quantile"=quant,
      "corr_quant_chart"=plot_bar,
      "feature_removed_df"=tibble(reduced_df),
      "original_df"=tibble(df))
    return(results_list)
  } else if(alter_df==FALSE){
    message("[INFO] You opted to review features before feature removal.\nObserve correlation quantiles and choose your ideal correlation cut-off.")
      results_list <- list(
        "corr_matrix" = corr,
        "cov_matrix"= cov,
        "corr_vector"=vec_correlation,
        "corr_quantile"=quant,
        "corr_quant_chart"=plot_bar,
        "original_df"=df)
      return(results_list)

  }

}











