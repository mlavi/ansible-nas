#!/usr/bin/env bash

_ghq_root=${GHQ_ROOT:-${HOME}/Documents}
_ansible_nas="${_ghq_root}/github.com/mlavi/ansible-nas"
_homelab="${_ghq_root}/gitlab.com/mlavi/homelab"

source "${_homelab}"/common.lib.sh "${_ansible_nas}"/.env "${_homelab}"/Ansible.com/.env \
  && ansible-playbook nas-mlavi.homelab.yaml \
    --limit pi \
    --extra-vars "$(dotenv2keypair)" \
    --start-at-task="${1}*"
