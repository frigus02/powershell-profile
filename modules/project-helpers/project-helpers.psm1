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
        if ($ProjectName)
        {
            $path = Get-ProjectPath $ProjectName
            $sublimeProjectFiles = ls $path\*.sublime-project
            if ($sublimeProjectFiles.Count -eq 1)
            {
                $sublimeProject = $sublimeProjectFiles[0].FullName
                "Opening project $sublimeProject in Sublime Text"
                subl --project $sublimeProject
            }
            else
            {
                "Opening path $path in Sublime Text"
                subl $path
            }
        }
        else
        {
            "Opening current folder in Sublime Text"
            subl "."
        }
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
        $commands = @(
            "Set-ProjectDirectory",
            "Set-Project",
            "Invoke-NpmStart",
            "Invoke-SublimeText",
            "p",
            "ns",
            "edit"
        )

        $words = $line.Split(" ")
        $command = $words[0]
        if ($words.Length -eq 2 -and $commands.Contains($command))
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

Set-Alias -Name p -Value Set-Project
Set-Alias -Name ns -Value Invoke-NpmStart
Set-Alias -Name edit -Value Invoke-SublimeText

Export-ModuleMember Set-ProjectDirectory
Export-ModuleMember Set-Project
Export-ModuleMember Invoke-NpmStart
Export-ModuleMember Invoke-SublimeText
Export-ModuleMember TabExpansion
Export-ModuleMember -Alias p
Export-ModuleMember -Alias ns
Export-ModuleMember -Alias edit

#endregion
