ARG BASE_IMAGE=senzing/senzingapi-tools:3.10.3

ARG IMAGE_NAME="senzing/sshd"
ARG IMAGE_MAINTAINER="support@senzing.com"
ARG IMAGE_VERSION="1.4.12"

# -----------------------------------------------------------------------------
# Stage: builder
# -----------------------------------------------------------------------------

FROM ${BASE_IMAGE} AS builder

# Set Shell to use for RUN commands in builder step.

ENV REFRESHED_AT=2024-06-24

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
 && wget https://github.com/axboe/fio/archive/refs/tags/fio-3.30.zip \
 && unzip fio-3.30.zip \
 && cd fio-fio-3.30/ \
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
 && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
 && echo "export LANGUAGE=C" >> /etc/profile \
 && echo "export LC_ALL=C.UTF-8" >> /etc/profile \
 && echo "export LD_LIBRARY_PATH=/opt/senzing/g2/lib" >> /etc/profile \
 && echo "export PATH=${PATH}" >> /etc/profile \
 && echo "export PYTHONPATH=/opt/senzing/g2/python:/opt/senzing/g2/sdk/python" >> /etc/profile \
 && echo "export PYTHONUNBUFFERED=1" >> /etc/profile \
 && echo "export NOTVISIBLE='in users profile'" >> /etc/profile \
 && echo "export ROOT_PASSWORD=senzingsshdpassword" >> /etc/profile \
 && echo "export SENZING_DOCKER_LAUNCHED=true" >> /etc/profile \
 && echo "export SENZING_SKIP_DATABASE_PERFORMANCE_TEST=true" >> /etc/profile \
 && echo "export SENZING_SSHD_SHOW_PERFORMANCE_WARNING=true" >> /etc/profile \
 && echo "export VISIBLE=now" >> /etc/profile

# Copy files from repository.

COPY ./rootfs /
RUN /app/update-motd.sh

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
