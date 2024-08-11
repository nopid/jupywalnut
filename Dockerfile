FROM ubuntu:24.04
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y pipx graphviz openjdk-17-jre libflint-dev build-essential autoconf libtool pkg-config python3-dev
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
RUN pipx install notebook==6.5.7 --include-deps
RUN pipx runpip notebook install setuptools pydot metakernel==0.29.5 rise==5.7.1
RUN pipx runpip notebook install licofage==0.8 ratser==0.2 
RUN apt-get purge -y --auto-remove build-essential autoconf libtool pkg-config
RUN apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}
RUN userdel -r ubuntu
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
ENV PYTHONPATH=/data:
USER ${NB_USER}
RUN jupyter trust notebooks/*.ipynb
CMD [ "jupyter-notebook"]
