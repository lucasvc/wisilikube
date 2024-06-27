param(
    $_Command
)

if (!$_Command) {
    "No command provided, please use one of the followings,"
    foreach($_ in Get-ChildItem $PSScriptRoot\Command -File -Name -Filter *.ps1) {
        "    " + [System.IO.Path]::GetFileNameWithoutExtension($_)
    }
    return
}

& "$PSScriptRoot\Command\$_Command.ps1" @args
