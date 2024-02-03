FROM ubuntu
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip python3-venv graphviz openjdk-17-jre python3-json-pointer
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-jsonschema
RUN pip3 install pydot notebook==6.5.6 metakernel==0.29.5 rise==5.7.1
RUN apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
RUN mkdir -p ${HOME}/Result
RUN mkdir /data
COPY jupyter_notebook_config.py /etc/jupyter/
COPY kernel.json /data
COPY walnutkernel.py /data
COPY walnut.jar /data
ADD auxfiles.tar.gz ${HOME}/
WORKDIR ${HOME}
RUN jupyter-kernelspec install /data
COPY notebooks/howto.ipynb notebooks/
RUN chown -R ${NB_UID} ${HOME}
RUN chmod -R a+rx /data
ENV PYTHONPATH /data:
USER ${NB_USER}
RUN jupyter trust notebooks/*.ipynb
CMD [ "jupyter-notebook"]
