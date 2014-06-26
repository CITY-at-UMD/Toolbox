filenames <- list.files(path="data", pattern="*.csv")
for (i in 1:length(filenames)){ 
	data = t( read.csv( paste(getwd(),"/data/",filenames[i],sep = ""), header=FALSE) )
	rownames(data) <- c(substr(filenames[i], 9, nchar(filenames[i])-4))
	colnames(data) <- c("SiteEnergy(GJ)","SourceEnergy(GJ)","SiteEnergyIntensity(MJ/m2)","SourceEnergyIntensity(MJ/m2)","PeakElectricDemand(W)","GHGEmissions(kg)","AnnualElectricityCost($)","AnnualGasCost($)","TotalAnnualEnergyCost($)","AnnualEnergyCostIntensity($/m2)")
	if (i == 1) {
	  Bldg101Data <- data
	} else {
	  Bldg101Data <- rbind(Bldg101Data,data)
	}
}
rm(filenames,data,i)
#print(Bldg101Data)
#Optional write. CAUTION: it will save to same directory, and will need to be moved before rerunning script
write.table(Bldg101Data, "Bldg101Data.csv", sep=",", col.names=NA)
