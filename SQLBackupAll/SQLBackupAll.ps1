# CONFIG **********************************************************************

$BackupPath = "G:\SQLBackup\"
$SQLInstance = "DEFAULT"

$Log = "log.txt"
$ErrorActionPreference = "Continue"

#******************************************************************************


Try {
    Import-Module SQLPS
	Set-Location $(split-path -parent $MyInvocation.MyCommand.Definition) # Set working directory to script directory

    $Localhost = get-content env:computername
    $TodayDate = Get-Date -Format dd-MM-yyyy_HH-mm

    Foreach ($Database in $(Get-ChildItem SQLSERVER:\SQL\$Localhost\$SQLInstance\Databases)) {
		Try {
			$DBBackupPath = $($BackupPath+$Database.name+"\")
			$DBBackupFileName = "$($Database.name)_$($TodayDate).bak"
			
			If(!(Test-Path $DBBackupPath)) {
				New-Item -ItemType directory -Path $DBBackupPath
			}
			
			If ($SQLInstance -eq "DEFAULT") { 
				$ServerInstance = "$($localhost)"
			} Else {
				$ServerInstance = "$($localhost)\$($SQLInstance)" 
			}
			
			Backup-SqlDatabase -ServerInstance $ServerInstance -Database $Database.name -BackupFile $($DBBackupPath+$DBBackupFileName)
			"[$(get-date)] Backup OK: $($Database.name) -> $($DBBackupPath+$DBBackupFileName)" | Tee-Object $Log -Append
		} Catch {
			"[$(get-date)] Failed to Backup DB: $($Database.name)" | Tee-Object $Log -Append
		}
    }
} Catch {
    $_ | Tee-Object $Log -Append
}