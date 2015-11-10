::Batch file that saves key building information from SQL file to CSV file
@echo off
::Input and Output Filenames
Set InputFileName=eplusout.sql
Set OutputFileName=eplusout.csv
::Key Variables to Extract
Set SiteEnergy=SELECT RowName, Value, Units FROM TabularDataWithStrings WHERE ReportName = 'AnnualBuildingUtilityPerformanceSummary' AND ReportForString='Entire Facility' AND TableName = 'Site and Source Energy' AND RowName = 'Total Site Energy' And ColumnName = 'Total Energy';
Set SourceEnergy=SELECT RowName, Value, Units FROM TabularDataWithStrings WHERE ReportName = 'AnnualBuildingUtilityPerformanceSummary' AND ReportForString='Entire Facility' AND TableName = 'Site and Source Energy' AND RowName = 'Total Source Energy' And ColumnName = 'Total Energy';
Set SiteEnergyIntensity=SELECT RowName, Value, Units FROM TabularDataWithStrings WHERE ReportName = 'AnnualBuildingUtilityPerformanceSummary' AND ReportForString='Entire Facility' AND TableName = 'Site and Source Energy' AND RowName = 'Total Site Energy' And ColumnName = 'Energy Per Total Building Area';
Set SourceEnergyIntensity=SELECT RowName, Value, Units FROM TabularDataWithStrings WHERE ReportName = 'AnnualBuildingUtilityPerformanceSummary' AND ReportForString='Entire Facility' AND TableName = 'Site and Source Energy' AND RowName = 'Total Source Energy' And ColumnName = 'Energy Per Total Building Area';
Set PeakElectricDemand=SELECT RowName, Value, Units FROM TabularDataWithStrings WHERE ReportName = 'EnergyMeters' AND ReportForString='Entire Facility' AND TableName = 'Annual and Peak Values - Electricity' AND RowName = 'Electricity:Facility' And ColumnName = 'Electricity Maximum Value';
Set GHGEmissions=SELECT RowName, Value, Units FROM TabularDataWithStrings WHERE ReportName = 'EnergyMeters' AND ReportForString='Entire Facility' AND TableName = 'Annual and Peak Values - Other by Weight/Mass' AND RowName = 'CarbonEquivalentEmissions:Carbon Equivalent' And ColumnName = 'Annual Value';
Set AnnualElectricityCost=SELECT RowName, Value, Units FROM TabularDataWithStrings WHERE ReportName = 'Economics Results Summary Report' AND ReportForString='Entire Facility' AND TableName = 'Annual Cost' AND RowName = 'Cost' And ColumnName = 'Electric';
Set AnnualGasCost=SELECT RowName, Value, Units FROM TabularDataWithStrings WHERE ReportName = 'Economics Results Summary Report' AND ReportForString='Entire Facility' AND TableName = 'Annual Cost' AND RowName = 'Cost' And ColumnName = 'Gas';
Set TotalAnnualEnergyCost=SELECT RowName, Value, Units FROM TabularDataWithStrings WHERE ReportName = 'Economics Results Summary Report' AND ReportForString='Entire Facility' AND TableName = 'Annual Cost' AND RowName = 'Cost' And ColumnName = 'Total';
Set AnnualEnergyCostIntensity=SELECT RowName, Value, Units FROM TabularDataWithStrings WHERE ReportName = 'Economics Results Summary Report' AND ReportForString='Entire Facility' AND TableName = 'Annual Cost' AND RowName = 'Cost per Total Building Area' And ColumnName = 'Total';
::Run sqlite3 to extract the data and place it into a csv file
sqlite3.exe -csv %InputFileName% "%SiteEnergy%%SourceEnergy%%SiteEnergyIntensity%%SourceEnergyIntensity%%PeakElectricDemand%%GHGEmissions%%AnnualElectricityCost%%AnnualGasCost%%TotalAnnualEnergyCost%%AnnualEnergyCostIntensity%" > %OutputFileName%
