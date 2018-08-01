$ScriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$RepoPath = Split-Path -Path $ScriptPath -Parent

# Extend the module path to include this repository
$Env:PSModulePath += ";$RepoPath\modules"

# Import modules and scripts
Import-Module posh-git
Import-Module project-helpers

. "$RepoPath\aliases\all.ps1"
. "$RepoPath\aliases\android.ps1"

# Prompt
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host($pwd.ProviderPath) -nonewline

    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}
