$ScriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$RepoPath = Split-Path -Path $ScriptPath -Parent

# Modules from this repo
$Env:PSModulePath += ";$RepoPath\modules"
Import-Module project-helpers

# Test SSH agent config
$sshAgent = Get-Service ssh-agent -ErrorAction Ignore
if ($sshAgent) {
	if ($sshAgent.StartType -eq "Disabled" -or
		$sshAgent.Status -ne "Running") {
		Write-Host "The ssh-agent service is not running. Set the service to automatic and try again."
	} else {
		$sshCommand = (Get-Command ssh.exe -ErrorAction Ignore | Select-Object -ExpandProperty Path).Replace("\", "/")
		$configuredSshCommand = git config --global core.sshCommand
		if ($sshCommand -ne $configuredSshCommand) {
			Write-Host "git is not configured to use the native ssh command. To fix run:"
			Write-Host "    git config --global core.sshCommand $sshCommand"
		}
	}
}

# Aliases
. "$RepoPath\aliases\all.ps1"
. "$RepoPath\aliases\base64.ps1"
. "$RepoPath\aliases\clipboard.ps1"
. "$RepoPath\aliases\hyper-v.ps1"
. "$RepoPath\aliases\js.ps1"

# Prompt
Invoke-Expression (&starship init powershell)
