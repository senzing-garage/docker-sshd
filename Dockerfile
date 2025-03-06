ARG BASE_IMAGE=senzing/senzingapi-tools:3.12.5

ARG IMAGE_NAME="senzing/sshd"
ARG IMAGE_MAINTAINER="support@senzing.com"
ARG IMAGE_VERSION="1.5.0"

# -----------------------------------------------------------------------------
# Stage: builder
# -----------------------------------------------------------------------------

FROM ${BASE_IMAGE} AS builder

# Set Shell to use for RUN commands in builder step.

ENV REFRESHED_AT=2025-03-06

# Run as "root" for system installation.

USER root

# Install packages via apt for building fio.

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get -y install \
      gcc \
      make \
      pkg-config \
      python3 \
      python3-dev \
      python3-pip \
      python3-venv \
      unzip \
      wget \
 && rm -rf /var/lib/apt/lists/*

# Work around until Debian repos catch up to modern versions of fio.

RUN mkdir /tmp/fio \
 && cd /tmp/fio \
 && wget https://github.com/axboe/fio/archive/refs/tags/fio-3.39.zip \
 && unzip fio-3.39.zip \
 && cd fio-fio-3.39/ \
 && ./configure \
 && make \
 && make install \
 && fio --version \
 && cd \
 && rm -rf /tmp/fio

# Create and activate virtual environment.

RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# pip install Python dependencies.

COPY requirements.txt .
RUN pip3 install --upgrade pip \
 && pip3 install -r requirements.txt \
 && rm /requirements.txt

# -----------------------------------------------------------------------------
# Stage: Final
# -----------------------------------------------------------------------------

# Create the runtime image.

FROM ${BASE_IMAGE} AS runner

ARG IMAGE_NAME
ARG IMAGE_MAINTAINER
ARG IMAGE_VERSION

LABEL Name=${IMAGE_NAME} \
      Maintainer=${IMAGE_MAINTAINER} \
      Version=${IMAGE_VERSION}

# Define health check.

HEALTHCHECK CMD ["/app/healthcheck.sh"]

# Run as "root" for system installation.

USER root

# Install packages via apt.

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get -y install \
      elvis-tiny \
      htop \
      iotop \
      jq \
      net-tools \
      openssh-server \
      postgresql-common \
      procps \
      python3-dev \
      python3-pip \
      python3-pyodbc \
      strace \
      tree \
      unzip \
      wget \
      zip \
 && /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y \
 && apt-get -y install postgresql-client-14 \
 && rm -rf /var/lib/apt/lists/*

# Copy python virtual environment from the builder image.

COPY --from=builder /app/venv /app/venv

# Activate virtual environment.

ENV VIRTUAL_ENV=/app/venv
ENV PATH="/app/venv/bin:${PATH}"

# Configure sshd.

RUN mkdir /var/run/sshd \
 && sed -i -e '$aPermitRootLogin yes' /etc/ssh/sshd_config \
 && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Copy files from repository.

COPY ./rootfs /
RUN /app/update-motd.sh \
 && /app/update-etc-profile.sh

# Copy files from prior stages.

COPY --from=builder "/usr/local/bin/fio" "/usr/local/bin/fio"

# The port for ssh is 22.

EXPOSE 22

# Runtime environment variables.

ENV NOTVISIBLE="in users profile" \
    ROOT_PASSWORD=senzingsshdpassword \
    SENZING_ETC_PATH=/etc/opt/senzing \
    SENZING_SSHD_SHOW_PERFORMANCE_WARNING=true

# Runtime execution.

CMD ["/app/docker-entrypoint.sh"]
