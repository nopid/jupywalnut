# jupywalnut
A raw Jupyter kernel and docker container for Walnut

## How do I run this?

Please read [notebooks/howto.ipynb](notebooks/howto.ipynb)!

You can either do it directly or, better, using 
https://mybinder.org/v2/gh/nopid/jupywalnut/main


## The old way (kept here for reference)

There are plenty of ways to run me:
 1. as a local docker container pulled from the Docker HUB:
    $ docker run --rm -it -p 8888:8888 nopid/walnut

 2. as a local docker container built from this repo:
    $ docker build -t nopid/walnut .

 3. as a local docker container built with repo2docker:
    $ jupyter-repo2docker -p 8888:8888 http://github.com/nopid/jupywalnut jupyter-notebook

 4. completly remotely in your browser with mybinder:
    $ https://mybinder.org/v2/gh/nopid/jupywalnut/main
