#!/bin/sh
docker run --rm -it -v $(PWD)/notebooks:/home/jovyan/notebooks -p 8888:8888 nopid/walnut
