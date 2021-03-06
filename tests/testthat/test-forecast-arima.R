context("forecast_ARIMA")

library(forecast)

# Test Group A: Simple Arima Model
test_that("Basic ARIMA model functions",{
  # Set seed so that rnorm returns the same result
  set.seed(123)
  
  # Build Arima (no regression)
  model <- forecast::Arima(ts(rnorm(1000),freq=4), 
                           order=c(1,1,1),
                           seasonal=c(1,0,1),
                           include.constant = TRUE)
  
  # Test 1: Works with greek letters
  tex <- extract_eq(model)
  actual <- "(1 -\\phi_{1}\\operatorname{B} )\\ (1 -\\Phi_{1}\\operatorname{B}^{\\operatorname{4}} )\\ (1 - \\operatorname{B}) (y_{t} -\\delta\\operatorname{t}) = (1 +\\theta_{1}\\operatorname{B} )\\ (1 +\\Theta_{1}\\operatorname{B}^{\\operatorname{4}} )\\ \\varepsilon_{t}"
  expect_equal(tex, equation_class(actual),
               label = "basic Arima + greek builds correctly")
  
  # Test 2: Works with coefficients
  tex <- extract_eq(model, use_coefs = TRUE)
  actual <- "(1 +0.03\\operatorname{B} )\\ (1 +0.75\\operatorname{B}^{\\operatorname{4}} )\\ (1 - \\operatorname{B}) (y_{t} -1e-06\\operatorname{t}) = (1 -1\\operatorname{B} )\\ (1 +0.74\\operatorname{B}^{\\operatorname{4}} )\\ \\varepsilon_{t}"
  
  if( as.vector( adist(tex,actual) ) > 0 ) {
    test <- TRUE
  } else {
    numerics <- lapply(list(tex,actual), function(x){
      y <- gsub("[^0-9\\.\\s]+", " ", x, perl = TRUE)
      y <- strsplit(y, "\\s")
      y <- as.numeric(unlist(y))
      
      y[!is.na(y)]
    })
    
    test <- sum( abs( numerics[[1]] - numerics[[2]] ) > 0.01 ) == 0
  }
  
  expect_true(test,
              label = "basic Arima + coefficients builds correctly")

})

# Test Group B: Regression w/ ARIMA Errors
test_that("Regression w/ ARIMA Errors functions",{
  # Set seed so that rnorm returns the same result
  set.seed(123)
  
  # Build our random numbers
  rnd_numbers <- list(x1 = rnorm(1000),
                      x2 = rnorm(1000),
                      ts_rnorm = rnorm(1000))
  
  # Build Exogenous Regressors
  xregs <- as.matrix(data.frame(x1 = rnd_numbers$x1 + 5,
                                x2 = rnd_numbers$x2 * 5))
  
  # Build Regression Model
  model <- forecast::Arima(ts(rnd_numbers$ts_rnorm,freq=4), 
                           order=c(1,1,1),
                           seasonal=c(1,0,1),
                           xreg = xregs,
                           include.constant = TRUE)
  
  # Test 1: Works with greek letters
  tex <- extract_eq(model)
  actual <- "\\begin{alignat}{2}
&\\text{let}\\quad &&y_{t} = \\operatorname{y}_{\\operatorname{0}} +\\delta\\operatorname{t} +\\beta_{1}\\operatorname{x1}_{\\operatorname{t}} +\\beta_{2}\\operatorname{x2}_{\\operatorname{t}} +\\eta_{t} \\\\
&\\text{where}\\quad  &&(1 -\\phi_{1}\\operatorname{B} )\\ (1 -\\Phi_{1}\\operatorname{B}^{\\operatorname{4}} )\\ (1 - \\operatorname{B}) \\eta_{t}  \\\\
& &&= (1 +\\theta_{1}\\operatorname{B} )\\ (1 +\\Theta_{1}\\operatorname{B}^{\\operatorname{4}} )\\ \\varepsilon_{t} \\\\
&\\text{where}\\quad &&\\varepsilon_{t} \\sim{WN(0, \\sigma^{2})}
\\end{alignat}"
  
  expect_equal(tex, equation_class(actual),
               label = "Regession w/ Arima Errors + greek builds correctly")
  
  # Test 2: Works with coefficients
  tex <- extract_eq(model, use_coefs = TRUE)
  actual <- "\\begin{alignat}{2}
&\\text{let}\\quad &&y_{t} = \\operatorname{y}_{\\operatorname{0}} +2e-04\\operatorname{t} -0.02\\operatorname{x1}_{\\operatorname{t}} +0.01\\operatorname{x2}_{\\operatorname{t}} +\\eta_{t} \\\\
&\\text{where}\\quad  &&(1 -0.03\\operatorname{B} )\\ (1 +0.99\\operatorname{B}^{\\operatorname{4}} )\\ (1 - \\operatorname{B}) \\eta_{t}  \\\\
& &&= (1 -1\\operatorname{B} )\\ (1 +1\\operatorname{B}^{\\operatorname{4}} )\\ \\varepsilon_{t} \\\\
&\\text{where}\\quad &&\\varepsilon_{t} \\sim{WN(0, \\sigma^{2})}
\\end{alignat}"
  
  if( as.vector( adist(tex,actual) ) > 0 ) {
    test <- TRUE
  } else {
    numerics <- lapply(list(tex,actual), function(x){
      y <- gsub("[^0-9\\.\\s]+", " ", x, perl = TRUE)
      y <- strsplit(y, "\\s")
      y <- as.numeric(unlist(y))
      
      y[!is.na(y)]
    })
    
    test <- sum( abs( numerics[[1]] - numerics[[2]] ) > 0.01 ) == 0
  }
  
  expect_true(test,
              label = "Regession w/ Arima Errors + coefficients builds correctly")
  
})
