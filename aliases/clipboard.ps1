function pbcopy
{
    clip
}

function pbpaste
{
    Add-Type -Path 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Windows.Forms.dll'
    [System.Windows.Forms.Clipboard]::GetText()
}
