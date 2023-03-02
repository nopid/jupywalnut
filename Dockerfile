FROM ubuntu
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip python3-venv graphviz openjdk-17-jre
RUN pip3 install pydot notebook metakernel
RUN apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
RUN mkdir -p /data/Result
COPY kernel.json /data/
COPY walnutkernel.py /data/
COPY walnut.jar /data/
ADD auxfiles.tar.gz /data/
WORKDIR /data
RUN jupyter-kernelspec install /data
CMD [ "jupyter-notebook", "--allow-root", "--no-browser", "--ip",  "0.0.0.0" ]
