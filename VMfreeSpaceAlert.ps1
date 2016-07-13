# VM Free Space Alert 
# July 2016 Hamdi OZCAN http://ozcan.com
#
# task schedule 
# C:\WINDOWS\system32\windowspowershell\v1.0\powershell.exe -file C:\PowerCLI\VMfreeSpaceAlert.ps1

add-pssnapin VMware.VimAutomation.Core
Connect-VIServer vcenterHostName

$outArray = @()
$Output2 = ""

ForEach ($VM in Get-VM | where-object {($_.powerstate -ne "PoweredOff") -and ($_.Extensiondata.Guest.ToolsStatus -Match ".*Ok.*")})
{
ForEach ($Drive in $VM.Extensiondata.Guest.Disk) 
{

#Do not consider P drive
if ($Drive.DiskPath -eq "P:\") { break }

$Path = $Drive.DiskPath

#Calculations  
$Freespace = [math]::Round($Drive.FreeSpace / 1MB)
$Capacity = [math]::Round($Drive.Capacity/ 1MB)

$SpaceOverview = "$Freespace" + "/" + "$capacity"  
$PercentFree = [math]::Round(($FreeSpace)/ ($Capacity) * 100)  

if ($PercentFree -lt 10) 
{
    $Output = "" | Select "VM","Disk","FreeMB","FreePER" 
    $Output.VM = $VM.Name
    $Output.Disk = $Path
    $OutPut.FreeMB = $Freespace
    $Output.FreePER = $PercentFree

    $Output2 = $Output2 + "Vm: " + $VM.Name + "`n"
    $Output2 = $Output2 + "Disk: " + $Path + "`n"
    $OutPut2 = $Output2 + "Free(MB): " + $Freespace + "`n"
    $Output2 = $Output2 + "Free(%): " + $PercentFree + "`n`n"  
}

if ($Output) { $outarray += $Output }
$Output = $null

} 
}

if ($outarray) {$outarray | Export-Csv "C:\PowerCLI\VMfreeSpaceAlert.csv"}
if ($Output2) {send-mailmessage -to "mailme@mailme.com" -from "VM FreeSpace <vcenter@vcenter.local>" -subject "VM Free Space Alert <%10" -body $Output2 -Attachments "C:\PowerCLI\VMfreeSpaceAlert.csv" -smtpServer mail.mailserver.com}

Disconnect-VIServer -Force -Confirm:$false
Remove-PSSnapin -Name VMWare.VimAutomation.Core
