param (
    [string]$UbuntuMajor = "22", # TODO LTS
    [string]$UbuntuMinor = "04", # TODO LTS
    [string]$UbuntuPatch = "4", # TODO last
                                # https://changelogs.ubuntu.com/meta-release
    [string]$Destination
)

If ([string]::IsNullOrEmpty(${env:USERNAME})) {
    "ERROR: Required environment variable `USERNAME` not found (value=${env:USERNAME})"
    exit 1
}

$UbuntuCodeName = "jammy"   # TODO resolve from number
                            # https://changelogs.ubuntu.com/meta-release
$UbuntuInstall = "server"   # TODO review if other install flavor works

If ([string]::IsNullOrEmpty(${Destination})) {
    $Destination = "."
}
else {
    $Current = pwd
    Copy-Item Command\Install\${UbuntuInstall}.sh ${Destination}\install
    cd ${Destination}
}

$UbuntuPackageDownload = @{
    server = [pscustomobject]@{
            RootFs = "ubuntu-${UbuntuMajor}.${UbuntuMinor}-server-cloudimg-amd64-root.tar.xz"
            Uri = "https://cloud-images.ubuntu.com/releases/${UbuntuMajor}.${UbuntuMinor}/release"
    };
    base = [pscustomobject]@{
            RootFs = "ubuntu-base-${UbuntuMajor}.${UbuntuMinor}.${UbuntuPatch}-base-amd64.tar.gz"
            Uri = "https://cdimage.ubuntu.com/ubuntu-base/releases/${UbuntuMajor}.${UbuntuMinor}/release"
    };
    minimal = [pscustomobject]@{
            RootFs = "ubuntu-${UbuntuMajor}.${UbuntuMinor}-minimal-cloudimg-amd64-root.tar.xz"
            Uri = "https://cloud-images.ubuntu.com/minimal/releases/${UbuntuCodeName}/release"
    }
}
$UbuntuRootfs = ${UbuntuPackageDownload}.${UbuntuInstall}.RootFs
$UbuntuUri = ${UbuntuPackageDownload}.${UbuntuInstall}.Uri
Invoke-WebRequest -Uri "${UbuntuUri}/${UbuntuRootFs}" -OutFile .
wsl --import --version 2 wisilikube ${Destination} ${UbuntuRootfs}

pwsh -Command { `
    $env:WSLENV=$env:WSLENV+":USERNAME/u"; `
    wsl -d wisilikube bash -c "chmod +x install && ./install wsl" && `
    wsl --shutdown && `
    wsl -d wisilikube bash -c "./install user_create" && `
    wsl --shutdown && `
    wsl -d wisilikube bash -c "sudo ./install system && ./install docker" && `
    wsl --shutdown && `
    wsl -d wisilikube bash -c "./install minik8s"
}

Remove-Item -Recurse -Force ${UbuntuRootfs}
If (![string]::IsNullOrEmpty(${Current})) {
    Remove-Item -Recurse -Force install
    cd ${Current}
}
