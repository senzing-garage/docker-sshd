ARG BASE_IMAGE=debian:11.2-slim@sha256:4c25ffa6ef572cf0d57da8c634769a08ae94529f7de5be5587ec8ce7b9b50f9c
FROM ${BASE_IMAGE}

ENV REFRESHED_AT=2022-01-27

LABEL Name="senzing/sshd" \
      Maintainer="support@senzing.com" \
      Version="1.2.6"

HEALTHCHECK CMD ["/app/healthcheck.sh"]

# Run as "root" for system installation.

USER root

# Install packages via apt.

RUN apt-get update \
      && apt-get -y install \
      # build-essential \
      curl \
      # elfutils \
      # gdb \
      htop \
      iotop \
      # ipython3 \
      # itop \
      jq \
      less \
      # libbz2-dev \
      # libffi-dev \
      # libgdbm-dev \
      # libncursesw5-dev \
      libpq-dev \
      # libreadline-dev \
      # libsqlite3-dev \
      # libssl-dev \
      # lsb-release \
      net-tools \
      # odbc-postgresql \
      odbcinst \
      openssh-server \
      postgresql-client \
      procps \
      python3-dev \
      python3-pip \
      # python3-setuptools \
      sqlite3 \
      strace \
      # telnet \
      # tk-dev \
      tree \
      # unixodbc \
      unixodbc-dev \
      unzip \
      vim \
      wget \
      zip \
      && rm -rf /var/lib/apt/lists/*

# Install packages via pip.

COPY requirements.txt ./
RUN pip3 install --upgrade pip \
      && pip3 install -r requirements.txt \
      && rm requirements.txt

# work around until Debian repos catch up to modern versions of fio --Dr. Ant
# Debian package for Debian 11.2 on 27 Jan is at fio@3.25-2, which still has
# vulnerabilities not found in 3.27
RUN mkdir /tmp/fio \
      && cd /tmp/fio \
      && wget https://github.com/axboe/fio/archive/refs/tags/fio-3.27.zip \
      && unzip fio-3.27.zip \
      && cd fio-fio-3.27/ \
      && ./configure \
      && make \
      && make install \
      && fio --version \
      && cd \
      && rm -rf /tmp/fio

ENV NOTVISIBLE "in users profile"

ENV SENZING_SSHD_SHOW_PERFORMANCE_WARNING='true'

# Configure sshd.

RUN mkdir /var/run/sshd \
      && sed -i -e '$aPermitRootLogin yes' /etc/ssh/sshd_config \
      && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
      && echo "export VISIBLE=now" >> /etc/profile \
      && echo "export LD_LIBRARY_PATH=/opt/senzing/g2/lib:/opt/senzing/g2/lib/debian:/opt/IBM/db2/clidriver/lib" >> /root/.bashrc \
      && echo "export ODBCSYSINI=/etc/opt/senzing" >> /root/.bashrc \
      && echo "export PATH=${PATH}:/opt/senzing/g2/python:/opt/IBM/db2/clidriver/adm:/opt/IBM/db2/clidriver/bin" >> /root/.bashrc \
      && echo "export PYTHONPATH=/opt/senzing/g2/python" >> /root/.bashrc \
      && echo "export SENZING_ETC_PATH=/etc/opt/senzing" >> /root/.bashrc \
      && echo "export SENZING_SSHD_SHOW_PERFORMANCE_WARNING=true" >> /root/.bashrc \
      && echo "export LC_ALL=C" >> /root/.bashrc \
      && echo "export LANGUAGE=C" >> /root/.bashrc

# Copy files from repository.

COPY ./rootfs /

EXPOSE 22

ENV ROOT_PASSWORD=senzingsshdpassword

CMD ["/app/docker-entrypoint.sh"]
