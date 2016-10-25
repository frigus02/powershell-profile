function which
{
    (Get-Command $args[0]).Source
}

function e
{
    explorer.exe /e,$((Get-Location).Path)
}

$Env:PATH += ";C:\Program Files\Sublime Text 3"
