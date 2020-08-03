ARG BASE_IMAGE=senzing/senzing-base:1.5.2
FROM ${BASE_IMAGE}

ENV REFRESHED_AT=2020-07-22

LABEL Name="senzing/sshd" \
      Maintainer="support@senzing.com" \
      Version="1.0.0"

HEALTHCHECK CMD ["/app/healthcheck.sh"]

# Run as "root" for system installation.

USER root

# Install packages via apt.

RUN apt-get update && apt-get install -y openssh-server

RUN apt-get update \
 && apt-get -y install \
    elfutils \
    fio \
    htop \
    iotop \
    ipython \
    itop \
    less \
    net-tools \
    odbc-postgresql \
    procps \
    pstack \
    python-pyodbc \
    python-setuptools \
    strace \
    tree \
    unixodbc \
    unixodbc-dev \
    vim \
 && rm -rf /var/lib/apt/lists/*

# Install packages via pip.

RUN pip3 install --upgrade pip \
 && pip3 install \
      click==7.0 \
      csvkit \
      eventlet \
      flask-socketio==3.3.1 \
      flask==1.0.2 \
      fuzzywuzzy \
      itsdangerous==1.1.0 \
      jinja2==2.10 \
      markupsafe==1.1.1 \
      pandas \
      ptable \
      pyodbc \
      pysnooper \
      python-engineio==3.4.3 \
      python-levenshtein \
      python-socketio==3.1.2 \
      setuptools \
      six==1.12.0 \
      werkzeug==0.14.1
      
RUN mkdir /var/run/sshd

# Copy files from repository.

COPY ./rootfs /

# Runtime execution.

WORKDIR /app
EXPOSE 922
CMD ["/usr/sbin/sshd", "-D"]
