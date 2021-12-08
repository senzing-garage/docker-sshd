ARG BASE_IMAGE=senzing/senzing-base:1.6.3
FROM ${BASE_IMAGE}

ENV REFRESHED_AT=2021-12-07

LABEL Name="senzing/sshd" \
      Maintainer="support@senzing.com" \
      Version="1.2.5"

HEALTHCHECK CMD ["/app/healthcheck.sh"]

# Run as "root" for system installation.

USER root

# Install packages via apt.

RUN apt-get update \
 && apt-get -y install \
    elfutils \
    htop \
    iotop \
    ipython3 \
    itop \
    less \
    libpq-dev \
    net-tools \
    openssh-server \
    procps \
    pstack \
    python3-setuptools \
    strace \
    telnet \
    tree \
    unixodbc-dev \
    unzip \
    zip \
 && rm -rf /var/lib/apt/lists/*

# Install packages via pip.

COPY requirements.txt ./
RUN pip3 install --upgrade pip \
 && pip3 install -r requirements.txt \
 && rm requirements.txt

# work around until Debian repos catch up to modern versions of fio --Dr. Ant

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
 && echo "export SENZING_SSHD_SHOW_PERFORMANCE_WARNING=true" >> /root/.bashrc

# Copy files from repository.

COPY ./rootfs /

EXPOSE 22

ENV ROOT_PASSWORD=senzingsshdpassword

CMD ["/app/docker-entrypoint.sh"]
