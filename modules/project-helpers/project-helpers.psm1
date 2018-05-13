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

function Set-VisualStudioPath {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Path
    )
    process
    {
        Set-Variable -Name VISUAL_STUDIO_PATH -Value $Path -Option Constant -Scope Script
    }
}

function Set-EditorPath {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Path
    )
    process
    {
        Set-Variable -Name EDITOR_PATH -Value $Path -Option Constant -Scope Script
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

function Invoke-YarnStart {
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

        yarn start
    }
}

function Invoke-EditorForProject {
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

        $projects = @()
        $projects += ls $path\*.sublime-project | %{ $_.FullName }
        $projects += ls $path\*.sln, $path\*\*.sln | %{ $_.FullName }
        $projects += (Get-Item $path).FullName

        $project = $projects[0]
        if ($projects.Count -gt 2)
        {
            $project = $projects | Out-GridView -OutputMode Single
        }

        if ($project)
        {
            if ($project.EndsWith(".sublime-project"))
            {
                "Opening project $project in Sublime Text"
                subl --project $project
            }
            elseif ($project.EndsWith(".sln"))
            {
                "Opening project $project in Visual Studio"
                . $VISUAL_STUDIO_PATH $project
            }
            else
            {
                "Opening path $project in Editor"
                . $EDITOR_PATH $project
            }
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
            "Invoke-YarnStart",
            "Invoke-EditorForProject",
            "p",
            "ns",
            "ys",
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
Set-Alias -Name ys -Value Invoke-YarnStart
Set-Alias -Name edit -Value Invoke-EditorForProject

Export-ModuleMember Set-ProjectDirectory
Export-ModuleMember Set-VisualStudioPath
Export-ModuleMember Set-EditorPath
Export-ModuleMember Set-Project
Export-ModuleMember Invoke-NpmStart
Export-ModuleMember Invoke-YarnStart
Export-ModuleMember Invoke-EditorForProject
Export-ModuleMember TabExpansion
Export-ModuleMember -Alias p
Export-ModuleMember -Alias ns
Export-ModuleMember -Alias ys
Export-ModuleMember -Alias edit

#endregion
