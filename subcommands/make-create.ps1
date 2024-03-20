param (
    [string]$UbuntuMajor = "22", # TODO LTS
    [string]$UbuntuMinor = "04", # TODO LTS
    [string]$UbuntuPatch = "4", # TODO max
    [string]$Destination
)

If ( [string]::IsNullOrEmpty(${Destination}) ) {
    $Destination = "."
}
else {
    $Current = pwd
    Copy-Item install.sh ${Destination}
    cd ${Destination}
}

$UbuntuRootfs = "ubuntu-${UbuntuMajor}.${UbuntuMinor}-server-cloudimg-amd64-root.tar.xz"
                # <BASE> "ubuntu-base-${UbuntuMajor}.${UbuntuMinor}.${UbuntuPatch}-base-amd64.tar.gz"
$UbuntuUri = "https://cloud-images.ubuntu.com/releases/${UbuntuMajor}.${UbuntuMinor}/release/${UbuntuRootfs}"
                 # <BASE> "https://cdimage.ubuntu.com/ubuntu-base/releases/${UbuntuMajor}.${UbuntuMinor}/release/${UbuntuRootfs}"
Invoke-WebRequest -Uri ${UbuntuUri} -OutFile .
Invoke-WebRequest -Uri https://github.com/yuk7/wsldl/releases/latest/download/wsldl.exe -OutFile wisilikube.exe
wsl --import --version 2 wisilikube ${Destination} ${UbuntuRootfs}

pwsh -Command { `
    $env:WSLENV=$env:WSLENV+":USERNAME/u"; `
    .\wisilikube.exe run bash -c "chmod +x install.sh && ./install.sh wsl" && `
    wsl --shutdown && `
    .\wisilikube.exe run bash -c "./install.sh user_create" && `
    .\wisilikube.exe config --default-user $env:USERNAME && `
    .\wisilikube.exe run bash -c "sudo ./install.sh system && ./install.sh docker" && `
    wsl --shutdown && `
    .\wisilikube.exe run bash -c "./install.sh minik8s"
}

Remove-Item -Recurse -Force ${UbuntuRootfs}
If (![string]::IsNullOrEmpty(${Current}))
{
    Remove-Item -Recurse -Force install.sh
    cd ${Current}
}
