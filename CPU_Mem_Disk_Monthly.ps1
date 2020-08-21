$LastMonth = (Get-Date).Addmonths(-1).ToString('yyyyMM')
#$LastMonth = get-date -format "202003"
$Folder = "C:\Users\user\Desktop\CPU_Mem_Disk"
$ServerName = hostname
$Compress_csv = "$Folder\$ServerName" + "_$LastMonth" + "*.csv"
$Zip_File = "$Folder\$ServerName" + "_$LastMonth" + ".zip"

$cpu_csvs = Get-childItem -Path $Folder | where-object {$_.name -like "*_" + $LastMonth + "*_CPU.csv"} | select name

$mem_csvs = Get-childItem -Path $Folder | where-object {$_.name -like "*_" + $LastMonth + "*_Mem.csv"} | select name

$disk_csvs = Get-childItem -Path $Folder | where-object {$_.name -like "*_" + $LastMonth + "*_Disk.csv"} | select name

ForEach ($cpu_csv in $cpu_csvs){
	$cpu_csv_file = "$Folder\" + $cpu_csv.name
	$cpu_content = import-csv $cpu_csv_file
	$cpu_average = [math]::Round((($cpu_content.cpu_usage | measure -average | select average).average),2)
	$cpu_split = $cpu_csv.name -split "_"
	$cpu_date = $cpu_split[1]
	$cpu_month = $cpu_date.substring(0,6)
	$cpu_month_file = "$Folder\$cpu_month" + "_CPU_avg.csv"
	"$cpu_date,$cpu_average" >> $cpu_month_file
}

ForEach ($mem_csv in $mem_csvs){
	$mem_csv_file = "$Folder\" + $mem_csv.name
	$mem_content = import-csv $mem_csv_file
	$mem_average = [math]::Round((($mem_content.Mem_usage | measure -average | select average).average),2)
	$mem_split = $mem_csv.name -split "_"
	$mem_date = $mem_split[1]
	$mem_month = $mem_date.substring(0,6)
	$mem_month_file = "$Folder\$mem_month" + "_Mem_avg.csv"
	"$mem_date,$mem_average" >> $mem_month_file
}

ForEach ($disk_csv in $disk_csvs){
	$disk_csv_file = "$Folder\" + $disk_csv.name
	$disk_content = import-csv $disk_csv_file
	$disk_C_max = ($disk_content.C_Drive_Usage | measure -max | select Maximum).Maximum
	$disk_D_max = ($disk_content.D_Drive_Usage | measure -max | select Maximum).Maximum
	$disk_split = $disk_csv.name -split "_"
	$disk_date = $disk_split[1]
	$disk_month = $disk_date.substring(0,6)
	$disk_month_file = "$Folder\$disk_month" + "_Disk_max.csv"
	"$disk_date,$disk_C_max,$disk_D_max" >> $disk_month_file
}

Compress-Archive -Path $Compress_csv -DestinationPath $Zip_File
Remove-Item -Path $Compress_csv
