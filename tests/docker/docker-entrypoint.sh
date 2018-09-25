#!/bin/sh
set -e

printf "[defaults]\nroles_path=/etc/ansible/roles\n" > /ansible/ansible.cfg

test -z ${pmm_client_use_official_repo} && \
  echo "Missing environment variable: pmm_client_use_official_repo" && exit 1
(test "${pmm_client_use_official_repo}" = "False" && \
  test -z ${pmm_client_version}) && \
  echo "Missing environment variable: pmm_client_version" && exit 1

if [ ! -f /etc/ansible/lint.zip ]; then
  wget https://github.com/ansible/galaxy-lint-rules/archive/master.zip -O \
  /etc/ansible/lint.zip
  unzip /etc/ansible/lint.zip -d /etc/ansible/lint
fi

ansible-lint -c /etc/ansible/roles/${ansible_role}/.ansible-lint -r \
  /etc/ansible/lint/galaxy-lint-rules-master/rules \
  /etc/ansible/roles/${ansible_role}
ansible-lint -c /etc/ansible/roles/${ansible_role}/.ansible-lint -r \
  /etc/ansible/lint/galaxy-lint-rules-master/rules \
  /ansible/test.yml

ansible-playbook /ansible/test.yml \
  -i /ansible/inventory \
  --syntax-check \
  -e "{ pmm_client_use_official_repo: ${pmm_client_use_official_repo} }" \
  -e "{ pmm_client_version: ${pmm_client_version} }"

ansible-playbook /ansible/test.yml \
  -i /ansible/inventory \
  --connection=local \
  --become \
  -e "{ pmm_client_use_official_repo: ${pmm_client_use_official_repo} }" \
  -e "{ pmm_client_version: ${pmm_client_version} }" \
  $(test -z ${travis} && echo "-vvvv")

ansible-playbook /ansible/test.yml \
  -i /ansible/inventory \
  --connection=local \
  --become \
  -e "{ pmm_client_use_official_repo: ${pmm_client_use_official_repo} }" \
  -e "{ pmm_client_version: ${pmm_client_version} }" | \
  grep -q "changed=0.*failed=0" && \
  (echo "Idempotence test: pass" && exit 0) || \
  (echo "Idempotence test: fail" && exit 1)
