#' Recursive Feature Engineering SelectoR
#' @description This function removes the redundant features in a model and automatically selects the best combination of features to remove.
#' This utilises, by default, the random forest mean decrease in accuracy methods, from the caret package, reference Kuhn (2021).
#' This function is a wrapper for the \strong{rfe()} function
#' @param df data frame to fit the recursive feature engineering algorithm to
#' @param x_cols the independent variables to be used for the recursive feature engineering algorithm
#' @param y_cols the dependent variables to be used in the prediction
#' @param method \strong{\emph{Default = "cv"}}- cross validation method for resampling, other options "repeatedcv"
#' @param kfolds \emph{Default = 10} - the number of k folds - train / test splits to compute when resampling
#' @param sizes the sizes of the search boundary for the search
#' @param alter_df \emph{Default = TRUE} - will remove the redundant features, due to having a lesser affect on the mean decrease in accuracy, or other measures.
#' @param eval_funcs \emph{Default = rfFuncs} (Random Forest Mean Decrease Accuracy method). Other options: rfe, lmFuncs, rfFuncs, treebagFuncs, nbFuncs, pickSizeBest, pickSizeTolerance.
#' @param ... Function forwarding to main `caret::rfe() function` to pass in additional parameters native to caret
#' @return A list containing the outputs highlighted hereunder:
#' \itemize{
#' \item{\strong{"rfe_model_fit_results"}}{ a list of the model fit results. Including the optimal features}
#' \item{\strong{"rfe_reduced_features"}}{ a data.frame object with the reduced variables and data}
#' \item{\strong{"rfe_original_data"}}{ a data.frame object with the original data passed for manual exclusion based on fit outputs}
#' \item{\strong{"rfe_reduced_data"}}{output of setting the alter_df=TRUE will remove the features / IVs from the data.frame}
#' }
#' @import caret stats
#' @importFrom dplyr tibble
#' @export
#' @encoding UTF-8
#' @details
#' With the df_alter set to TRUE the recursive feature algorithm chosen will automatically remove the features from the returned tibble embedded in the list.
#' @references Kuhn (2021) Recursive Feature Elimination. \url{https://topepo.github.io/caret/recursive-feature-elimination.html}
#' @examples
#' \dontrun{
#'
#'library(caret)
#'library(tibble)
#'library(FeatureTerminatoR)
#'library(dplyr)
#'df <- iris
#'# Passing in the indexes as slices x values located in index 1:4 and y value in location 5
#'rfe_fit <- rfeTerminator(df, x_cols= 1:4, y_cols=5, alter_df = TRUE, eval_funcs = rfFuncs)
#'# Passing by column name
#'rfe_fit_col_name <- rfeTerminator(df, x_cols=1:4, y_cols="Species", alter_df=TRUE)
#'# Further example
#'ref_x_col_name <- rfeTerminator(df,
#'                                x_cols=c("Sepal.Length", "Sepal.Width",
#'                                         "Petal.Length", "Petal.Width"),
#'                                y_cols = "Species")
#'#Explore the optimal model results
#'print(rfe_fit$rfe_model_fit_results)
#'# Explore the optimal variables selected
#'print(rfe_fit$rfe_model_fit_results$optVariables)
#'# Explore the original data passed to the frame
#'print(head(rfe_fit$rfe_original_data))
#'# Explore the data adapted with the less important features removed
#'print(head(rfe_fit$rfe_reduced_data))
#'}


rfeTerminator <- function(df, x_cols, y_cols, method="cv", kfolds=10,
                          sizes = c(1:100), alter_df = TRUE, eval_funcs=rfFuncs, ...){

  if (!is.data.frame(df) || df == ''){
    stop("The input of df needs to be a data.frame object.")
  }

  if(x_cols == "" || length(x_cols)==0){
    stop("Please enter either the index location of the independent variables to use.\nOr the column names passed as a vector()")
  }

  if(y_cols == "" || length(y_cols)==0){
    stop("Please enter either the index location of the dependent variables to use.\nOr the column names passed as a vector()")
  }

  ctrl <- caret::rfeControl(functions=eval_funcs,
                            method=method, number=kfolds)
  y_df <- df[y_cols]
  results <- caret::rfe(df[,x_cols], df[,y_cols], sizes=c(sizes),
                        rfeControl = ctrl, ...)
  original <- df

  if(alter_df==TRUE){
    message("[INFO] Removing features as a result of recursive feature enginnering. Expose rfe_reduced_data from returned list using $ selectors.")
    transformed <- df[, results$optVariables]
    merged <- cbind(transformed, y_df)
    colnames(merged) <- c(results$optVariables, names(y_df))
    results_list <- list("rfe_model_fit_results"=results,
                         "rfe_reduced_features"=transformed,
                         "rfe_original_data"=original,
                         "rfe_reduced_data"=merged
                         )
    message(paste0("[IVS SELECTED] Optimal variables are: ", as.character(results$optVariables), "\n"))
    return(results_list)

  } else if(alter_df==FALSE){
    message("[INFO] Returning initial recursive feature engineering results and original data as a list()")
    results_list <- list("rfe_model_fit_results"=results,
                         "rfe_original_data"=tibble(original)
                         )
    return(results_list)

  }

}

