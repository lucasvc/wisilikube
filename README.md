# WSL 2 distro for Minikube stack development

This is a simple way of having the Minikube stack of tools on a Windows.

It is bases it use in,

* [Windows Subsystem for Linux](https://learn.microsoft.com/en-gb/windows/wsl/about#what-is-wsl-2) (aka WSL) in its version 2.
* An Ubuntu root filesystem (aka `rootfs`), currently [the Server cloudimage](https://cloud-images.ubuntu.com/releases/).

and nothing more :)
No Docker Desktop, nor full virtual machine required.
And most fancy: automatic installation of all the tools.

## Requirements

* Windows 10 2004 and higher (Build 19041 and higher).
* WSL version 2 is enabled.

## Install

Execute,

```
.\make.ps1 Install
```

### Options

| Option | Description |
| ------ | ----------- |
|`Destination` | Can be used to select installation folder |

## Export

// TODO create `make.ps1 Export`
// until that
// wsl --export wisilikube wisilikube
// will create a tarball with the distro, later can be imported with ?

## Usage

Once installed execute the file,

```
wsl -d wisilikube
```

to enter into the distro (Ubuntu) shell.
You can execute there i.e.

```
minikube start --insecure-registry 10.0.0.0/24
```

To start a Minikube cluster.

## Known issues / next works

### Version selector

Currently Ubuntu version is hardcoded in the `Install.ps1` script, a version selector can be developed using [meta-release](https://changelogs.ubuntu.com/meta-release).

### Better `make` commands

`TODO` pointeds in this file.

### Fresh start is slow

Fresh start (opening first shell after computer start/WSL-shutdown) is slow, ~30 seconds.
This is probably due to some of the Server services starting.
Next steps is to replace Server with the Base flavor installing **only** those really needed packages, but also found other unknown issues with that flavor.

### Publish Docker daemon

Even I created a simpler Docker daemon distro (dodaemon), why having two separate Docker daemons? Ideally this will replace the simpler one as main WSL distro.
