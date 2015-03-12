# docker-viper

[Viper](https://bitbucket.org/viperproject/) development environment in
a Docker container (based on
[docker-eclipse](https://github.com/fgrehm/docker-eclipse)).

## Requirements

* Docker 1.2+ (should work fine on 1.0+ but I haven't tried)
* An X11 socket

## Quickstart

Assuming that you are able to run `docker` commands
[without `sudo`](http://docs.docker.io/installation/ubuntulinux/#giving-non-root-access),
you can use the [provided `idea` script](idea) to start a disposable
IntelliJ IDE Docker container with your project sources mounted at
`/home/developer/workspace` within the container. Once you close
IntelliJ the container will be removed and no traces of it will be kept
on your machine (apart from the Docker image of course).

## Help! I started the container but I don't see the Eclipse screen

You might have an issue with the X11 socket permissions since the default user
used by the base image has an user and group ids set to `1000`, in that case
you can run either create your own base image with the appropriate ids or run
`xhost +` on your machine and try again.
