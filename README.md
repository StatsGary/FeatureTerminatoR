
# FeatureTerminatoR - a package to perform feature engineering and automated termination of features of no predictive value 

<a href = "https://hutsons-hacks.info/"><img src="man/figures/FeatureTermHex.png" height="175px" width="225px" align="right"/></a>

 <!-- badges: start -->
  [![R-CMD-check](https://github.com/StatsGary/FeatureTerminatoR/workflows/R-CMD-check/badge.svg)](https://github.com/StatsGary/FeatureTerminatoR/actions)
  [![FeatureTerminatoR: Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
  [![CRAN status](https://www.r-pkg.org/badges/version/FeatureTerminatoR)](https://CRAN.R-project.org/package=FeatureTerminatoR)
  [![](https://cranlogs.r-pkg.org/badges/FeatureTerminatoR)](https://cran.r-project.org/package=FeatureTerminatoR)
  ![GitHub last commit](https://img.shields.io/github/last-commit/StatsGary/FeatureTerminatoR)
  [![Launch binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/StatsGary/FeatureTerminatoR/main)
  
  <!-- adges: end -->
  
  
The goal of this package is to provide a common set of functions for working with NHS Data Dictionary look up tables. 

## Installation

Currently, this is making its way on to CRAN. To install it for now, please follow the GitHub installation instructions.

### GitHub

To install the package from GitHub use the below:

``` r
#install.packages("remotes")
remotes::install_github("https://github.com/StatsGary/FeatureTerminatoR")

```

### CRAN

To install the package from CRAN use the following command:

``` r
#install.packages("FeatureTerminatoR")
```

## Loading the package
To load the package into your R environmnet you need to use the below code:
``` r
library(FeatureTerminatoR)
```

## Using the Recursive Feature Engineering Terminator (rfeTerminator)
We will use a novel example of utilising the package to perform recursive feature engineering on the iris dataset:
``` r
library(caret)
library(tidyverse)
df <- iris
print(head(df,10))
# Fitting the model
rfe_fit <- rfeTerminator(df, x_cols= 1:4, y_cols=5, alter_df = TRUE, eval_funcs = rfFuncs)
```
At this point the model is now fitted to the data and has looked at the random forest variable importance i.e. mean decrease on accuracy in relation to the variables interaction and effect on the y variable. This will remove any variables with minimal predictive power. The next step is to examine the model outputs. 
``` r
#Explore the optimal model results
print(rfe_fit$rfe_model_fit_results)
#View the optimum variables selected
print(rfe_fit$rfe_model_fit_results$optVariables)
#Explore the original data passed to the frame
print(head(rfe_fit$rfe_original_data))
print(head(rfe_fit$rfe_reduced_data))
```
The reduced data is the dataset with the features removed, however the tool recommends the features to remove, so this can be done automated or manually. 

## Removing High Correlated Features - multicol_terminatoR

The package vignette goes into the details of why you would want to do this, here I am going to show how to implement using the iris df we have already created in the previous section:
``` r
#Fit a model on the results and define a confidence cut off limit
mc_term_fit <- FeatureTerminatoR::mutlicol_terminator(df, x_cols=1:4,
                                   y_cols="Species",
                                   alter_df=TRUE,
                                   cor_sig = 0.90)
```

To visualise the outputs of the correlations:
``` r
# Visualise the quantile distributions of where the correlations lie
mc_term_fit$corr_quant_chart
```

To view the covariance and correlation matrices:
``` r
# View the correlation matrix
mc_term_fit$corr_matrix
# View the covariance matrix
mc_term_fit$cov_matrix
```
To get the reduced data:
``` r
# Get the removed and reduced data
new_df_post_feature_removal <- mc_term_fit$feature_removed_df
glimpse(new_df_post_feature_removal)
```

## Learn How To Use The Package
To learn how to use the package, go specifically to the associated [vignette](https://rpubs.com/StatsGary/FeatureTerminatoR) to learn how to work with the tool. This will show you the inbuilt functionality for feature engineering and how to use the package. 

## Still to be included

These algorithms will form the first version of the package, but still to be developed are:

* Simulated Annealing methods - this is a probabilistic technique for approximating the global optimum of a given function. The name of the algorithm comes from annealing in metallurgy, a technique involving heating and controlled cooling of a material to increase the size of its crystals and reduce their defects.
* Lasso Regression - a regularisation method that allows for the intercept to equal zero, meaning the variable is of very little, or no importance to the prediced yhat measure. 

## Code of Conduct
  
Please note that the FeatureTerminatoR project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.

