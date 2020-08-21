$TodayDate = get-date -format "yyyyMMdd"
$ServerName = hostname
$Folder = "C:\Users\user\Desktop"
$CPU_Daily_CSV = "$Folder\$ServerName" + "_$TodayDate" + "_CPU.csv"
$Mem_Daily_CSV = "$Folder\$ServerName" + "_$TodayDate" + "_Mem.csv"
$Disk_Daily_CSV = "$Folder\$ServerName" + "_$TodayDate" + "_Disk.csv"

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
