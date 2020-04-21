<#
.SYNOPSIS
	Helper for working with JavaScript projects from the command line.
#>



using namespace System.Management.Automation
using namespace System.Management.Automation.Language



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
		$projects += ls $path\*.sln, $path\*\*.sln | %{ $_.FullName }
		$projects += (Get-Item $path).FullName

		$project = $projects[0]
		if ($projects.Count -gt 2)
		{
			$project = $projects | Out-GridView -OutputMode Single
		}

		if ($project)
		{
			if ($project.EndsWith(".sln"))
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

$completerScript = {
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	Get-ChildItem (Get-ProjectPath "$wordToComplete*") | ForEach-Object {
		[CompletionResult]::new($_.Name,$_.Name, [CompletionResultType]::Variable,$_.Name)
	}
}
Register-ArgumentCompleter -CommandName Set-Project -ParameterName ProjectName -ScriptBlock $completerScript
Register-ArgumentCompleter -CommandName Invoke-NpmStart -ParameterName ProjectName -ScriptBlock $completerScript
Register-ArgumentCompleter -CommandName Invoke-YarnStart -ParameterName ProjectName -ScriptBlock $completerScript
Register-ArgumentCompleter -CommandName Invoke-EditorForProject -ParameterName ProjectName -ScriptBlock $completerScript

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
Export-ModuleMember -Alias p
Export-ModuleMember -Alias ns
Export-ModuleMember -Alias ys
Export-ModuleMember -Alias edit

#endregion
