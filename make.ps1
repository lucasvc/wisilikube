param(
    $_Command
)

if (!$_Command) {
    foreach($_ in Get-ChildItem $PSScriptRoot\Command -Name) {
        [System.IO.Path]::GetFileNameWithoutExtension($_)
    }
    return
}

& "$PSScriptRoot\Command\$_Command.ps1" @args
