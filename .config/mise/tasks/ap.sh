#!/usr/bin/env bash
# shellcheck shell=bash

#MISE description="select mlavi collection playbooks, limit from inventory"

function _select() {
  local _error
  local _hosts
  local _host_group
  local _playbook
  local _playbook_display
  local _tags

  _playbook=$(find ~/.ansible/collections/ansible_collections/mlavi -wholename "*/playbooks/*yaml" | fzf --exact)
  _playbook_display=$(echo "${_playbook}" | awk -F'ansible_collections/' '{print $2;}' | sed -e 's/playbooks\///' -e 's/\.yaml//' | tr '/' '.')
  _playbook_display="ansible-playbook ${_playbook_display}"

  _host_group=$(yq '.[].hosts' "${_playbook}")
  if (($(echo "${_host_group}" | grep --count 'default') > 0)); then
    _host_group=$(echo "${_host_group}" | awk -F'default' '{print $2}' | tr -d '() }"')
  fi
  if [[ $_host_group != 'all' ]]; then
    _hosts=$(yq ".${_host_group}.hosts" "${ANSIBLE_INVENTORY}hosts.yaml" | grep -v -e '#' -e ' ' | tr -d : | fzf --exact --exit-0 --select-1)
    _playbook_display+=" --limit ${_hosts}"
  fi

  _tags=$(yq '.[].tasks[].tags[]' "${_playbook}" | sort --unique --reverse | fzf --exact --exit-0 --select-1)
  if [[ -n ${_tags} ]]; then
    _playbook_display+=" --tags ${_tags}"
  fi
  echo "INFO" "|${_host_group}|${_hosts}|${_tags}|"
  echo "${_playbook_display}"
}

_select
