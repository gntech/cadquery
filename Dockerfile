FROM ubuntu:16.04

MAINTAINER <dave.cowden@gmail.com>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8



#from continuum: https://hub.docker.com/r/continuumio/anaconda/~/dockerfile/
RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda2-5.0.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

RUN apt-get install -y curl grep sed dpkg  && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH

RUN apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:freecad-maintainers/freecad-stable && \
    apt-get update && apt-get install -y freecad

RUN mkdir -p /opt/cadquery
COPY requirements-dev.txt  runtests.py  cq_cmd.py cq_cmd.sh setup.py  README.md MANIFEST setup.cfg /opt/cadquery/
COPY cadquery /opt/cadquery/cadquery
COPY examples /opt/cadquery/examples
COPY tests /opt/cadquery/tests


RUN pip install -r /opt/cadquery/requirements-dev.txt
RUN cd /opt/cadquery && python ./setup.py install
RUN chmod +x /opt/cadquery/cq_cmd.sh
RUN useradd -ms /bin/bash cq
USER cq
WORKDIR /home/cq

ENTRYPOINT [ "/opt/cadquery/cq_cmd.sh" ]
