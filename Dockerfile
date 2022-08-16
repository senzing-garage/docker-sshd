ARG BASE_IMAGE=debian:11.4-slim@sha256:a811e62769a642241b168ac34f615fb02da863307a14c4432cea8e5a0f9782b8

# -----------------------------------------------------------------------------
# Stage: builder
# -----------------------------------------------------------------------------

FROM ${BASE_IMAGE} AS builder

# Set Shell to use for RUN commands in builder step.

ENV REFRESHED_AT=2022-08-12

LABEL Name="senzing/sshd" \
      Maintainer="support@senzing.com" \
      Version="1.3.0"

# Run as "root" for system installation.

USER root

# Install packages via apt for building fio.

RUN apt-get update \
 && apt-get -y install \
      gcc \
      make \
      pkg-config \
      unzip \
      wget \
      && rm -rf /var/lib/apt/lists/*

# Work around until Debian repos catch up to modern versions of fio.

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

# -----------------------------------------------------------------------------
# Stage: Final
# -----------------------------------------------------------------------------

# Create the runtime image.

FROM ${BASE_IMAGE} AS runner

ENV REFRESHED_AT=2022-08-12

LABEL Name="senzing/sshd" \
      Maintainer="support@senzing.com" \
      Version="1.3.0"

# Define health check.

HEALTHCHECK CMD ["/app/healthcheck.sh"]

# Run as "root" for system installation.

USER root

# Install packages via apt.

RUN apt-get update \
 && apt-get -y install \
      curl \
      elvis-tiny \
      htop \
      iotop \
      jq \
      less \
      libpq-dev \
      libssl1.1 \
      net-tools \
      odbcinst \
      openssh-server \
      postgresql-client \
      procps \
      python3-dev \
      python3-pip \
      sqlite3 \
      strace \
      tree \
      unixodbc-dev \
      unzip \
      wget \
      zip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install packages via pip.

COPY requirements.txt .
RUN pip3 install --upgrade pip \
 && pip3 install -r requirements.txt \
 && rm /requirements.txt

# Configure sshd.

RUN mkdir /var/run/sshd \
 && sed -i -e '$aPermitRootLogin yes' /etc/ssh/sshd_config \
 && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
 && echo "export LANGUAGE=C" >> /root/.bashrc \
 && echo "export LC_ALL=C.UTF-8" >> /root/.bashrc \
 && echo "export LD_LIBRARY_PATH=/opt/senzing/g2/lib:/opt/senzing/g2/lib/debian:/opt/IBM/db2/clidriver/lib" >> /root/.bashrc \
 && echo "export ODBCSYSINI=/etc/opt/senzing" >> /root/.bashrc \
 && echo "export PATH=${PATH}:/opt/senzing/g2/python:/opt/IBM/db2/clidriver/adm:/opt/IBM/db2/clidriver/bin" >> /root/.bashrc \
 && echo "export PYTHONPATH=/opt/senzing/g2/python" >> /root/.bashrc \
 && echo "export SENZING_ETC_PATH=/etc/opt/senzing" >> /root/.bashrc \
 && echo "export SENZING_SSHD_SHOW_PERFORMANCE_WARNING=true" >> /root/.bashrc \
 && echo "export TERM=xterm" >> /root/.bashrc \
 && echo "export VISIBLE=now" >> /etc/profile

# Copy files from repository.

COPY ./rootfs /

# Copy files from prior stages.

COPY --from=builder "/usr/local/bin/fio" "/usr/local/bin/fio"

# The port for ssh is 22.

EXPOSE 22

# Runtime environment variables.

ENV NOTVISIBLE "in users profile"
ENV ROOT_PASSWORD=senzingsshdpassword
ENV SENZING_SSHD_SHOW_PERFORMANCE_WARNING='true'

# Runtime execution.

CMD ["/app/docker-entrypoint.sh"]
