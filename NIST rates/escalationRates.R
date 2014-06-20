# NISTIR 85-3273-28 
# Energy Price Indices and Discount Factors for Life-Cycle Cost Analysis – 2013 
# Annual Supplement to NIST Handbook 135 and NBS Special Publication 709
# http://dx.doi.org/10.6028/NIST.IR.85-3273-28 
#
# Matthew Dahlhausen 17 Jun 2014
#
# Projected fuel price indices (excluding general inflation) by end-use sector and fuel type.
# ca1 = Census Region 1 (Connecticut, Maine, Massachusetts, New Hampshire, New Jersey, New York, Pennsylvania, Rhode Island, Vermont)
# ca2 = Census Region 2 (Illinois, Indiana, Iowa, Kansas, Michigan, Minnesota, Missouri, Nebraska, North Dakota, Ohio, South Dakota, Wisconsin)
# ca3 = Census Region 3 (Alabama, Arkansas, Delaware, District of Columbia, Florida, Georgia, Kentucky, Louisiana, Maryland, Mississippi, North Carolina, Oklahoma, South Carolina, Tennessee, Texas, Virginia, West Virginia)
# ca4 = Census Region 4 (Alaska, Arizona, California, Colorado, Hawaii, Idaho, Montana, Nevada, New Mexico, Oregon, Utah, Washington, Wyoming)
# ca5 = United States Average
# fuels = (Electricity,Distillate.Oil,LPG,Residual.Oil,Natural.Gas,Coal)
# use example: # escalation.rates.ca1.residential["Electricity","2017"]
#
# ghg.prices in 2013 dollar per kilogram carbon dioxide equivalent
# use example: escalation.rates.ghg.prices["Low",] escalation.rates.ghg.prices["Default",as.character(i)]
# 
# R does not allow object names to start with numbers.  To reference column headers (years) as numbers, use as.numeric(colnames(data))

### DATA IMPORT SECTION ### 
ImportEscalationRates <- function() {		# RUN CODE INSIDE THIS FUNCTION IN R; FUNCTION DOES NOT RETURN VALUES YET
  # Imports NIST escalation rates into R variables 
  #
  # Returns:
  #   Variables in the format escalation.rates.region.sector and escalation.rates.ghg.prices 
  
  ##import escalation rates
  res.names <- c(rep("NULL",5))
  com.names <- c(rep("NULL",5))
  for (i in 1:5){	
    res.names[i] <- paste("ca",i,".residential",sep="")
    com.names[i] <- paste("ca",i,".commercial",sep="")	
	# include file load error handling here
    assign( res.names[i], read.table( paste( getwd(), "/rates/", "ca", i, ".residential.txt", sep = ""), header=TRUE, sep = " ", check.names = FALSE) )  
    assign( com.names[i], read.table( paste( getwd(), "/rates/", "ca", i, ".commercial.txt", sep = ""), header=TRUE, sep = " ", check.names = FALSE) )  
  }  

  ## Import GHG prices
  ## NOTE: this is not robust to carbon prices exceeding $9.99 per kg, or $990/MTCO2e, which is unlikely
  ghg.prices = read.table( paste( getwd(), "/rates/", "ghg.price.txt", sep = ""), header=TRUE, sep = " ", check.names = FALSE)
  ghg.prices <- t(ghg.prices) #take the transpose to match other data
  colnames(ghg.prices) <- ghg.prices[1,]
  ghg.prices <- ghg.prices[-1,]
  ghg.prices <- substr(ghg.prices,2,5) #remove dollar sign  
  apply(ghg.prices[], 2, as.numeric)
  rownames(ghg.prices) <- c("Default", "Low", "High") #add back in row names (there is an error I'm not catching)
  
  escalation.rates <- list(	ca1.residential = get(res.names[1]), 
							ca2.residential = get(res.names[2]),
							ca3.residential = get(res.names[3]),
							ca4.residential = get(res.names[4]),
							ca5.residential = get(res.names[5]),
							ca1.commercial = get(com.names[1]),
							ca2.commercial = get(com.names[2]),
							ca3.commercial = get(com.names[3]),
							ca4.commercial = get(com.names[4]),
							ca5.commercial = get(com.names[5]),
							"ghg.prices" = ghg.prices)
  return(escalation.rates)
}

### METHODS ### 
GetEscalationRate <- function(region = "ca5", sector = "commercial") {
  # Computes and adjusted fuel cost, excluding general inflation.
  #
  # Args:
  #   region: ca1-ca5, default is ca5, U.S. average 
  #	  sector: residential or commercial,  default is commercial
  # Returns:
  #   Project future price indices for that region and sector for all fuels through 2043
  rate <- read.table( paste( getwd(), "/rates/", region, ".", sector, ".txt", sep = ""), header=TRUE, sep = " ", check.names = FALSE)
  return(rate)
}

ApplyEscalationRate <- function(cost, rate, fuel, year) {
  # Computes and adjusted fuel cost, excluding general inflation.
  #
  # Args:
  #   cost: The cost to be adjusted, in 2013 dollars
  #   fuel: Electricity, Distillate.Oil, LPG, Residual.Oil, Natural.Gas, or Coal 
  #	  year: The year to adjust 
  # Returns:
  #   An adjusted cost modified by the price index for that fuel in that year 
  
  # Error handling
  if (as.numeric(year) < as.numeric("2013")){ 
    stop("NIST rates are not available for base years prior to 2013")  
  }  
  if (as.numeric(year) > as.numeric("2043")) { 
    stop("NIST rates are not available beyond 2043")  
  }   
  adjusted.cost <- cost*rate[fuel, year]  
  return(adjusted.cost)
}

ApplyEscalationRates <- function(cash.flow, region = "ca1", sector = "commercial", fuel, start.year = "2013") {
  # Computes the fuel price indices, excluding general inflation.
  #
  # Args:
  #   cash.flow: The cost to be adjusted, in 2013 dollars  #   
  #   region: ca1-ca5, default is ca5, U.S. average 
  #	  sector: residential or commercial,  default is commercial
  #   fuel: Electricity, Distillate.Oil, LPG, Residual.Oil, Natural.Gas, or Coal 
  #	  start.year: year of first index in cash flow 
  #
  # Returns:
  #   A price index adjusted projected cash flow 
  
  # Error handling
  if (as.numeric(start.year) < as.numeric("2013")){ 
    stop("NIST rates are not available for base years prior to 2013")  
  }  
  if (as.numeric(start.year) + length(cash.flow) - 1 > as.numeric("2043")) { 
    stop("cash flow period extends beyond 2043, beyond which NIST rates are unavailable")  
  } 
  if (length(cash.flow) == 0) { 
    stop("cash flow is 0 length")  
  }     
  rate <- GetEscalationRate(region, sector) 
  adjusted.cash.flow <- c(rep(0,length(cash.flow)))  
  if (as.numeric(start.year) == "2013"){ 
    adjusted.cash.flow[1] <- cash.flow[1]
    i <- 2
  } else {
    i <- 1
  }
  for (j in i:length(cash.flow)) {
    cost <- cash.flow[j]
    year <- as.character(as.numeric(start.year) + j-1)
    adjusted.cash.flow[j] <- ApplyEscalationRate(cost, rate, fuel, year) 
  }
  return(adjusted.cash.flow)
}

## Add Function: GHGCost <- function(scenario = "Default", year) {} escalation.rates.ghg.prices["Default",as.character(i)]

