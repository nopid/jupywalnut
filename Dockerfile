FROM ubuntu:24.04
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip python3-venv graphviz openjdk-17-jre python3-json-pointer
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-jsonschema libflint-dev
RUN rm /usr/lib/python*/EXTERNALLY-MANAGED
RUN pip3 install -U --ignore-installed pip
RUN pip3 install licofage==0.8 ratser==0.1
RUN pip3 install pyzmq
RUN pip3 install --ignore-installed jsonschema
RUN pip3 install numpy==1.26.4 pydot notebook==6.5.7 metakernel==0.29.5 rise==5.7.1
RUN apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

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
ENV PYTHONPATH /data:
USER ${NB_USER}
RUN jupyter trust notebooks/*.ipynb
CMD [ "jupyter-notebook"]
