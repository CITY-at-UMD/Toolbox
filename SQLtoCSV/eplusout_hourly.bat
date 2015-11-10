::Batch file that saves hourly output from SQL file to CSV file
::Make sure OutputVariable and OutputMeter objects exist in EnergyPlus
@echo off
::Input and Output Filenames
Set InputFileName=eplusout.sql

::Key Variables to Extract
Set RunPeriodKey=SELECT EnvironmentPeriodIndex FROM EnvironmentPeriods WHERE EnvironmentType=3;
for /f "delims=" %%i in ('sqlite3.exe %InputFileName% "%RunPeriodKey%"') do set RunPeriodIndex=%%i

Set TimeSchema=.schema Time;
Set Times=SELECT * FROM Time WHERE Interval=60 AND EnvironmentPeriodIndex=%RunPeriodIndex%;

Set InteriorLightsKey=SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableName = 'InteriorLights:Electricity' AND ReportingFrequency = 'Hourly';
for /f "delims=" %%i in ('sqlite3.exe %InputFileName% "%InteriorLightsKey%"') do set InteriorLightsIndex=%%i
Set InteriorLights=SELECT VariableValue FROM ReportMeterData WHERE TimeIndex IN (SELECT TimeIndex FROM Time WHERE Interval=60 AND EnvironmentPeriodIndex=%RunPeriodIndex%) AND ReportMeterDataDictionaryIndex=%InteriorLightsIndex%;

Set InteriorEquipmentKey=SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableName = 'InteriorEquipment:Electricity' AND ReportingFrequency = 'Hourly';
for /f "delims=" %%i in ('sqlite3.exe %InputFileName% "%InteriorEquipmentKey%"') do set InteriorEquipmentIndex=%%i
Set InteriorEquipment=SELECT VariableValue FROM ReportMeterData WHERE TimeIndex IN (SELECT TimeIndex FROM Time WHERE Interval=60 AND EnvironmentPeriodIndex=%RunPeriodIndex%) AND ReportMeterDataDictionaryIndex=%InteriorEquipmentIndex%;

Set FansKey=SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableName = 'Fans:Electricity' AND ReportingFrequency = 'Hourly';
for /f "delims=" %%i in ('sqlite3.exe %InputFileName% "%FansKey%"') do set FansIndex=%%i
Set Fans=SELECT VariableValue FROM ReportMeterData WHERE TimeIndex IN (SELECT TimeIndex FROM Time WHERE Interval=60 AND EnvironmentPeriodIndex=%RunPeriodIndex%) AND ReportMeterDataDictionaryIndex=%FansIndex%;

Set CoolingKey=SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableName='Cooling:Electricity' AND ReportingFrequency = 'Hourly';
for /f "delims=" %%i in ('sqlite3.exe %InputFileName% "%CoolingKey%"') do set CoolingIndex=%%i
Set Cooling=SELECT VariableValue FROM ReportMeterData WHERE TimeIndex IN (SELECT TimeIndex FROM Time WHERE Interval=60 AND EnvironmentPeriodIndex=%RunPeriodIndex%) AND ReportMeterDataDictionaryIndex=%CoolingIndex%;

Set HeatingKey=SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableName='Heating:Gas' AND ReportingFrequency = 'Hourly';
for /f "delims=" %%i in ('sqlite3.exe %InputFileName% "%HeatingKey%"') do set HeatingIndex=%%i
Set Heating=SELECT VariableValue FROM ReportMeterData WHERE TimeIndex IN (SELECT TimeIndex FROM Time WHERE Interval=60 AND EnvironmentPeriodIndex=%RunPeriodIndex%) AND ReportMeterDataDictionaryIndex=%HeatingIndex%;

Set ElectricityKey=SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableName = 'Electricity:Facility' AND ReportingFrequency = 'Hourly';
for /f "delims=" %%i in ('sqlite3.exe %InputFileName% "%ElectricityKey%"') do set ElectricityIndex=%%i
Set Electricity=SELECT VariableValue FROM ReportMeterData WHERE TimeIndex IN (SELECT TimeIndex FROM Time WHERE Interval=60 AND EnvironmentPeriodIndex=%RunPeriodIndex%) AND ReportMeterDataDictionaryIndex=%ElectricityIndex%;

Set GasKey=SELECT ReportMeterDataDictionaryIndex FROM ReportMeterDataDictionary WHERE VariableName='Gas:Facility' AND ReportingFrequency = 'Hourly';
for /f "delims=" %%i in ('sqlite3.exe %InputFileName% "%GasKey%"') do set GasIndex=%%i
Set Gas=SELECT VariableValue FROM ReportMeterData WHERE TimeIndex IN (SELECT TimeIndex FROM Time WHERE Interval=60 AND EnvironmentPeriodIndex=%RunPeriodIndex%) AND ReportMeterDataDictionaryIndex=%GasIndex%;

Set FanMassFlowKey=SELECT ReportVariableDataDictionaryIndex FROM ReportVariableDataDictionary WHERE VariableName='Air System Mixed Air Mass Flow Rate' AND ReportingFrequency = 'Hourly';
for /f "delims=" %%i in ('sqlite3.exe %InputFileName% "%FanMassFlowKey%"') do set FanMassFlowIndex=%%i
Set FanMassFlow=SELECT VariableValue FROM ReportVariableData WHERE TimeIndex IN (SELECT TimeIndex FROM Time WHERE Interval=60 AND EnvironmentPeriodIndex=%RunPeriodIndex%) AND ReportVariableDataDictionaryIndex = %FanMassFlowIndex%;

::Run sqlite3 to extract the data and place it into a csv file
sqlite3.exe -csv %InputFileName% "%Times%" > Times.csv
sqlite3.exe -csv %InputFileName% "%InteriorLights%" > InteriorLights.csv
sqlite3.exe -csv %InputFileName% "%InteriorEquipment%" > InteriorEquipment.csv
sqlite3.exe -csv %InputFileName% "%Fans%" > Fans.csv
sqlite3.exe -csv %InputFileName% "%FanMassFlow%" > FanMassFlow.csv
sqlite3.exe -csv %InputFileName% "%Cooling%" > Cooling.csv
sqlite3.exe -csv %InputFileName% "%Heating%" > Heating.csv
sqlite3.exe -csv %InputFileName% "%Electricity%" > Electricity.csv
sqlite3.exe -csv %InputFileName% "%Gas%" > Gas.csv