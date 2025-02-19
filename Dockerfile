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
    DEBIAN_FRONTEND=noninteractive apt-get install -y graphviz openjdk-17-jre libflint-dev build-essential autoconf libtool pkg-config python3-dev wget less
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
ENV UV_COMPILE_BYTECODE=1
ENV UV_TOOL_DIR=/opt/uv
ENV UV_TOOL_BIN_DIR=/usr/local/bin
RUN uv tool install --python 3.12 --with walnut_kernel,pydot,notebook,jupyter-cache,jupyterlab-rise jupyter-core
RUN ln -s /opt/uv/jupyter-core/bin/jupyter-notebook /usr/local/bin/jupyter-notebook
RUN cd /tmp && \
wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.40/quarto-1.6.40-linux-$(dpkg --print-architecture).deb && \
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
COPY jupyter_server_config.py /etc/jupyter/
COPY --from=0 /Walnut/walnut.jar /walnut
COPY --from=0 /Walnut/auxfiles.tar.gz /tmp
RUN cd ${HOME} && tar xvzf /tmp/auxfiles.tar.gz && rm /tmp/auxfiles.tar.gz
WORKDIR ${HOME}
COPY notebooks/howto.ipynb notebooks/
RUN chown -R ${NB_UID} ${HOME}
RUN chmod -R a+rx /walnut
ENV PYTHONPATH=/walnut:
ENV QUARTO_PYTHON=/opt/uv/jupyter-core/bin/python3
ENV WALNUT_JAR=/walnut/walnut.jar
ENV WALNUT_HOME=${HOME}
USER ${NB_USER}
RUN jupyter trust notebooks/*.ipynb
CMD [ "jupyter", "lab" ]
