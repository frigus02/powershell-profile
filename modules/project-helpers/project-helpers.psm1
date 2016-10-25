<#
.SYNOPSIS
    Helper for working with JavaScript projects from the command line.
#>



#region Setup

function Get-ProjectPath([string]$ProjectName)
{
    return Join-Path -Path $PROJECTS_DIRECTORY -ChildPath $ProjectName
}

#endregion



#region Exported Cmdlets

function Set-ProjectDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Directory
    )
    process
    {
        Set-Variable -Name PROJECTS_DIRECTORY -Value $Directory -Option Constant -Scope Script
    }
}

function Set-Project {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $ProjectName
    )
    process
    {
        cd (Get-ProjectPath $ProjectName)
    }
}

function Invoke-NpmStart {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$false)]
        [string] $ProjectName
    )
    process
    {
        if ($ProjectName)
        {
            Set-Project -ProjectName $ProjectName
        }

        npm start
    }
}

function Invoke-SublimeText {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$false)]
        [string] $ProjectName
    )
    process
    {
        $path = "."
        if ($ProjectName)
        {
            $path = Get-ProjectPath $ProjectName
        }

        subl $path
    }
}

#endregion



#region TabExpansion

# Backup old tabexpansion
$tabExpansionBackup = 'ProjectHelpers_DefaultTabExpansion'
if ((Test-Path -Path Function:\TabExpansion -ErrorAction SilentlyContinue) -and -not (Test-Path -Path Function:\$tabExpansionBackup -ErrorAction SilentlyContinue))
{
    Rename-Item -Path Function:\TabExpansion $tabExpansionBackup -ErrorAction SilentlyContinue
}

# Revert old tabexpansion when module is unloaded
$Module = $MyInvocation.MyCommand.ScriptBlock.Module
$Module.OnRemove = {
    Write-Debug 'Revert tab expansion back'
    Remove-Item -Path Function:\TabExpansion -ErrorAction SilentlyContinue
    if (Test-Path -Path Function:\$tabExpansionBackup)
    {
        Rename-Item -Path Function:\$tabExpansionBackup Function:\TabExpansion
    }
}

function TabExpansion
{
    [CmdletBinding()]
    param (
        [String] $line,
        [String] $lastWord
    )
    process
    {
        if ($line -eq "Invoke-NpmStart $lastWord" -or $line -eq "ns $lastWord" -or `
            $line -eq "Invoke-SublimeText $lastWord" -or $line -eq "s $lastWord" -or `
            $line -eq "Set-Project $lastWord" -or $line -eq "n $lastWord")
        {
            Get-ChildItem (Get-ProjectPath "$lastWord*") | %{ $_.Name } | sort -Unique
        }
        elseif (Test-Path -Path Function:\$tabExpansionBackup)
        {
            & $tabExpansionBackup $line $lastWord
        }
    }
}

#endregion



#region Module Interface

Set-Alias -Name n -Value Set-Project
Set-Alias -Name ns -Value Invoke-NpmStart
Set-Alias -Name s -Value Invoke-SublimeText

Export-ModuleMember Set-ProjectDirectory
Export-ModuleMember Set-Project
Export-ModuleMember Invoke-NpmStart
Export-ModuleMember Invoke-SublimeText
Export-ModuleMember TabExpansion
Export-ModuleMember -Alias n
Export-ModuleMember -Alias ns
Export-ModuleMember -Alias s

#endregion
