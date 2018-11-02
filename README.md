# pmm_client

This role installs and configures the Percona PMM Client.

## Requirements

This role requires
[Ansible 2.5.0](https://docs.ansible.com/ansible/devel/roadmap/ROADMAP_2_5.html)
or higher.

You can simply use pip to install (and define) a stable version:

```sh
pip install ansible==2.7.1
```

All platform requirements are listed in the metadata file.

## Install

```sh
ansible-galaxy install timorunge.pmm_client
```

## Role Variables

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
# Force to set client name on initial setup
# Type: Bool
pmm_client_force_setup: False
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

## Examples

### 1) Install the PMM Client with no basic auth and disabled SSL

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

### 2) Install the PMM Client with basic auth and enabled SSL

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

### 3) Install the PMM Client from a defined URL

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

### 4) Forcing the setup of the PMM Client

In some situations you have to force the setup of the PMM Client. E.g. if the
server was unreachable or you've done a new setup with a hostname which was
used before.

You will get a message like the following:

```sh
TASK [timorunge.pmm-client : include_tasks] ********************************************************************************************************
included: ... ansible-pmm-client/tasks/server-config.yml for proxysql-aN8thi

TASK [timorunge.pmm-client : Check if PMM Client is configured] ************************************************************************************
fatal: [proxysql-aN8thi]: FAILED! => {"changed": false, "cmd": ["pmm-admin", "list"], "delta": "0:00:00.148803", "end": "2018-09-25 09:39:46.297917", "msg": "non-zero return code", "rc": 1, "start": "2018-09-25 09:39:46.149114", "stderr": "", "stderr_lines": [], "stdout": "PMM client is not configured, missing config file. Please make sure you have run 'pmm-admin config'.", "stdout_lines": ["PMM client is not configured, missing config file. Please make sure you have run 'pmm-admin config'."]}
...ignoring

TASK [timorunge.pmm-client : Configure PMM Client - Basic mode] ************************************************************************************
fatal: [proxysql-aN8thi]: FAILED! => {"changed": true, "cmd": ["pmm-admin", "config", "--server", "172.20.0.10:80", "--client-name", "proxysql-aN8thi", "--config-file", "/usr/local/percona/pmm-client/pmm.yml"], "delta": "0:00:00.239708", "end": "2018-09-25 09:39:50.590280", "msg": "non-zero return code", "rc": 1, "start": "2018-09-25 09:39:50.350572", "stderr": "", "stderr_lines": [], "stdout": "Another client with the same name 'proxysql-aN8thi' detected, its address is 172.20.0.11.\nIt has the active services so this name is not available.\n\nSpecify the other one using --client-name flag.\n\nIn case this is the correct client node that was previously uninstalled with unreachable PMM server,\nyou can add --force flag to proceed further. Do not use this flag otherwise.\nThe orphaned remote services will be removed automatically.", "stdout_lines": ["Another client with the same name 'proxysql-aN8thi' detected, its address is 172.20.0.11.", "It has the active services so this name is not available.", "", "Specify the other one using --client-name flag.", "", "In case this is the correct client node that was previously uninstalled with unreachable PMM server,", "you can add --force flag to proceed further. Do not use this flag otherwise.", "The orphaned remote services will be removed automatically."]}
  to retry, use: --limit @... main.retry

PLAY RECAP *****************************************************************************************************************************************
proxysql-aN8thi            : ok=9    changed=0    unreachable=0    failed=1
```

Basically you have two options:

#### 1) Via yaml configuration

```yaml
- hosts: all
  become: yes
  vars:
    pmm_client_force_setup: True
  roles:
    - timorunge.pmm_client
```

#### 2) Via command line

This is the recommended way.

```sh
$ ansible-playbook main.yml -i inventory -b --limit "proxysql-aN8thi" --diff -e "{ pmm_client_force_setup: True }"

...

TASK [timorunge.pmm-client : Check if PMM Client is configured] ************************************************************************************
fatal: [proxysql-aN8thi{"changed": false, "cmd": ["pmm-admin", "list"], "delta": "0:00:00.361021", "end": "2018-09-25 09:51:30.675725", "msg": "non-zero return code", "rc": 1, "start": "2018-09-25 09:51:30.314704", "stderr": "", "stderr_lines": [], "stdout": "PMM client is not configured, missing config file. Please make sure you have run 'pmm-admin config'.", "stdout_lines": ["PMM client is not configured, missing config file. Please make sure you have run 'pmm-admin config'."]}
...ignoring

TASK [timorunge.pmm-client : Configure PMM Client - Basic mode] ************************************************************************************
changed: [proxysql-aN8thi]

...

TASK [timorunge.pmm-client : Adding Linux and ProxySQL services to monitoring] *********************************************************************
changed: [proxysql-aN8thi] => (item=linux:metrics)
changed: [proxysql-aN8thi] => (item=proxysql:metrics)

...

proxysql-aN8thi            : ok=13   changed=2    unreachable=0    failed=0
```

### 5) Uninstall the PMM Client

```yaml
- hosts: all
  become: yes
  vars:
    pmm_client_enabled: False
  roles:
    - timorunge.pmm_client
```

## Testing

[![Build Status](https://travis-ci.org/timorunge/ansible-pmm-client.svg?branch=master)](https://travis-ci.org/timorunge/ansible-pmm-client)

Tests are done with [Docker](https://www.docker.com) and
[docker_test_runner](https://github.com/timorunge/docker-test-runner) which
brings up the following containers with different environment settings:

- CentOS 7
- Debian 9.4 (Stretch)
- Ubuntu 16.04 (Xenial Xerus)
- Ubuntu 17.10 (Artful Aardvark)
- Ubuntu 18.04 (Bionic Beaver)

Ansible 2.7.1 is installed on all containers and a
[test playbook](tests/test.yml) is getting applied.

For further details and additional checks take a look at the
[docker_test_runner configuration](tests/docker_test_runner.yml) and the
[Docker entrypoint](tests/docker/docker-entrypoint.sh).

```sh
# Testing locally:
curl https://raw.githubusercontent.com/timorunge/docker-test-runner/master/install.sh | sh
./docker_test_runner.py -f tests/docker_test_runner.yml
```

Since the build time on Travis is limited for public repositories the
automated tests are limited to:

- CentOS 7
- Debian 9.4 (Stretch)
- Ubuntu 16.04 (Xenial Xerus)
- Ubuntu 18.04 (Bionic Beaver)

## Dependencies

None

## License

[BSD 3-Clause "New" or "Revised" License](https://spdx.org/licenses/BSD-3-Clause.html)

## Author Information

- Based on the Ansible role from [Chris Sam](https://github.com/chrissam/ansible-role-pmm-client)
- Heavily modified by: Timo Runge
