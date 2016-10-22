function which
{
    (Get-Command $args[0]).Source
}

function e
{
    explorer.exe /e,$((Get-Location).Path)
}
