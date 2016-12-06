# quic
`quic` stands for Quasi-isolated container. The program lets you run an executable in a linux container. The executable
will also be running with the specified path as the root folder with its own `proc` fs mounted.
Note that environment variables specified in the host will be passed along to the container. This can be avoided by prepending the command with `env -i` for a clean env.

A simple way to create a usable root filesystem is to use `debootstrap`.

## Installation
Ensure you have the installed:
 - `nasm` assembler installed
 - `ld` linker
 - `make` utility program

Clone repo and run `make` in it. You should now have a binary called `quic` put it somewhere on your `PATH`.

## Usage
```
quic host|<path-to-netns> <path-to-container-rootfs> <executable-in-container> [args...]
```

_NOTE: The executable needs superuser privileges (e.g. through `sudo`)._

### Arguments

`host` used to indicate that the container should use the hosts network stack without creating a network namespace.

`<path-to-netns>` can be used to have the container join the network namespace indicated by the path. These can commonly be found in `/var/run/netns/`. 

`<path-to-container-rootfs>` needs to be some directory which the container will use as the root filesystem.

`<executable-in-container>` is the path (relative to the root fs) to the executable that should run. It should be in a subdirectory of the root filesystem.

`[args...]` is optional and will be passed as arguments to the executable.



