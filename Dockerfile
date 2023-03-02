FROM ubuntu
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip python3-venv graphviz openjdk-17-jre python3-json-pointer
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-jsonschema
RUN pip3 install pydot notebook metakernel rise==5.7.1
RUN apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
RUN mkdir -p /data/Result
COPY jupyter_notebook_config.py /etc/jupyter/
COPY kernel.json /data/
COPY walnutkernel.py /data/
COPY walnut.jar /data/
ADD auxfiles.tar.gz /data/
WORKDIR /data
RUN jupyter-kernelspec install /data
CMD [ "jupyter-notebook"]
