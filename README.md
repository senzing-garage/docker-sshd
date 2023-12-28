# docker-sshd

If you are beginning your journey with
[Senzing](https://senzing.com/),
please start with
[Senzing Quick Start guides](https://docs.senzing.com/quickstart/).

You are in the
[Senzing Garage](https://github.com/senzing-garage)
where projects are "tinkered" on.
Although this GitHub repository may help you understand an approach to using Senzing,
it's not considered to be "production ready" and is not considered to be part of the Senzing product.
Heck, it may not even be appropriate for your application of Senzing!

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

1. [Legend](#legend)
1. [Expectations](#expectations)
1. [Demonstrate using Docker](#demonstrate-using-docker)
    1. [Prerequisites for Docker](#prerequisites-for-docker)
    1. [SSH port](#ssh-port)
    1. [Set sshd password](#set-sshd-password)
    1. [Run Docker container](#run-docker-container)
    1. [SSH into container](#ssh-into-container)
1. [Configuration](#configuration)
1. [License](#license)
1. [References](#references)

### Legend

1. :thinking: - A "thinker" icon means that a little extra thinking may be required.
   Perhaps there are some choices to be made.
   Perhaps it's an optional step.
1. :pencil2: - A "pencil" icon means that the instructions may need modification before performing.
1. :warning: - A "warning" icon means that something tricky is happening, so pay attention.

## Expectations

- **Space:** This repository and demonstration require 1 GB free disk space.
- **Time:** Budget 40 minutes to get the demonstration up-and-running, depending on CPU and network speeds.
- **Background knowledge:** This repository assumes a working knowledge of:
  - [Docker](https://github.com/senzing-garage/knowledge-base/blob/main/WHATIS/docker.md)
  - [ssh](https://github.com/senzing-garage/knowledge-base/blob/main/WHATIS/ssh.md)

## Demonstrate using Docker

### Prerequisites for Docker

:thinking: The following tasks need to be complete before proceeding.
These are "one-time tasks" which may already have been completed.

1. The following software programs need to be installed:
    1. [docker](https://github.com/senzing-garage/knowledge-base/blob/main/WHATIS/docker.md)

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
      ${SENZING_SSHD_PORT_PARAMETER} \
      senzing/sshd
    ```

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
   See [Build Docker Image](development.md#build-docker-image).

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

## Configuration

Configuration values specified by environment variable or command line parameter.

- **[SENZING_DATABASE_URL](https://github.com/senzing-garage/knowledge-base/blob/main/lists/environment-variables.md#senzing_database_url)**
- **[SENZING_DEBUG](https://github.com/senzing-garage/knowledge-base/blob/main/lists/environment-variables.md#senzing_debug)**

## License

View
[license information](https://senzing.com/end-user-license-agreement/)
for the software container in this Docker image.
Note that this license does not permit further distribution.

This Docker image may also contain software from the
[Senzing GitHub community](https://github.com/senzing-garage/)
under the
[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

Further, as with all Docker images,
this likely also contains other software which may be under other licenses
(such as Bash, etc. from the base distribution,
along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage,
it is the image user's responsibility to ensure that any use of this image complies
with any relevant licenses for all software contained within.

## References

- [Development](docs/development.md)
- [Errors](docs/errors.md)
- [Examples](docs/examples.md)
- Related artifacts
  - [DockerHub](https://hub.docker.com/r/senzing/sshd)
