#######################################################################
#Aeolus Server Management Bootstrap
#2013.06.03  Marcel de Haas
#======================================================================
# CHANGELOG
#----------------------------------------------------------------------
# 2013.08.12 | MdH  | Initial release
#######################################################################

$ComputerName = $env:COMPUTERNAME.tolower()
$DomainName = $env:USERDNSDOMAIN.tolower()
#$DomainName = ((Get-NetConnectionProfile).Name).tolower()
$ScriptPath = Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path
$Year = (Get-Date).Year
$Identity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$Principal=new-object System.Security.Principal.WindowsPrincipal($Identity)
$Administrator=[System.Security.Principal.WindowsBuiltInRole]::Administrator
$IsElevated=$Principal.IsInRole($Administrator)

#Feedback for interactive run
Clear-Host
Write-Output "======================================================================="
Write-Output "PowerShell Bootstrap                         (c)2013-$Year, Company Name"
Write-Output "======================================================================="

If ($IsElevated) {
	#Load local config file
	[xml]$ConfigXML = Get-Content "$ScriptPath\config.xml"
	$PreviousServer = $ConfigXML.configuration.server
	Write-Output "Configuration server: $PreviousServer"

	#Update config file
	(new-object Net.WebClient).DownloadString(("https://" + $PreviousServer + "/config.xml")) | Out-File "$ScriptPath\config.xml"
  
	#Load updated settings
	[xml]$ConfigXML = Get-Content "$ScriptPath\config.xml"
	$CurrentServer = $ConfigXML.configuration.server
	If ($PreviousServer -ne $CurrentServer) {Write-Output "Configuration server update: $CurrentServer"}
  Write-Output "-----------------------------------------------------------------------"
  #Update Bootstrap
  (new-object Net.WebClient).DownloadString(("https://" + $CurrentServer + "/bootstrap.ps1")) | Out-File "$ScriptPath\bootstrap.ps1"

	#Retrieve script
  [xml]$ScriptXML = (new-object Net.WebClient).DownloadString(("https://" + $CurrentServer + "/script.xml.ps1"))
  $ScriptBlock = $ScriptXML.application.script."#cdata-section"
  

	#Execute Script
  Invoke-Expression $ScriptBlock
} Else {
	Write-Error "You are not executing from an elevated session"
}

Write-Output "======================================================================="