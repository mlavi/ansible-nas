#!/usr/bin/env bash

source "${HOME}/Documents/gitlab.com/mlavi/homelab/common.lib.sh" .env Ansible.com/.env \
  && ansible-playbook nas-mlavi.homelab.yaml \
    --limit pi \
    --extra-vars "$(dotenv2keypair)" \
    --start-at-task="${1}*"
