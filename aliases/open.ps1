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
