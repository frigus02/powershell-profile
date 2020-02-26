function base64([switch]$D)
{
    if ($D)
    {
        [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($input))
    }
    else
    {
        [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($input))
    }
}
