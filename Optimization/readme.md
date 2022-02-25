# Calibration of Heston Stochastic Volatility Model

Estimate the model parameters Ψ = {κ, θ, η, ρ, V0}, using a snapshot of a volatility surface (empVolatilitySurfaceData.mat)

The empVolatilitySurfaceData.mat file contains a data structure:
– data.K: 1 × 42 strike prices
– data.T: 8 × 1 maturities
– data.IVolSurf: 8 × 41 Implied volatilities (that is, option prices are provided in terms of B-S implied volatilities)
– data.r: interest rate (0.0466)
– data.S0: current price of the underlying stock (1.00)

The loss function is:

  sum(marketIV - modelIV)^2

which is to be minimized with respect to model parameters. 
Here IVMarket is the implied volatility from the market
and IVModel is the implied volatility from the model with the given values of parameters.


I am using the FFT-approach to price options with given parameter values and converting the dollar prices to Implied Volatilities.
I visualize the market and volatility surfaces in every optimization iteration.
Then I calculate the standard errors of parameter estimates.
