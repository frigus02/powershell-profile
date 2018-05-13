function disable-hyper-v
{
    bcdedit /set hypervisorlaunchtype off
}

function enable-hyper-v
{
    bcdedit /set hypervisorlaunchtype auto
}
