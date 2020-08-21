# PowerShell Profile

This contains my personal PowerShell profile. It's inspired by Matt McNabb, who explains how he setup his profile in the blog post [Take Your Powershell Profile on the Road](http://mattmcnabb.github.io/portable-profile).

## Prerequisites

Install Starship prompt:

```posh
scoop install sharship
```

## Usage

Clone the repository and create a PowerShell profile with the follwing content:

```posh
# Import profile
. "C:\repos\powershell-profile\profiles\default.ps1"

# Configure project directory for project-helpers module
Set-ProjectDirectory -Directory "C:\repos"
Set-VisualStudioPath -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio 2015.lnk"
Set-EditorPath -Path "code"
```

To find the location of your profile file, open a PowerShell window and print the variable `$PROFILE`. If the referenced file does not exist yet, just create it. More information can be found in the post [Understanding the six Windows PowerShell profiles](https://blogs.technet.microsoft.com/heyscriptingguy/2012/05/21/understanding-the-six-powershell-profiles/).

## More useful modules

### Docker

```posh
Install-Module -Scope CurrentUser DockerCompletion
```

### Bash Completions

```posh
# Install
Install-Module -Scope CurrentUser PSBashCompletions

# Completions
((kubectl completion bash) -join "`n") | Set-Content -Encoding ASCII -NoNewline -Path $env:USERPROFILE\Documents\WindowsPowerShell\kubectl_completions.sh

# Use in profile
Import-Module PSBashCompletions
Register-BashArgumentCompleter kubectl $env:USERPROFILE\Documents\WindowsPowerShell\kubectl_completions.sh
Set-Alias k kubectl
Register-BashArgumentCompleter k $env:USERPROFILE\Documents\WindowsPowerShell\kubectl_completions.sh
```
