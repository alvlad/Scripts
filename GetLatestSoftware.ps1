<#
.Synopsis
   Download latest version software
.DESCRIPTION
   This script downloaded latest build software, such as Adobe Flash Player, Google Chrome, Mozilla Firefox, Java, Foxit Reader and etc
.EXAMPLE
   .\GetLatestSoftware
#>

# Set folder for downloaded files
$downloadFolder = ""
$downloadFolderTemp = ""

# Test source folder
if (Test-Path $downloadFolder)
{
    Write-Host "Source folder exist" -ForegroundColor Green
}
else
{
    Write-Host "Not access to source folder with software" -ForegroundColor Red
    Exit
}

# Set Proxy Address 
$UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox
$proxyAddr = ''
$proxy = new-object System.Net.WebProxy
$proxy.Address = $proxyAddr
$proxy.useDefaultCredentials = $true          


function Get-LatestFirefox()
{
    $pathfirefox = "$downloadFolder\firefox\"

    $softwareUrlFirefox = @{f64 = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=ru"; f86 = "https://download.mozilla.org/?product=firefox-latest&os=win&lang=ru"}
    
    try
    {
        #Delete old version
        Get-ChildItem -Path $pathfirefox -Include *.* -File -Recurse | foreach { $_.Delete()}

        foreach ($item in $softwareUrlFirefox.GetEnumerator())
        {

          Write-Host "Download latest build Mozilla Firefox" -ForegroundColor Green

          Invoke-WebRequest -Uri $item.Value -Proxy $proxyAddr -ProxyUseDefaultCredentials -UserAgent $UserAgent  -OutFile ("$downloadFolder\firefox\" + $item.Name +".exe")

          Write-Host "Downloaded latest firefox is success" -ForegroundColor Green

        }
    }

    catch
    {
        Write-Host $Error -ForegroundColor Red
    }
    
}

function Get-AdobeFlash ()
{
  # Get url release 
  $releases = "https://get.adobe.com/en/flashplayer/" # URL to for GetLatest
 
  # Parsing html page, get current version 
  $HTML = Invoke-WebRequest -Uri $releases -Proxy $proxyAddr -ProxyUseDefaultCredentials 
  $try = ($HTML.ParsedHtml.getElementsByTagName('p') | Where{ $_.className -eq 'NoBottomMargin' } ).innerText
  $try = $try  -split "\r?\n"
  $try = $try[0] -replace ' ', ' = '
  $try =  ConvertFrom-StringData -StringData $try
  $CurrentVersion = ( $try.Version )
  $majorVersion = ([version] $CurrentVersion).Major
 
  # Flash Player Active X
  $softwareAdobeUrl = @()
  $softwareAdobeUrl += "https://download.macromedia.com/pub/flashplayer/pdc/${CurrentVersion}/install_flash_player_${majorVersion}_active_x.msi"
  $softwareAdobeUrl += "https://download.macromedia.com/get/flashplayer/pdc/${CurrentVersion}/install_flash_player_${majorVersion}_plugin.msi"
  $softwareAdobeUrl += "https://download.macromedia.com/pub/flashplayer/pdc/${CurrentVersion}/install_flash_player_${majorVersion}_ppapi.msi"
  
  $CurrentVersion
  $softwareAdobeUrl
 
 Write-Host $true
 #$_.New = $CurrentVersion 
 
 # create folder, download msi
 New-Item -ItemType Directory -Path "$downloadFolder\adobe\" -Force
 $targetDir = "$downloadFolder\adobe\"       
      
 $wc = New-Object System.Net.WebClient            
 $wc.Proxy = $proxy

 $sourceFiles = $softwareAdobeUrl
 
 foreach ($sourceFile in $sourceFiles)
 {            
    $sourceFileName = $sourceFile.SubString($sourceFile.LastIndexOf('/')+1)            
    $targetFileName = $targetDir + $sourceFileName            
    $wc.DownloadFile($sourceFile, $targetFileName)            
    Write-Host "Downloaded $sourceFile to file location $targetFileName"             
 }            
 
}      

function Get-LatestJava ()
{
    $pathjava = "$downloadFolder\java"

    
    $softJavaUrl = @{ 'jre-windows-x86' = "http://javadl.oracle.com/webapps/download/AutoDL?BundleId=227550_e758a0de34e24606bca991d704f6dcbf"; 'jre-windows-x64' = "http://javadl.oracle.com/webapps/download/AutoDL?BundleId=227552_e758a0de34e24606bca991d704f6dcbf"}

    try
    {
        #Delete old version
        Get-ChildItem -Path $pathjava -Include *.* -File -Recurse | foreach { $_.Delete() }

        foreach ($item in $softJavaUrl.GetEnumerator())
        {
            
            Write-Host "Download latest Java build" -ForegroundColor Green
            
            Invoke-WebRequest -Uri $item.Value -Proxy $proxyAddr -ProxyUseDefaultCredentials -UserAgent $UserAgent -OutFile ("$downloadFolder\Java\" + $item.Name + ".exe")
            
            Write-Host "Downloaded latest Java is success" -ForegroundColor DarkGreen 

        }
    }
    catch
    {
        Write-Host $Error -ForegroundColor Red
    }
}

function Get-LatestChromeEnt ()
{
    $pathchrome = "$downloadFolder\chrome"

    $softChromeURL = @{
        'googlechromestandaloneenterprise64.msi' = "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi";
        'googlechromestandaloneenterprise.msi' = "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise.msi"
        }


    try
    {
        #Delete old version
        Get-ChildItem -Path $pathchrome -Include *.* -File -Recurse | foreach { $_.Delete() }

        foreach ($item in $softChromeURL.GetEnumerator())
        {

            Write-Host "Download latest Chrome Enterprise build" -ForegroundColor Green
            
            Invoke-WebRequest -Uri $item.Value -Proxy $proxyAddr -ProxyUseDefaultCredentials -UserAgent $UserAgent -OutFile ("$downloadFolder\Chrome\"+$item.Name)

            Write-Host "Downloaded latest Chrome Enterprise is success" -ForegroundColor Green 

        }
    }
    catch
    {
        Write-Host $Error -ForegroundColor Red
    }

}

function Get-StableSevenZip ()
{
    $pathSevenZip = "$downloadFolder\7zip"

    try
    {

        # Get latest stable build 
        $WebResponse = Invoke-WebRequest -Uri "http://7-zip.org/" -Proxy $proxyAddr -ProxyUseDefaultCredentials

        # Get link for file
        $soft7zipURL = $WebResponse.Links | Where { $_.innerHTML -eq 'Download' -and $_.class -notcontains 'MenuLink'} | Select href
        

        # Download file for x64 and x86 
        foreach ($item in $soft7zipURL.href)
        {
            $sourceFileName = $item.Substring($item.LastIndexOf('/')+1)

            if (Test-Path -Path $downloadFolder\7zip\$sourceFileName)
            {

              Write-Host "This version $sourceFileName is already downloaded" -ForegroundColor Green

            }
            else
            {
              #Delete old version
              Get-ChildItem -Path $pathSevenZip -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt (Get-Date).AddMinutes(-1) } | Remove-Item -Force

              $ZipURL = "http://7-zip.org/$item"
  
              Invoke-WebRequest -Uri $ZipURL -Proxy $proxyAddr -ProxyUseDefaultCredentials -UserAgent $UserAgent -OutFile "$downloadFolder\7zip\$sourceFileName"

            }
        }
    }
    catch
    {
        Write-Host $Error -ForegroundColor Red
    }
   
}

function Get-StableFoxitReader ()
{
    $pathFoxit = "$downloadFolder\Foxit"
    
    $currentVersion = (Get-Item -Path "$pathFoxit\Foxit.exe").VersionInfo.FileVersion.Trim()
    
    # URL with latest build Foxit Reader
    $softFoxitUrl = "https://www.foxitsoftware.com/ru/downloads/latest.php?product=Foxit-Reader&platform=Windows&language=Russian"


    try
    {

        # Download latest build Foxit Reader
        Invoke-WebRequest -Uri $softFoxitUrl -Proxy $proxyAddr -ProxyUseDefaultCredentials -UserAgent $UserAgent -OutFile "$downloadFolderTemp\Foxit.exe"

        # Get current major version 
        $downloadFileVersion  = (Get-Item $downloadFolderTemp\Foxit.exe).VersionInfo.Fileversion.Trim()

        # We check the version if at us is older, then we copy new in the folder of the application
        if ($currentVersion -ne $downloadFileVersion)
        {
            Copy-Item -Path $downloadFolderTemp\Foxit.exe -Destination $pathFoxit
        }
        else
        {
           Write-Host "This version $currentVersion is already downloaded" -ForegroundColor Green
        }
        
        # Clear temp folder 
        Remove-Item -Path "$downloadFolderTemp\Foxit.exe"

    }
    catch
    {
        Write-Host $Error
    }
}

Write-Host "Ok. We start download latest build" -ForegroundColor DarkGreen
#Get-LatestFirefox
#Get-AdobeFlash
#Get-LatestJava
Get-LatestChromeEnt
#Get-StableSevenZip
#Get-StableFoxitReader
# SIG # Begin signature block
# MIINuQYJKoZIhvcNAQcCoIINqjCCDaYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4ldtgo0+v6N6kH6TvvZ5B/z5
# s7qgggsfMIIEITCCAwmgAwIBAgITXQAAAAZkag0IOEQjiQAAAAAABjANBgkqhkiG
# 9w0BAQsFADAXMRUwEwYDVQQDEwxNUlNLIFJPT1QtQ0EwHhcNMTcxMDE2MTEzODM4
# WhcNMzIxMDE2MDU0NzMwWjBMMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxFjAUBgoJ
# kiaJk/IsZAEZFgZtcnNrLWMxGzAZBgNVBAMTEk1SU0sgRW50ZXJwcmlzZSBDQTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKklQi4Opw7d6sMts+CogPNj
# hk4B8hlS4zR/M3t+ZXLTIt8wMPq/nmv7c8v4Rfm9UjK9YbFGcEXLAXuC4z6Prx2w
# 7A0HUtmQpU7sKw6ELPQr5eoAwgdi2zFix8BOMV5gwbwR6nOV3yKgczOq+adKCe0b
# dNrIFIA6VDkdIKOVHdwomRtgY5B9hEqKMPECUfEx9KKvp3IS+CEUQ++iFIWau/tc
# yWGzF96la5VOqFQytntQamdh3fl0FRgIyDI6BP3xZELYh/HOlxu3MnFuc0bRnQaN
# piJH9uZgRfPjSxoTR4uQArY9YlQn9FZ19zANz30fI56/ANk7yWijKeFOfZMqaN8C
# AwEAAaOCAS8wggErMBIGCSsGAQQBgjcVAQQFAgMCAAIwIwYJKwYBBAGCNxUCBBYE
# FOAwInaJ9BGg7vK/h3RzEgaxKVzNMB0GA1UdDgQWBBQD/2CeRsQRgwlUyhfB2ri7
# EPMpIDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTyM710olSq005SfYnmZU7Kzg/5lDA1
# BgNVHR8ELjAsMCqgKKAmhiRodHRwOi8vY2EubXJzay0xLnJ1L3BraS9NcnNrX1JD
# QS5jcmwwQAYIKwYBBQUHAQEENDAyMDAGCCsGAQUFBzAChiRodHRwOi8vY2EubXJz
# ay0xLnJ1L3BraS9NcnNrX1JDQS5jcnQwDQYJKoZIhvcNAQELBQADggEBADOWXvTa
# FllhmlFYYL6leJU10C69dP2Hx7ACqt3Cg5I+BZyMzcg44eV33YUO9Y7vFe4A+yNq
# MgQHWy9OBdFerv5yMw3fmZeCu1sdA/f6Bc6xxWN1Byz1aEam37l2iVzrsMJgbDeg
# z40k0f97/XtdI2GytCC3r0s8GhowN5bEZcyEZzxCXfd9Rh8r9+kNqPD8k5CYKd3c
# EZXwHWjm420Yf206NjMOo3SXzXXjJ2NcI5eGCuU2zaKgCXYT8WScTRqpgxJunbCf
# IwvIk0S+VRG/JNsJG8eoh8iTkvnDqLBYuUnQEArImwdIPSQXrFEuj0wmg7+N5G2N
# fdLZRBxdMBAbH6swggb2MIIF3qADAgECAhN6AAAAH4JfeZpM7qocAAIAAAAfMA0G
# CSqGSIb3DQEBCwUAMEwxFTATBgoJkiaJk/IsZAEZFgVsb2NhbDEWMBQGCgmSJomT
# 8ixkARkWBm1yc2stYzEbMBkGA1UEAxMSTVJTSyBFbnRlcnByaXNlIENBMB4XDTE3
# MTAzMDA2NTgzMVoXDTE4MTAzMDA2NTgzMVowggJ5MRUwEwYKCZImiZPyLGQBGRYF
# bG9jYWwxFjAUBgoJkiaJk/IsZAEZFgZtcnNrLWMxITAfBgNVBAsMGNCf0L7Qu9GM
# 0LfQvtCy0LDRgtC10LvQuDElMCMGA1UECwwc0JHQtdC70LPQvtGA0L7QtNCt0L3Q
# tdGA0LPQvjE9MDsGA1UECww00JjRgdC/0L7Qu9C90LjRgtC10LvRjNC90YvQuSDQ
# sNC/0L/QsNGA0LDRgiDQnNCg0KHQmjFjMGEGA1UECwxa0JTQtdC/0LDRgNGC0LDQ
# vNC10L3RgiDQutC+0YDQv9C+0YDQsNGC0LjQstC90YvRhSDQuCDRgtC10YXQvdC+
# 0LvQvtCz0LjRh9C10YHQutC40YUg0JDQodCjMU8wTQYDVQQLDEbQo9C/0YDQsNCy
# 0LvQtdC90LjQtSDQuNC90YTQvtGA0LzQsNGG0LjQvtC90L3Ri9GFINGC0LXRhdC9
# 0L7Qu9C+0LPQuNC5MU4wTAYDVQQLDEXQntGC0LTQtdC7INC/0YDQvtCz0YDQsNC8
# 0LzQvdC+LdCw0L/Qv9Cw0YDQsNGC0L3Ri9GFINC/0LvQsNGC0YTQvtGA0LwxdDBy
# BgNVBAsMa9Ch0LXQutGC0L7RgCDRg9C/0YDQsNCy0LvQtdC90LjRjyDQsNC/0L/Q
# sNGA0LDRgtC90YvQvNC4INC4INC/0YDQvtCz0YDQsNC80LzQvdGL0LzQuCDQv9C7
# 0LDRgtGE0L7RgNC80LDQvNC4MUMwQQYDVQQDDDrQkNC70Y7RiNC40L0g0JLQu9Cw
# 0LTQuNGB0LvQsNCyINCQ0LvQtdC60YHQsNC90LTRgNC+0LLQuNGHMIIBIjANBgkq
# hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzrkd5iev1Id3GOVay2Q6iyU7LU1r1wcO
# AY+dGKpA2aj/Vx66dCR0dlZkXjC2qpr9BTUxU17gW8hioZ0WOF60VKk8PXqGcwYO
# 7++FNTE1UmeI6gqH4zgWvg2KZjy96Qr7AJMQr4CKqxQpo62l4AjeBh6Z9rjbBZRz
# b5bgzeXONzpcrMcum93F5KjZG487MYbe5LiwwjinSVDu5cTOTUnYCYmE5j6E6UWD
# wszF5WSqU3UfEp6ZUIDkYFlwvA1cUab2v/SonFJnUISHgs9zXys+JVfYtdrDVEVD
# EIUpTE4V+B9HckIcJ8K+ST1rZw8PLwzNEwvYfizCsv9SGEFRb4KPBQIDAQABo4IB
# oDCCAZwwPQYJKwYBBAGCNxUHBDAwLgYmKwYBBAGCNxUIgbnfdoXOhGiD/Zcqg9fp
# Aobiy1kphMraf4LblUwCAWQCAQMwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0P
# AQH/BAQDAgeAMBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYE
# FEhUH0bswC0M/H2VANVwsc5ny/fwMB8GA1UdIwQYMBaAFAP/YJ5GxBGDCVTKF8Ha
# uLsQ8ykgMDkGA1UdHwQyMDAwLqAsoCqGKGh0dHA6Ly9jYS5tcnNrLTEucnUvcGtp
# L01yc2tTdWJDQSgyKS5jcmwwaQYIKwYBBQUHAQEEXTBbMFkGCCsGAQUFBzAChk1o
# dHRwOi8vY2EubXJzay0xLnJ1L3BraS9tc2stc3J2LWNhLm1yc2stYy5sb2NhbF9N
# UlNLJTIwRW50ZXJwcmlzZSUyMENBKDIpLmNydDAzBgNVHREELDAqoCgGCisGAQQB
# gjcUAgOgGgwYQWx5dXNoaW4uVkFAbXJzay1jLmxvY2FsMA0GCSqGSIb3DQEBCwUA
# A4IBAQARU8aRaJFXSP9TbiwyjjsRNazi9ip2nFDFXinJ77HFsi54JlIxphVqaZQl
# n8/sWKlFrk2pyyzyxw3NffQ48PCbHHRyhcFaGCfZzfese0OdMMzZWQxybWa/kONr
# s2H+FrsEgBe4E+t4I1qoInbTJ8Y/b9aKA64JLTfxvsf6NtfufHayTcjTms/3ndvJ
# nPt2kUsUcGS5n2CXE9w9Nq2I4xwRQocYtFGMj9rE6roNmqncFACt80TMhTgfxQkd
# GlKMMIDQujAm6aqx/Ys3ruqeeYx7d0qcuKn8xoP/UqMw0zGhXv7TJucvA7hN31zG
# zG9/HiwmpGVA/QyfgjaMWk9FOFTpMYICBDCCAgACAQEwYzBMMRUwEwYKCZImiZPy
# LGQBGRYFbG9jYWwxFjAUBgoJkiaJk/IsZAEZFgZtcnNrLWMxGzAZBgNVBAMTEk1S
# U0sgRW50ZXJwcmlzZSBDQQITegAAAB+CX3maTO6qHAACAAAAHzAJBgUrDgMCGgUA
# oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
# CQQxFgQUAZUYHMKoOCwb2TDZyOWuUaNwWGUwDQYJKoZIhvcNAQEBBQAEggEAXPq/
# zRWuUpzDC1w80mP0h7qyjlalFR8lsygdk9WfUdiLICscey/rkQvHzQYiFzQ4UOgK
# 2f1mwEGFF0wAfhZl5ozztwLXb4F0l4fLghBIueKE37vBbx3CX88H8v54+26fz0HK
# 5iKdpudKN2RvX2gBSxFnqlnogQF3FqcldUegmBiqI8EonOGpW5pk85tbKt8BvYrk
# Kxxfgk6GlhlwaVl4Rmkuq/W18PBv1uiXxd64TaBjtLwJXr8EvTNqS0YS8tn8C42N
# Scp5CRE0tziLaKm1leU/rQ1X0mZ40SNdwdq1GXkSNbmDTj4ps5WYocbslPt1duD4
# OX75UP17eUtg03JAQQ==
# SIG # End signature block
