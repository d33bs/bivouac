# references (but not copies)
# - https://github.com/jupyterhub/jupyterhub/blob/main/dockerfiles/Dockerfile.alpine
# - https://github.com/jupyterhub/repo2docker/blob/main/Dockerfile

ARG PYTHON_VERSION=3.9.12

FROM python:$PYTHON_VERSION

ENV LANG=en_US.UTF-8

ENV PWD=$PWD
ENV DATA_PWD=$PWD/src
ENV WORK_DIR=/workdir
ENV DATA_DIR=$WORK_DIR/src

WORKDIR $WORK_DIR

COPY ./requirements.txt requirements.txt
COPY $DATA_PWD $DATA_DIR

# add a nonroot user
RUN groupadd --system somebody \
    && useradd --base-dir $WORK_DIR --system --gid somebody -G root somebody

# update to enable noroot access
RUN chgrp -R 0 $WORK_DIR \ 
    && chmod -R g=u $WORK_DIR

# installs
RUN apt update \
    && apt install -y \
    nodejs \
    npm
RUN pip3 install --no-cache -r requirements.txt

# Install and enable jupyter lab formatter extension for isort+black formatting within notebooks
RUN jupyter labextension install @ryantam626/jupyterlab_code_formatter
RUN jupyter serverextension enable --py jupyterlab_code_formatter
RUN jupyter server extension enable jupyterlab_code_formatter

USER somebody

EXPOSE 8888

CMD ["jupyter","lab" \
    ,"--ip", "0.0.0.0" \
    ,"--no-browser" \
    ,"--ServerApp.token=''" \
    ,"--ServerApp.password=''"]