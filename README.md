# Nectar Jupyter Docker Stacks

This project provides customised Jupyter environments suitable for running on
ARDC Nectar JupyterHub service.

It relies heavily on the official [Jupyter Docker Stacks](https://github.com/jupyter/docker-stacks)
repo and provides just enough to add our own customisations to the standard
images.

We are currently building the following images from upstream:
- minimal-notebook
- datascience-notebook
- scipy-notebook
- r-notebook

## Using it

The included Makefile is borrowed from the upstream project, and modified a
a bit for our purposes. Running `make` with no other arguments gives us this
help menu.

```
$ make
nectar-jupyter-docker-stacks
============================
Replace % with a stack directory name (e.g., make build/minimal-notebook)

build-all                      build all stacks
build/%                        build the latest image for a stack using the system's architecture
cont-clean-all                 clean all containers (stop + rm)
cont-rm-all                    remove all containers
cont-stop-all                  stop all containers
img-clean                      clean dangling and jupyter images
img-list                       list jupyter images
img-rm-dang                    remove dangling images (tagged None)
img-rm                         remove jupyter images
pull-all                       pull all images
pull/%                         pull a jupyter image
push-all                       push all tagged images
push/%                         push all tags for a jupyter image
run-shell/%                    run a bash in interactive mode in a stack
run-sudo-shell/%               run a bash in interactive mode as root in a stack
```

## Building images

To build a single image, you can do something like:
```
make build/minimal-notebook
```

or to simply build them all, just run
```
make build
```

The upstream image version to build upon is set as the `TAG` variable in
the top of the Makefile. As new versions come out, you will want to update this
value.

When the images are being built, we include our `favicon.ico`, which simply
replaces the existing ones inside the image, and we build a copy of our
[Nectar JupyterLab Theme](https://github.com/NeCTAR-RC/nectar-jupyterlab-theme)
extension and install it to provide our customised look-and-feel.

The images are then tagged with the standard Docker `Image ID` so we have an
immutable tag to reference them with. They also include the upstream tag
(currently using `hub-5.4.3`) for reference.

Once you're ready, you can the push the images to the registry:
```
make push/minimal-notebook
```

or to just push them all:
```
make push-all
```

Then you can use this handy one-liner to print the results, which will need to
go into Helm chart values in the JupyterHub config in the
[containers repo](https://git.rc.nectar.org.au/internal/containers)

```
$ docker images | awk '/registry.rc.nectar.org.au\/nectar\/jupyter-.*hub-5.4.3/ {print $1 ":" $3}'
registry.rc.nectar.org.au/nectar/jupyter-datascience-notebook:9c5ee67a3531
registry.rc.nectar.org.au/nectar/jupyter-scipy-notebook:758ef9e36fba
registry.rc.nectar.org.au/nectar/jupyter-r-notebook:7e4e982de33d
registry.rc.nectar.org.au/nectar/jupyter-minimal-notebook:920172ce630a
```
