$TodayDate = get-date -format "yyyyMMdd"
$ServerName = hostname
$Folder = "C:\Users\user\Desktop"
$CPU_Daily_CSV = "$Folder\$ServerName" + "_$TodayDate" + "_CPU.csv"
$Mem_Daily_CSV = "$Folder\$ServerName" + "_$TodayDate" + "_Mem.csv"
$Disk_Daily_CSV = "$Folder\$ServerName" + "_$TodayDate" + "_Disk.csv"
$DailyerrLog = "$Folder\DailyErr.log"

function Percent_Used{
	param([array] $Freespace)
	$UsedSpace = ($FreeSpace.Size - $FreeSpace.FreeSpace)
	If ($UsedSpace -ne 0) {
		return [math]::Round(((($FreeSpace.Size - $FreeSpace.FreeSpace) / $FreeSpace.Size)*100),2)
	}
	Else {
		return $UsedSpace
	}
}

$Current_Time = Get-date -format s

$Processor = (Get-WmiObject -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average ).Average

$ComputerMemory = Get-WmiObject -Class win32_operatingsystem -ErrorAction Stop
$Memory = ((($ComputerMemory.TotalVisibleMemorySize - $computerMemory.FreePhysicalMemory)*100)/ $ComputerMemory.TotalVisibleMemorySize)
$RoundMemory = [math]::Round($Memory, 2)

$FreeSpace_C = (Get-WmiObject -Class Win32_logicalDisk | ? {$_.DeviceID -eq 'C:'})
$Pct_Use_C = Percent_Used($FreeSpace_C)

$FreeSpace_D = Get-WmiObject -Class Win32_logicalDisk | ? {$_.DeviceID -eq 'D:'} 
$Pct_Use_D = Percent_Used($FreeSpace_D)

If (!(Test-Path $CPU_Daily_CSV)){
	"Date,CPU_usage" >> $CPU_Daily_CSV
}
"$Current_Time,$Processor" >> $CPU_Daily_CSV

If (!(Test-Path $Mem_Daily_CSV)){
	"Date,Mem_Usage" >> $Mem_Daily_CSV
}
"$Current_Time,$RoundMemory" >> $Mem_Daily_CSV

If (!(Test-Path $Disk_Daily_CSV)){
	"Date,C_Drive_Usage,D_Drive_Usage" >> $Disk_Daily_CSV
}
"$Current_Time,$Pct_Use_C,$Pct_Use_D" >> $Disk_Daily_CSV

#Logging
$CPU_File_Modify_Date=(Get-ChildItem $CPU_Daily_CSV).LastWriteTime
$Mem_File_Modify_Date=(Get-ChildItem $Mem_Daily_CSV).LastWriteTime
$Disk_File_Modify_Date=(Get-ChildItem $Disk_Daily_CSV).LastWriteTime

$CPU_File_Update_Time=NEW-TIMESPAN -Start $Current_Time -End $CPU_File_Modify_Date
$Mem_File_Update_Time=NEW-TIMESPAN -Start $Current_Time -End $Mem_File_Modify_Date
$Disk_File_Update_Time=NEW-TIMESPAN -Start $Current_Time -End $Disk_File_Modify_Date

If ($CPU_File_Update_Time.Minutes -gt 5){
	Write-Output "$Current_Time $CPU_Daily_CSV not update. Please Check!" | Out-file $DailyErrLog -append
}

If ($Mem_File_Update_Time.Minutes -gt 5){
	Write-Output "$Current_Time $Mem_Daily_CSV not update. Please Check!" | Out-file $DailyErrLog -append
}

If ($Disk_File_Update_Time.Minutes -gt 5){
	Write-Output "$Current_Time $Disk_Daily_CSV not update. Please Check!" | Out-file $DailyErrLog -append
}
