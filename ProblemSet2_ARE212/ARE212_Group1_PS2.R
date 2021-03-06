# Problem Set 2 - Are 212 - Spring 2021
# Group 1: Danyang Li, Shreya Sarkar, Jie Song
# February 16, 2021

# Preamble
# install.packages("pacman")
library(pacman)
p_load(dplyr, haven, readr, knitr, psych, ggplot2,stats4, 
       stargazer, lmSupport, magrittr, qwraps2, Jmisc)

# set working directory
setwd("D:/phd/2020-21/Spring/ARE212/ProblemSetsSofia/ProblemSet2_ARE212") # change this to your working directory
getwd()  # Confirm current wd is folder 'ProblemSet2_ARE212'

my_data <- read_dta("pset2HPRICE2.dta")
summary(my_data)

# 1. create new variable
my_data$dist2 <- my_data$dist^2

# 2. summary statistics
describe(my_data)

#         vars   n     mean      sd   median  trimmed     mad     min
# price       1 506 22511.51 9208.86 21200.00 21535.69 6078.66 5000.00
# crime       2 506     3.61    8.59     0.26     1.68    0.33    0.01
# nox         3 506     5.55    1.16     5.38     5.45    1.28    3.85
# rooms       4 506     6.28    0.70     6.21     6.25    0.51    3.56
# dist        5 506     3.80    2.11     3.21     3.54    1.91    1.13
# radial      6 506     9.55    8.71     5.00     8.73    2.97    1.00
# proptax     7 506    40.82   16.85    33.00    40.00   10.82   18.70
# stratio     8 506    18.46    2.17    19.10    18.67    1.63   12.60
# ppoverty    9 506    12.70    7.24    11.36    11.92    7.17    1.73
# lprice     10 506     9.94    0.41     9.96     9.95    0.31    8.52
# lnox       11 506     1.69    0.20     1.68     1.68    0.25    1.35
# lproptax   12 506     5.93    0.40     5.80     5.93    0.33    5.23
# dist2      13 506    18.83   21.15    10.30    14.72   10.45    1.28
# max    range  skew kurtosis     se
# price    50001.00 45001.00  1.10     1.44 409.38
# crime       88.98    88.97  5.20    36.77   0.38
# nox          8.71     4.86  0.72    -0.09   0.05
# rooms        8.78     5.22  0.40     1.84   0.03
# dist        12.13    11.00  1.01     0.46   0.09
# radial      24.00    23.00  1.00    -0.88   0.39
# proptax     71.10    52.40  0.67    -1.15   0.75
# stratio     22.00     9.40 -0.80    -0.30   0.10
# ppoverty    39.07    37.34  0.94     0.61   0.32
# lprice      10.82     2.30 -0.32     0.75   0.02
# lnox         2.16     0.82  0.35    -0.74   0.01
# lproptax     6.57     1.34  0.33    -1.18   0.02
# dist2      147.14   145.86  2.09     5.55   0.94

our_summary1 <- 
  list("Price" = 
         list("min" = ~ min(my_data$price),
              "max" = ~ max(my_data$price),
              "mean (sd)" = ~ qwraps2::mean_sd(my_data$price)),
       "Crime" = 
         list("min" = ~ min(my_data$crime),
              "max" = ~ max(my_data$crime),
              "mean (sd)" = ~ qwraps2::mean_sd(my_data$crime)), 
       "Nox" = 
         list("min" = ~ min(my_data$nox),
              "max" = ~ max(my_data$nox),
              "mean (sd)" = ~ qwraps2::mean_sd(my_data$nox)),
       "Distance" = 
         list("min" = ~ min(my_data$dist),
              "max" = ~ max(my_data$dist),
              "mean (sd)" = ~ qwraps2::mean_sd(my_data$dist))     
)

whole <- summary_table(my_data, our_summary1)
whole
stargazer(whole, out = "summary.tex")

# 3. create a histogram
hist_price <- ggplot(my_data, aes(x = price)) + 
              geom_histogram(bins = 15)
hist_price <- hist_price + 
              xlab("median housing price, $") + 
              ylab("# of observations") + 
              ggtitle("Histogram of median housing price") +
              theme(plot.title = element_text(hjust = 0.5))
hist_price

hist_nox <- hist(my_data$nox, 
                 main = "Nox distribution",
                 xlab = "Nox - Histogram of Nox, parts per 100 million (EPA standard 5.3)") +
                theme(plot.title = element_text(hjust = 0.5))
abline(v = 5.3, col = "red", lwd = 3)
hist_nox

# 4. plot price against nox 
scatter_pn <- ggplot(my_data, aes(x = nox, y = price)) +
              geom_point() +
              xlab("Nox") + 
              ylab("Median Housing Price") +
              ggtitle("Scatter Plot of Price and Nox") +
              theme(plot.title = element_text(hjust = 0.5))
scatter_pn

# 5. export data
write.csv(my_data, file = "pset2HPRICE2.csv")

# 6. reg price on nox, no constant
X6 <- my_data$nox
Y6 <- my_data$price
XY6 <- data.frame(X6, Y6)
colnames(XY6) <- c("nox", "price")
  
b6 <- solve(t(XY6$nox)%*%XY6$nox)%*%t(XY6$nox)%*%XY6$price
# b6 = 3746.135

XY6$e6 <- XY6$price - b6*XY6$nox
ssr6 <- t(XY6$e6)%*%(XY6$e6)

i <- rep(1, 506)
M0 <- diag(506) - i%*%solve(t(i)%*%i)%*%t(i)

sst6 <- t(XY6$price)%*%(XY6$price)
rsq6 <- 1 - ssr6 / sst6
rsq6 
# r-squared for Q6 = 0.7626401

XY6$price10 <- XY6$price*10
b6_2 <- solve(t(XY6$nox)%*%XY6$nox)%*%t(XY6$nox)%*%XY6$price10
# b6_2 = 37461.35

XY6$e6_2 <- XY6$price10 - b6_2*XY6$nox
ssr6_2 <- t(XY6$e6_2)%*%(XY6$e6_2)
sst6_2 <- t(XY6$price10)%*%(XY6$price10)
rsq6_2 <- 1 - ssr6_2 / sst6_2
rsq6_2
# r-sqared again = 0.7626401

all.equal(b6, b6_2)
# [1] "Mean relative difference: 9"
# the coefficients for price and price10 are different: the latter is 10 times as big as the former

all.equal(rsq6, rsq6_2)
# [1] TRUE
# the r-squared for both regressions are the same

# check if the calculation is correct
reg6 <- lm(price ~ nox - 1, XY6)
summary(reg6)
all.equal(as.numeric(b6), summary(reg6)$coefficients[1])
# [1] TRUE

all.equal(as.numeric(rsq6), summary(reg6)$r.squared)
# [1] TRUE

# report the coefficient and r-squared
stargazer(reg6, 
          column.labels = c("Question 6"),
          dep.var.labels = c(""),
          dep.var.caption = c("Dependent Variable: Median Housing Price"),
          covariate.labels = c("Nox"),
          title = "Effect of Nox on Median Housing Price (No Constant Linear OLS Regression)",
          out = "reg6.tex")

# 7. Get stats from the regression of price on nox and noconstant
# degrees of freedom (n-k), b (the coefficient), n, 
n6 <- nobs(reg6) # or nrow(model.frame(reg6))
df6 <- n6 - 1
# n = 506
# df= 505

all.equal(df6, reg6$df.residual)
# [1] TRUE

all.equal(as.numeric(b6), summary(reg6)$coefficients[1, 1])
# [1] TRUE

# R squared, R squared adjusted
all.equal(as.numeric(rsq6), summary(reg6)$r.squared)
# [1] TRUE

rsq6_adj <- 1 - (ssr6/(n6 - 1)) / (sst6 / n6)
all.equal(as.numeric(rsq6_adj), summary(reg6)$adj.r.squared)
# [1] TRUE

# SST, SSE, SSR
sse6 <- sst6 - ssr6
# ssr6 = 7.103e+10
# sst6 = 299250178180
# sse6 = 228220178672

# BIC, AIC
# BIC = ln(e'e/n) + k/n ln(n)
BIC6 <- log(ssr6 / n6) + 1 / n6 * log(n6)
all.equal(as.numeric(BIC6), BIC(reg6),
          check.attributes = FALSE, use.names = FALSE)
# [1] "Mean relative difference: 581.8262"

# AIC = ln(e'e/n) + 2k/n
AIC6 <- log(ssr6 / n6) + 2 / n6
all.equal(as.numeric(AIC6), AIC(reg6),
          check.attributes = FALSE, use.names = FALSE)
# [1] "Mean relative difference: 581.6352"

# The formulae for BIC and AIC in the canned package are different from class formulae.

# Generate a series of the predicted values of price
XY6$price_hat <- b6 * X6
all.equal(XY6$price_hat, reg6$fitted.values, 
          check.attributes = FALSE, use.names = FALSE)
# [1] TRUE

# plot those against the price data series
plot_yhat6 <- ggplot(XY6, aes(x = price, y = price_hat)) +
              geom_point() +
              xlab("Median Housing Price") + ylab("Predicted Price") +
              ggtitle("Scatter Plot of Price and Predicted Price") +
              theme(plot.title = element_text(hjust = 0.5))
plot_yhat6
# The fit is bad as the model performs poorly when predicting outliers.

# Compute the residuals series and plot the residuals against nox
all.equal(XY6$e6, reg6$residuals, 
          check.attributes = FALSE, use.names = FALSE)
# [1] TRUE
plot_res6 <- ggplot(XY6, aes(x = nox, y = e6)) +
             geom_point() +
             xlab("Nox, parts per 100 million") + ylab("Residuals") +
             ggtitle("Scatter Plot of Nox and Residuals") +
             theme(plot.title = element_text(hjust = 0.5))
plot_res6

# The variance of residuals is not constant across nox. The higher the nox, the lower the variance, indicating heteroskedasticity. 

# 8. Regress price on nox and a constant. 
X8 <- cbind(1, my_data$nox)
XY8 <- data.frame(X8, my_data$price)
colnames(XY8) <- c("constant", "nox", "price")

reg8 <- lm(price ~ nox, XY8)

# get degrees of freedom (n-k), b (the coefficient), n
n8 <- nobs(reg8)
# n = 506
df8 <- n8 - 2
# df= 504

all.equal(df8, reg8$df.residual)
# [1] TRUE
b8 <- solve(t(X8)%*%X8)%*%t(X8)%*%XY8$price
# b8   [,1]
# [1,] 41307.806
# [2,] -3386.853

all.equal(as.numeric(b8), summary(reg8)$coefficients[, 1], 
          check.attributes = FALSE, use.names = FALSE)
# [1] TRUE

# SST, SSM, SSR
XY8$price_hat <- X8%*%b8 
XY8$e8 <- XY8$price - XY8$price_hat
ssr8 <- t(XY8$e8)%*%(XY8$e8)
sst8 <- t(M0%*%XY8$price)%*%(M0%*%XY8$price)
sse8 <- sst8 - ssr8
# ssr8 = 35052373637
# sst8 = 42825531146
# sse8 = 7773157510

# R squared, R squared adjusted
rsq8 <- 1 - ssr8 / sst8
rsq8
# r-squared for Q8 = 0.1815076
all.equal(summary(reg8)$r.squared, as.numeric(rsq8))
# [1] TRUE

rsq8_adj <- 1 - (ssr8/(n8 - 2)) / (sst8 / (n8 - 1))
# adjusted r-squared for Q8 = 0.1798836
all.equal(summary(reg8)$adj.r.squared, as.numeric(rsq8_adj))
# [1] TRUE

# BIC, AIC
# BIC = ln(e'e/n) + k/n ln(n)
BIC8 <- log(ssr8 / n8) + 2 / n8 * log(n8)
all.equal(as.numeric(BIC8), BIC(reg8),
          check.attributes = FALSE, use.names = FALSE)
# [1] "Mean relative difference: 584.7753"

# AIC = ln(e'e/n) + 2k/n
AIC8 <- log(ssr8 / n8) + 4 / n8
all.equal(as.numeric(AIC8), AIC(reg8),
          check.attributes = FALSE, use.names = FALSE)
# [1] "Mean relative difference: 584.6151"

#The formula for AIC in the canned package is different from class formula.

# Generate a series of the predicted values of price and plot those against the price data series
all.equal(as.numeric(XY8$price_hat), reg8$fitted.values, 
          check.attributes = FALSE, use.names = FALSE)
# [1] TRUE

plot_yhat8 <- ggplot(XY8, aes(x = price, y = price_hat)) +
              geom_point() +
              xlab("Median Housing Price") + ylab("Predicted Price") +
              ggtitle("Scatter Plot of Price and Predicted Price") +
              theme(plot.title = element_text(hjust = 0.5))
plot_yhat8

# The fit is improved compared to the model without a constant.

# Compute the residuals series and plot the residuals against nox
all.equal(as.numeric(XY8$e8), reg8$residuals, 
          check.attributes = FALSE, use.names = FALSE)
# [1] TRUE

plot_res8 <- ggplot(XY8, aes(x = nox, y = e8)) +
             geom_point() +
             xlab("Nox, parts per 100 million") + ylab("Residuals") +
             ggtitle("Scatter Plot of Nox and Residuals") +
             theme(plot.title = element_text(hjust = 0.5))
plot_res8

# The variance of residuals is still not constant across nox. The higher the nox, the lower the variance, indicating heteroskedasticity. 

# 9.Demean price, call it dmeanprice and demean nox and call it dmeannox
my_data$dmeannox <- M0%*%my_data$nox
my_data$dmeanprice <- M0%*%my_data$price

# Regress the demeaned price on demeaned nox variable and no constant, and compare to analysis in question 8. Why do you get this? Explain briefly the theorem behind this?
b9 <- solve(t(my_data$dmeannox)%*%my_data$dmeannox)%*%
            t(my_data$dmeannox)%*%my_data$dmeanprice
b9
# b9 = -3386.853

all.equal(b8[2], as.numeric(b9), 
          check.attributes = FALSE, use.names = FALSE)
# [1] TRUE

reg9 <- lm(dmeanprice ~ dmeannox - 1, my_data)
summary(reg9)

all.equal(as.numeric(b9), summary(reg9)$coefficients[1],
          check.attributes = FALSE, use.names = FALSE)
# [1] TRUE

# Coefficients on nox for regression models in Q8 and Q9 are identical because in a simple regression model with a constant, the constant ensures the model residuals have a mean of 0, so it's equivalent to regressing demeaned Y on demeaned X without a constant, which effectively has a residual of 0. 

# make a nice ready for latex table and have side by side estimates
stargazer(reg8, reg9,
          column.labels = c("Y = Median Housing Price", "Y = Demeaned Median Housing Price"),
          dep.var.labels = c("", ""),
          dep.var.caption = c("Dependent Variable: Median Housing Price and Demeaned Median Housing Price"),
          covariate.labels = c("Nox", "Demeaned Nox"),
          title = "Effect of Nox on Median Housing Price (No Constant Linear OLS Regression)",
          out = "reg89.tex")

# 10.Regress price on a constant, nox, crime, rooms, dist, and dist2. 
X10 <- cbind(1, my_data$nox, my_data$crime, my_data$rooms,
                my_data$dist, my_data$dist2)
XY10 <- data.frame(X10, my_data$price)
colnames(XY10) <- c("constant", "nox", 
                    "crime", "rooms", "dist", "dist2", "price")
  
b10 <- solve(t(X10)%*%X10)%*%t(X10)%*%XY10$price
b10
#            [,1]
# [1,] -2137.2496
# [2,] -2989.2032
# [3,]  -239.2129
# [4,]  7876.2883
# [5,] -2846.8449
# [6,]   181.2089

reg10 <- lm(price ~ nox + crime + rooms + dist + dist2, my_data)
summary(reg10)
all.equal(as.numeric(b10), summary(reg10)$coefficients[, 1],
          check.attributes = FALSE, use.names = FALSE)
# [1] TRUE

# Generate a series of the predicted values of price and plot those against the price data series: What do you see in terms of fit?
XY10$price_hat <- X10%*%b10 
all.equal(as.numeric(XY10$price_hat), reg10$fitted.values,
          check.attributes = FALSE, use.names = FALSE)
# [1] TRUE

plot_yhat10 <- ggplot(XY10, aes(x = price, y = price_hat)) +
               geom_point() +
               xlab("Median Housing Price") + ylab("Predicted Price") +
               ggtitle("Scatter Plot of Price and Predicted Price") +
               theme(plot.title = element_text(hjust = 0.5))
plot_yhat10

# The fit is improved compared to the simple regression models.

# Compute the residuals series and plot the residuals against nox
XY10$e10 <- XY10$price - XY10$price_hat
all.equal(as.numeric(XY10$e10), reg10$residuals,
          check.attributes = FALSE, use.names = FALSE)
# [1] TRUE

plot_res10 <- ggplot(XY10, aes(x = nox, y = e10)) +
              geom_point() +
              xlab("Nox, parts per 100 million") + ylab("Residuals") +
              ggtitle("Scatter Plot of Nox and Residuals") +
              theme(plot.title = element_text(hjust = 0.5)) 
plot_res10

# the constant variance assumption for the residuals is not valid, as the variance of residual is small in extreme values of nox but large in middle values of nox

# 11.Regress Price on a constant, crime, rooms, dist, and dist2. Save residuals as PRICEres or Y11. 
X11 <- cbind(1, my_data$crime, my_data$rooms, 
                my_data$dist, my_data$dist2)
b11_1 <- solve(t(X11)%*%X11)%*%t(X11)%*%my_data$price
PRICEres <- my_data$price - X11%*%b11_1
b11_1
#               [,1]
# [1,] -29816.35197
# [2,]   -251.57295
# [3,]   8347.88617
# [4,]    284.87968
# [5,]    -16.11123

# Regress Nox on a constant, crime, rooms, dist, and dist2. Save these residuals as NOXres or X11. 
b11_2 <- solve(t(X11)%*%X11)%*%t(X11)%*%my_data$nox
NOXres <- my_data$nox - X11%*%b11_2
b11_2
#              [,1]
# [1,]  9.259692604
# [2,]  0.004134888
# [3,] -0.157767086
# [4,] -1.047678749
# [5,]  0.066010936

# Regress PRICEres on NOXres (or Y11 on X11) and no constant.
b11_3 <- solve(t(NOXres)%*%NOXres)%*%t(NOXres)%*%PRICEres
b11_3
# b11_3 = -2989.203

# Report your findings. We wanted to get the effect of nox on housing prices, all else constant. To which coefficient of a previous question is the coefficient of NOXres (or X11) equal to, and why?
# The coefficient is equal to the coefficient of Nox in Q10. Because in this equestion, we effectively regress prices that are not explained by the other five variables (PRICEres) on the Nox level that are not explained by other variables (NOXres). This is equivalent to regressing price on all six variables. The coefficient of Nox, in both cases, means the effect of Nox and price after controlling for the effects of all other variables. 

# check then with lm() package. 
reg11_1 <- lm(price ~ crime + rooms + dist + dist2, my_data)
reg11_2 <- lm(nox ~ crime + rooms + dist + dist2, my_data)
reg11_data <- data.frame(reg11_1$residuals, reg11_2$residuals)
colnames(reg11_data) <- c("PRICEres", "NOXres")

reg11 <- lm(PRICEres ~ NOXres - 1, reg11_data)
summary(reg11)
all.equal(as.numeric(b11_3), summary(reg11)$coefficients[1])
# [1] TRUE

# Make nice latex tables
stargazer(reg10, reg11,
          column.labels = c("Multivariate Reg", "Reg PRICEres on NOXres"),
          dep.var.labels = c("", ""),
          dep.var.caption = c("Dependent Variable: Median Housing Price"),
          covariate.labels = c("Nox", "Nox"),
          title = "Effect of Nox on Median Housing Price",
          out = "reg1011.tex")