#!/bin/sh
MAXMEM=20g
NBDIR=$PWD/notebooks
docker run --rm -it -m=$MAXMEM -v $NBDIR:/home/jovyan/notebooks -p 8888:8888 nopid/walnut
