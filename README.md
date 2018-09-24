pmm_client
==========

This role installs and configures the Percona PMM Client.

Requirements
------------

This role requires
[Ansible 2.5.0](https://docs.ansible.com/ansible/devel/roadmap/ROADMAP_2_5.html)
or higher.

You can simply use pip to install (and define) a stable version:

```sh
pip install ansible==2.6.4
```

All platform requirements are listed in the metadata file.

Install
-------

```sh
ansible-galaxy install timorunge.pmm_client
```

Role Variables
--------------

The variables that can be passed to this role and a brief description about
them are as follows. (For all variables, take a look at [defaults/main.yml](defaults/main.yml))

```yaml
# Define the version
# Type: Int
pmm_client_version: 1.14.1
# IP address and port of the pmm-server:
# Type: Str
pmm_client_server_host: 172.20.0.10
# Type: Int
pmm_client_server_port: 443
# Disable basic auth:
# Type: Bool
pmm_client_server_basic_auth: False
# Enable SSL:
# Type: Bool
pmm_client_server_use_ssl: True
# Define services to be added or removed:
# Type: List
pmm_client_add_services:
  - linux:metrics
  - mysql:metrics
  - mongodb:metrics
pmm_client_remove_services:
  - mysql:queries
# Define services to be started or stopped:
# Type: List
pmm_client_start_services:
  - linux:metrics
  - mysql:metrics
  - mongodb:metrics
pmm_client_stop_services:
  - mysql:queries
# Define credentials for the MySQL DB connection:
# Type: Dict
pmm_client_db:
  mysql:
    host: localhost
    port: 3306
    username: root
    password: toor
```

Examples
--------

## 1) Install the PMM Client with no basic auth and disabled SSL

```yaml
- hosts: all
  become: yes
  vars:
    pmm_client_server_host: 172.20.0.10
    pmm_client_server_port: 443
    pmm_client_server_basic_auth: False
    pmm_client_server_use_ssl: False
    pmm_client_add_services:
      - linux:metrics
    pmm_client_start_services:
      - linux:metrics
  roles:
    - timorunge.pmm_client
```

## 2) Install the PMM Client with basic auth and enabled SSL

```yaml
- hosts: all
  become: yes
  vars:
    pmm_client_server_host: 172.20.0.10
    pmm_client_server_port: 443
    pmm_client_server_basic_auth: True
    pmm_client_server_basic_auth_username: admin
    pmm_client_server_basic_auth_password: mySecurePassword
    pmm_client_server_use_ssl: True
    pmm_client_add_services:
      - linux:metrics
    pmm_client_start_services:
      - linux:metrics
  roles:
    - timorunge.pmm_client
```

## 3) Install the PMM Client from a defined URL

```yaml
- hosts: all
  become: yes
  vars:
    pmm_client_version: 1.14.1
    pmm_client_version_revision: 1
    pmm_client_use_official_repo: False
    pmm_client_debian_pkg: "https://www.percona.com/downloads/pmm/{{ pmm_client_version }}/binary/debian/{{ ansible_distribution_release }}/x86_64/pmm-client_{{ pmm_client_version }}-{{ pmm_client_version_revision }}.{{ ansible_distribution_release }}_amd64.deb"
  roles:
    - timorunge.pmm_client
```

## 4) Uninstall the PMM Client

```yaml
- hosts: all
  become: yes
  vars:
    pmm_client_enabled: False
  roles:
    - timorunge.pmm_client
```

Testing
-------

[![Build Status](https://travis-ci.org/timorunge/ansible-pmm-client.svg?branch=master)](https://travis-ci.org/timorunge/ansible-pmm-client)

Travis tests are done with [Docker](https://www.docker.com) and
[docker_test_runner](https://github.com/timorunge/docker-test-runner). Tests
on Travis are performing linting and syntax checks.

Dependencies
------------

None

License
-------
BSD

Author Information
------------------

- Based on the Ansible role from [Chris Sam](https://github.com/chrissam/ansible-role-pmm-client)
- Heavily modified by: Timo Runge
