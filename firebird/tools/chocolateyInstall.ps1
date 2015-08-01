[CmdletBinding()]
Param([Switch]$Uninstall)

$packageName = 'firebird'
$packageVersion = '2.5.4'
$installerType = 'exe'

$url = 'http://downloads.sourceforge.net/project/firebird/firebird-win32/2.5.4-Release/Firebird-2.5.4.26856_0_Win32.exe'
$url64 = 'http://downloads.sourceforge.net/project/firebird/firebird-win64/2.5.4-Release/Firebird-2.5.4.26856_0_x64.exe'
$installerName = 'Firebird-2.5.4.26856.exe'

function Get-FirebirdPath {
    $HKLMFirebirdInstancesKey = 'HKLM:\Software\Firebird Project\Firebird Server\Instances'
    $instances = Get-ItemProperty -Path "$HKLMFirebirdInstancesKey" -ErrorAction SilentlyContinue

    if (-not $instances) {
        # Not found. Try to search for a 32-bit install in a 64-bit architecture.

        $HKLMFirebirdInstancesKey = 'HKLM:\Software\Wow6432Node\Firebird Project\Firebird Server\Instances'
        $instances = Get-ItemProperty -Path "$HKLMFirebirdInstancesKey" -ErrorAction SilentlyContinue
    }

    if ($instances) {
        $instances.DefaultInstance
    } else {
        $null
    }
}

# --- Main ---

if (-not $Uninstall) {
    # Download installer into TEMP folder
    $installerFullName = Join-Path $env:TEMP $installerName
    Get-ChocolateyWebFile $packageName $installerFullName $url $url64
}
    


# Firebird already installed?
$firebirdPath = Get-FirebirdPath
if ($firebirdPath) {
    # Stop service
    Write-Host '* Stopping Firebird service...'
    Stop-Service FirebirdServerDefaultInstance -ErrorAction SilentlyContinue

    # Uninstall
    $uninstallers = Join-Path $firebirdPath 'unins*.exe'
    $lastUninstaller = Get-Item $uninstallers | Sort-Object LastWriteTime | Select-Object -Last 1
    $uninstallerArgs = '/VERYSILENT',
                        '/NORESTART',
                        '/SUPPRESSMSGBOXES'
        
    Uninstall-ChocolateyPackage $packageName $installerType $uninstallerArgs $lastUninstaller.FullName
}



if (-not $Uninstall) {
    # Install SuperClassic server, without Guardian, without Control Panel Applet and copy gds32.dll into System folder
    $installerArgs = '/SP-', 
                        '/VERYSILENT', 
                        '/NORESTART',
                        '/NOICONS',
                        '/SUPPRESSMSGBOXES',
                        '/COMPONENTS="ServerComponent,ServerComponent\ClassicServerComponent,DevAdminComponent,ClientComponent"',
                        '/TASKS="SuperClassicTask,|UseGuardianTask,UseServiceTask,AutoStartTask,|InstallCPLAppletTask,|MenuGroupTask,|CopyFbClientToSysTask,CopyFbClientAsGds32Task"'

    Install-ChocolateyInstallPackage $packageName $installerType $installerArgs $installerFullName
        
    $firebirdPath = Get-FirebirdPath
    if ($firebirdPath -eq $null) {
        throw "Firebird *WAS NOT* successfully installed."
    }
} else {
    # Reinstall client 
    $here = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $installScript = Join-Path $here "..\..\firebirdclient\tools\chocolateyInstall.ps1"

    if (Test-Path $installScript) {
        & $installScript
    }
}
