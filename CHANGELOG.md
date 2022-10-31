# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
[markdownlint](https://dlaa.me/markdownlint/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

-

## [1.4.4] - 2022-10-27

### Changed in 1.4.4

- In `Dockerfile`, updated FROM instruction to `senzing/senzingapi-tools:3.3.1`
- In `requirements.txt`, updated:
  - orjson==3.8.1
  - pandas==1.5.1
  - prettytable==3.5.0
  - python-socketio==5.7.2
  - setuptools==65.5.0

## [1.4.3] - 2022-10-11

### Changed in 1.4.3

- In `Dockerfile`, updated FROM instruction to `senzing/senzingapi-tools:3.3.1`
- In `requirements.txt`, updated:
  - setuptools==65.4.1
  - VisiData==2.10.2

## [1.4.2] - 2022-09-28

### Changed in 1.4.2

- In `Dockerfile`, updated FROM instruction to `senzing/senzingapi-tools:3.3.0`
- In `requirements.txt`, updated:
  - setuptools==65.4.0

## [1.4.1] - 2022-09-23

### Changed in 1.4.1

- Migrated from pip `pyodbc` to apt `python3-pyodbc`
- Trimmed `requirements.txt`

## [1.4.0] - 2022-08-26

### Changed in 1.4.0

- removed psutils and duplicate packages from requirements.txt
- update to use `senzingapi-tools`

## [1.3.0] - 2022-06-08

### Changed in 1.3.0

- Upgrade `Dockerfile` to `FROM debian:11.3-slim@sha256:06a93cbdd49a265795ef7b24fe374fee670148a7973190fb798e43b3cf7c5d0f`

## [1.2.12] - 2022-05-04

### Changed in 1.2.12

- Last release supporting `senzingdata-v2`.

## [1.2.11] - 2022-05-02

### Changed in 1.2.11

- In Dockerfile. `ENV LC_ALL=C` to `ENV LC_ALL=C.UTF-8`

## [1.2.10] - 2022-04-19

### Changed in 1.2.10

- Updated python dependencies in `requirements.txt`

## [1.2.9] - 2022-04-01

### Changed in 1.2.9

- Updated to Debian 11.3-slim

## [1.2.8] - 2022-03-21

### Changed in 1.2.8

- Support for `libcrypto` and `libssl`

## [1.2.7] - 2022-02-03

### Changed in 1.2.7

- fio build moved to new stage
- replaced vim with elvis-tiny
- updated requirments.txt to pin package versions
- set the TERM var

## [1.2.6] - 2022-02-01

### Changed in 1.2.6

- updated to debian 11.2 base
- trimmed installed tools

## [1.2.5] - 2021-10-11

### Changed in 1.2.5

- Updated to senzing/senzing-base:1.6.2

## [1.2.4] - 2021-07-23

### Added to 1.2.4

- Updated to newer version of fio
- Removed duplicate apt package installs

## [1.2.3] - 2021-07-15

### Added to 1.2.3

- Updated to senzing/senzing-base:1.6.1

## [1.2.2] - 2021-07-13

### Added to 1.2.2

- Updated to senzing/senzing-base:1.6.0

- ## [1.2.1] - 2021-07-12

### Added to 1.2.1

- Improve permornace warning messaging

## [1.2.0] - 2021-04-20

### Added to 1.2.0

- Update to senzingdata 2.0.0

## [1.1.1] - 2021-04-20

### Added to 1.1.1

- Unzip added to dockerfile

## [1.1.0] - 2021-03-12

### Added to 1.1.0

- Performance warning message

## [1.0.3] - 2020-11-30

### Added to 1.0.3

- Support submitting the password at docker run

## [1.0.2] - 2020-11-24

### Added to 1.0.2

- Add `pip3 install psycopg2-binary`

## [1.0.1] - 2020-10-23

### Added to 1.0.1

- Update to `senzing/senzing-base:1.5.5`
  - Adds environment variable for root user

## [1.0.0] - 2020-08-19

### Added to 1.0.0

- Initial functionality
