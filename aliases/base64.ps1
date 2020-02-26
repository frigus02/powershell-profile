function base64([switch]$D)
{
    if ($D)
    {
        [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($input))
    }
    else
    {
        [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($input))
    }
}
