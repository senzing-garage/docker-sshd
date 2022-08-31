# docker-sshd

## Synopsis

This docker container runs `sshd` so that `ssh` and `scp` can be used for remote access.

## Overview

In many cases, the functionality of `ssh` and `scp` are already supported.
Examples:

1. Docker:  `docker exec` and `docker cp`
1. Kubernetes:  `kubectl exec` and `kubectl cp`
1. OpenShift: `oc exec` and `oc cp`

But there are environments where there is no ability to "exec" nor "cp".
In these environments, a `senzing/sshd` docker container can be used provide "exec" and "cp" capabilities
via `ssh` and `scp`.
Examples:

1. AWS Elastic Container Service (ECS)

### Contents

1. [Preamble](#preamble)
    1. [Legend](#legend)
1. [Related artifacts](#related-artifacts)
1. [Expectations](#expectations)
1. [Demonstrate using Docker](#demonstrate-using-docker)
    1. [Prerequisites for Docker](#prerequisites-for-docker)
    1. [Docker volumes](#docker-volumes)
    1. [Docker network](#docker-network)
    1. [SSH port](#ssh-port)
    1. [Set sshd password](#set-sshd-password)
    1. [Run Docker container](#run-docker-container)
    1. [SSH into container](#ssh-into-container)
1. [Develop](#develop)
    1. [Prerequisites for development](#prerequisites-for-development)
    1. [Clone repository](#clone-repository)
    1. [Build Docker image](#build-docker-image)
1. [Examples](#examples)
    1. [Examples of Docker](#examples-of-docker)
1. [Advanced](#advanced)
    1. [Configuration](#configuration)
1. [Errors](#errors)
1. [References](#references)
1. [License](#license)

## Preamble

At [Senzing](http://senzing.com),
we strive to create GitHub documentation in a
"[don't make me think](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/dont-make-me-think.md)" style.
For the most part, instructions are copy and paste.
Whenever thinking is needed, it's marked with a "thinking" icon :thinking:.
Whenever customization is needed, it's marked with a "pencil" icon :pencil2:.
If the instructions are not clear, please let us know by opening a new
[Documentation issue](https://github.com/Senzing/template-python/issues/new?template=documentation_request.md)
describing where we can improve.   Now on with the show...

### Legend

1. :thinking: - A "thinker" icon means that a little extra thinking may be required.
   Perhaps there are some choices to be made.
   Perhaps it's an optional step.
1. :pencil2: - A "pencil" icon means that the instructions may need modification before performing.
1. :warning: - A "warning" icon means that something tricky is happening, so pay attention.

## Related artifacts

1. [DockerHub](https://hub.docker.com/r/senzing/sshd)

## Expectations

- **Space:** This repository and demonstration require 1 GB free disk space.
- **Time:** Budget 40 minutes to get the demonstration up-and-running, depending on CPU and network speeds.
- **Background knowledge:** This repository assumes a working knowledge of:
  - [Docker](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/docker.md)
  - [ssh](https://github.com/Senzing/knowledge-base/blob/main/WHATIS/ssh.md)

## Demonstrate using Docker

### Prerequisites for Docker

:thinking: The following tasks need to be complete before proceeding.
These are "one-time tasks" which may already have been completed.

1. The following software programs need to be installed:
    1. [docker](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/install-docker.md)
1. [Install Senzing using Docker](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/install-senzing-using-docker.md)
    1. If using Docker with a previous "system install" of Senzing,
       see [how to use Docker with system install](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/use-docker-with-system-install.md).
1. [Configure Senzing database using Docker](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/configure-senzing-database-using-docker.md)
1. [Configure Senzing using Docker](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/configure-senzing-using-docker.md)

### Docker volumes

Senzing Docker images follow the [Linux File Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.pdf).
Inside the Docker container, Senzing artifacts will be located in `/opt/senzing`, `/etc/opt/senzing`, and `/var/opt/senzing`.

1. :pencil2: Specify the directory containing the Senzing installation on the host system
   (i.e. *outside* the Docker container).
   Use the same `SENZING_VOLUME` value used when performing
   [Prerequisites for Docker](#prerequisites-for-docker).
   Example:

    ```console
    export SENZING_VOLUME=/opt/my-senzing
    ```

    1. :warning:
       **macOS** - [File sharing](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/share-directories-with-docker.md#macos)
       must be enabled for `SENZING_VOLUME`.
    1. :warning:
       **Windows** - [File sharing](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/share-directories-with-docker.md#windows)
       must be enabled for `SENZING_VOLUME`.

1. Identify the `data_version`, `etc`, `g2`, and `var` directories.
   Example:

    ```console
    export SENZING_DATA_VERSION_DIR=${SENZING_VOLUME}/data/3.0.0
    export SENZING_ETC_DIR=${SENZING_VOLUME}/etc
    export SENZING_G2_DIR=${SENZING_VOLUME}/g2
    export SENZING_VAR_DIR=${SENZING_VOLUME}/var
    ```

    *Note:* If using a "system install",
    see [how to use Docker with system install](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/use-docker-with-system-install.md).
    for how to set environment variables.

1. Here's a simple test to see if `SENZING_G2_DIR` and `SENZING_DATA_VERSION_DIR` are correct.
   The following commands should return file contents.
   Example:

    ```console
    cat ${SENZING_G2_DIR}/g2BuildVersion.json
    cat ${SENZING_DATA_VERSION_DIR}/libpostal/data_version
    ```

### Docker network

:thinking: **Optional:**  Use if Docker container is part of a Docker network.

1. List Docker networks.
   Example:

    ```console
    sudo docker network ls
    ```

1. :pencil2: Specify Docker network.
   Choose value from NAME column of `docker network ls`.
   Example:

    ```console
    export SENZING_NETWORK=*nameofthe_network*
    ```

1. Construct parameter for `docker run`.
   Example:

    ```console
    export SENZING_NETWORK_PARAMETER="--net ${SENZING_NETWORK}"
    ```

### SSH port

:thinking: Normally port 22 is already in use for `ssh`.
So a different port may be needed by the running docker container.

1. :thinking: **Optional:** See if port 22 is already in use.
   Example:

    ```console
    sudo lsof -i -P -n | grep LISTEN | grep :22
    ````

1. :pencil2: Choose port for docker container.
   Example:

    ```console
    export SENZING_SSHD_PORT=922
    ```

1. Construct parameter for `docker run`.
   Example:

    ```console
    export SENZING_SSHD_PORT_PARAMETER="--publish ${SENZING_SSHD_PORT:-22}:22"
    ```

### Set sshd password

:thinking: **Optional** The default password set for the sshd containers is `senzingsshdpassword`. However, this can be set by setting the following variable

:pencil2: Set the `SENZING_SSHD_PASSWORD` variable to change the password to access the sshd container
```console
export SENZING_SSHD_PASSWORD=<Pass_You_Want>
```

### Run Docker container

Although the `Docker run` command looks complex,
it accounts for all of the optional variations described above.
Unset `*_PARAMETER` environment variables have no effect on the
`docker run` command and may be removed or remain.

1. Run Docker container.
   Example:

    ```console
    sudo docker run \
      --env ROOT_PASSWORD=${SENZING_SSHD_PASSWORD} \
      --interactive \
      --rm \
      --tty \
      --volume ${SENZING_DATA_VERSION_DIR}:/opt/senzing/data \
      --volume ${SENZING_ETC_DIR}:/etc/opt/senzing \
      --volume ${SENZING_G2_DIR}:/opt/senzing/g2 \
      --volume ${SENZING_VAR_DIR}:/var/opt/senzing \
      ${SENZING_NETWORK_PARAMETER} \
      ${SENZING_SSHD_PORT_PARAMETER} \
      senzing/sshd
    ```

1. For more examples of use, see [Examples of Docker](#examples-of-docker).

### SSH into container

1. :pencil2: Identify the host running the `senzing/sshd` container.
   Example:

    ```console
    SENZING_SSHD_HOST=localhost
    ```

1. `ssh` into the running docker container.
   Example:

    ```console
    ssh root@${SENZING_SSHD_HOST} -p ${SENZING_SSHD_PORT:-22}
    ```

1. The default password is `senzingsshdpassword`.
   However, if the docker image was built locally, it may have been changed during `docker build`.
   See [Build Docker Image](#build-docker-image).

1. :thinking: **Optional:**
   If `senzing/sshd` has been deployed multiple times,
   the following message may appear when `ssh`-ing into the container:

    ```console
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ```

    This is a good thing,
    it's mean to prevent
    [man-in-the-middle attacks](https://en.wikipedia.org/wiki/Man-in-the-middle_attack).
    However in this case, it prevents access to ever-changing docker containers.
    The message usually shows a remedy.
    Example:

    ```console
    ssh-keygen -f "/home/senzing/.ssh/known_hosts" -R "[localhost]:922"
    ```

## Develop

The following instructions are used when modifying and building the Docker image.

### Prerequisites for development

:thinking: The following tasks need to be complete before proceeding.
These are "one-time tasks" which may already have been completed.

1. The following software programs need to be installed:
    1. [git](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/install-git.md)
    1. [make](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/install-make.md)
    1. [docker](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/install-docker.md)

### Clone repository

For more information on environment variables,
see [Environment Variables](https://github.com/Senzing/knowledge-base/blob/main/lists/environment-variables.md).

1. Set these environment variable values:

    ```console
    export GIT_ACCOUNT=senzing
    export GIT_REPOSITORY=docker-sshd
    export GIT_ACCOUNT_DIR=~/${GIT_ACCOUNT}.git
    export GIT_REPOSITORY_DIR="${GIT_ACCOUNT_DIR}/${GIT_REPOSITORY}"
    ```

1. Using the environment variables values just set, follow steps in [clone-repository](https://github.com/Senzing/knowledge-base/blob/main/HOWTO/clone-repository.md) to install the Git repository.

### Build Docker image

1. **Option #1:** Using `docker` command and GitHub.

    ```console
    sudo docker build \
      --tag senzing/sshd \
      https://github.com/senzing/docker-sshd.git#main
    ```

1. **Option #2:** Using `docker` command and local repository.

    ```console
    cd ${GIT_REPOSITORY_DIR}
    sudo docker build --tag senzing/sshd .
    ```

1. **Option #3:** Using `make` command.

    ```console
    cd ${GIT_REPOSITORY_DIR}
    sudo make docker-build
    ```

    Note: `sudo make docker-build-development-cache` can be used to create cached Docker layers.

1. :pencil2: **Option #4:** Using `docker` command and local repository to change the ssh user's password.

    ```console
    cd ${GIT_REPOSITORY_DIR}
    sudo docker build \
      --build-arg ROOT_PASSWORD=<PASS_YOU_WANT> \
      --tag senzing/sshd \
      .
    ```

## Examples

### Examples of Docker

The following examples require initialization described in
[Demonstrate using Docker](#demonstrate-using-docker).

## Advanced

### Configuration

Configuration values specified by environment variable or command line parameter.

- **[SENZING_DATA_VERSION_DIR](https://github.com/Senzing/knowledge-base/blob/main/lists/environment-variables.md#senzing_data_version_dir)**
- **[SENZING_DATABASE_URL](https://github.com/Senzing/knowledge-base/blob/main/lists/environment-variables.md#senzing_database_url)**
- **[SENZING_DEBUG](https://github.com/Senzing/knowledge-base/blob/main/lists/environment-variables.md#senzing_debug)**
- **[SENZING_ETC_DIR](https://github.com/Senzing/knowledge-base/blob/main/lists/environment-variables.md#senzing_etc_dir)**
- **[SENZING_G2_DIR](https://github.com/Senzing/knowledge-base/blob/main/lists/environment-variables.md#senzing_g2_dir)**
- **[SENZING_NETWORK](https://github.com/Senzing/knowledge-base/blob/main/lists/environment-variables.md#senzing_network)**
- **[SENZING_RUNAS_USER](https://github.com/Senzing/knowledge-base/blob/main/lists/environment-variables.md#senzing_runas_user)**
- **[SENZING_VAR_DIR](https://github.com/Senzing/knowledge-base/blob/main/lists/environment-variables.md#senzing_var_dir)**

## Errors

1. See [docs/errors.md](docs/errors.md).

## References

## License

View
[license information](https://senzing.com/end-user-license-agreement/)
for the software container in this Docker image.
Note that this license does not permit further distribution.

This Docker image may also contain software from the
[Senzing GitHub community](https://github.com/Senzing/)
under the
[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Further, as with all Docker images,
this likely also contains other software which may be under other licenses
(such as Bash, etc. from the base distribution,
along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage,
it is the image user's responsibility to ensure that any use of this image complies
with any relevant licenses for all software contained within.

