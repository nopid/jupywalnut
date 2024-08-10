#!/bin/sh
MAXMEM=128g
NBDIR=$PWD/notebooks
docker run --rm -it -m=$MAXMEM -v $NBDIR:/home/jovyan/notebooks -p 8888:8888 nopid/walnut
