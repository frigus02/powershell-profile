function which
{
    (Get-Command $args[0]).Source
}

function e
{
    explorer.exe /e,$((Get-Location).Path)
}

function open
{
    if ($args.Length -eq 0)
    {
        start "."
    }
    else
    {
        start $args[0]
    }
}

# This is an easy way to call a command with environment
# variables, as we are used to from unix. Examples:
# - s NODE_ENV=production node .\server.js
# - s A=1 B=2 C=3 echo '"$Env:A + $Env:B = $Env:C"'
function s
{
    # Parse params
    $vars = @()
    for ($i = 0; $i -lt $args.Length; $i++)
    {
        if ($args[$i].Contains(" ") -or -not $args[$i].Contains("="))
        {
            break
        }

        $parts = $args[$i].Split("=")
        $vars += @{
            "name" = $parts[0]
            "value" = $parts[1]
        }
    }

    $command = [string]::Join(" ", $args[$i..$args.Length])

    # Set environment variables
    foreach ($var in $vars)
    {
        $var["old"] = Get-Item -Path "Env:$($var["name"])" -ErrorAction SilentlyContinue
        New-Item -Name $var["name"] -Path Env: -Value $var["value"] -Force | Out-Null
    }

    try
    {
        # Invoke command
        Invoke-Expression $command
    }
    finally
    {
        # Reset environment variables
        foreach ($var in $vars)
        {
            if ($var["old"])
            {
                New-Item -Name $var["name"] -Path Env: -Value $var["old"].Value -Force | Out-Null
            }
            else
            {
                Remove-Item -Path "Env:$($var["name"])"
            }
        }
    }
}
