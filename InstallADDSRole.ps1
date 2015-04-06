###########################################################
# AUTHOR  : Alyushin Vladislav 
# DATE    : 22-02-2015 
# COMMENT : This script install Active Directory role,
# VERSION : 1.0
###########################################################
# ERROR REPORTING ALL
Set-StrictMode -Version latest
#Import PowerShell Module 
Try
{
Import-Module -Name ServerManager -ErrorAction
}
Catch
{
    Write-Host "[ERROR] Module couldn't be loaded. Script will stop!"
    Exit 1
}
#Input and Set hostname for DC machine
$hostname = Read-Host "Enter computer name"
Rename-Computer -ComputerName $hostname -Verbose 
#Install Windows Backup and SNMP Features
try
{
Install-WindowsFeature SNMP-Service, SNMP-WMI-Provider, Windows-Server-Backup -Verbose -Confirm
}
Catch
{
    Write-Host "[ERROR] Couldn't be install feature. Script will stop!"
}
#Input Domain Name
$dcname = Read-Host "Enter Domain Name"
#Input Password for Safe Mode AD 
$safepass = Read-Host "Enter Safe Mode Administrator Password"
#Path for log file
$log = Read-Host "Enter path for log file" + "\install.log"
#Install AD-DS role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Verbose
#Create forest and install ad dc,dns
Install-ADDSForest -domainname $dcname -CreateDnsDelegation -DomainMode Win2012R2 -ForestMode Win2012R2 -SafeModeAdministratorPassword $safepass -LogPath $log -Confirm -Verbose