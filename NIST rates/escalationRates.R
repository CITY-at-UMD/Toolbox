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
 
for (i in 1:5){
  res.name <- paste("escalation.rates.","ca",i,".residential",sep="")
  com.name <- paste("escalation.rates.","ca",i,".commercial",sep="")	
  assign( res.name, read.table( paste( getwd(), "/rates/", "ca", i, ".residential.txt", sep = ""), header=TRUE, sep = " ", check.names = FALSE) )  
  assign( com.name, read.table( paste( getwd(), "/rates/", "ca", i, ".commercial.txt", sep = ""), header=TRUE, sep = " ", check.names = FALSE) )
  }
rm(i, res.name, com.name)

escalation.rates.ghg.prices = read.table( paste( getwd(), "/rates/", "ghg.price.txt", sep = ""), header=TRUE, sep = " ", check.names = FALSE)
escalation.rates.ghg.prices = t(escalation.rates.ghg.prices) #take the transpose to match other data
colnames(escalation.rates.ghg.prices) = escalation.rates.ghg.prices[1,]
escalation.rates.ghg.prices = escalation.rates.ghg.prices[-1,]
escalation.rates.ghg.prices = substr(escalation.rates.ghg.prices,2,5) #remove dollar sign
#NOTE this is not robust to carbon prices exceeding $9.99 per kg, or $990/MTCO2e, which is unlikely



