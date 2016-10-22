# PowerShell Profile

This contains my personal PowerShell profile. It's inspired by Matt McNabb, who explains how he setup his profile in the blog post [Take Your Powershell Profile on the Road](http://mattmcnabb.github.io/portable-profile).

## Prerequisites

Install the following modules from the [PowerShell Gallery](https://msconfiggallery.cloudapp.net/):

```posh
Install-Module posh-git
Install-Module posh-docker
```

## Usage

Clone the repository and create a PowerShell profile with the follwing content:

```posh
# Import profile
. "C:\repos\powershell-profile\profiles\default.ps1"

# Configure project directory for project-helpers module
Set-ProjectDirectory -Directory "C:\repos"
```
