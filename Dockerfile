FROM gradle:7-jdk17
WORKDIR /
RUN git clone https://github.com/firetto/Walnut.git
WORKDIR /Walnut
RUN gradle clean customFatJar && cp build/libs/Walnut-all.jar walnut.jar
RUN rm */.gitkeep
RUN find . -maxdepth 1 \
    -not \( -name Documentation -prune \) \
    -not \( -name Test\ Results -prune \) \
    -type d -name '[A-Z]*' -print0 | tar cvzf auxfiles.tar.gz --null -T -

FROM ubuntu:24.04
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y pipx graphviz openjdk-17-jre libflint-dev build-essential autoconf libtool pkg-config python3-dev wget less
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
RUN pipx install notebook==6.5.7 --include-deps
RUN pipx runpip notebook install setuptools pydot metakernel==0.29.5 rise==5.7.1 jupyter-cache
RUN pipx runpip notebook install licofage==0.8.1 ratser==0.2 walnut_kernel==0.3.2
RUN cd /tmp && \
wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.5.56/quarto-1.5.56-linux-$(dpkg --print-architecture).deb && \
DEBIAN_FRONTEND=noninteractive apt install -y ./quarto*.deb && \
rm quarto*.deb
COPY walnut.xml /opt/quarto/share/pandoc/syntax-definitions/
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
RUN mkdir /walnut
COPY jupyter_notebook_config.py /etc/jupyter/
COPY --from=0 /Walnut/walnut.jar /walnut
COPY --from=0 /Walnut/auxfiles.tar.gz /tmp
RUN cd ${HOME} && tar xvzf /tmp/auxfiles.tar.gz && rm /tmp/auxfiles.tar.gz
WORKDIR ${HOME}
COPY notebooks/howto.ipynb notebooks/
RUN chown -R ${NB_UID} ${HOME}
RUN chmod -R a+rx /walnut
ENV PYTHONPATH=/walnut:
ENV QUARTO_PYTHON=/opt/pipx/venvs/notebook/bin/python3
ENV WALNUT_JAR=/walnut/walnut.jar
ENV WALNUT_HOME=${HOME}
USER ${NB_USER}
RUN jupyter trust notebooks/*.ipynb
CMD [ "jupyter-notebook"]
