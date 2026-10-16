#!/usr/bin/env bash

#MISE description="local publish ansible_collections"

function install_offline() {
  local _collection
  local _full_semantic_version

  # Positional parameters/arguments:
  _collection="${1}"
  _full_semantic_version="${2}"

  echo -e "\n__ ${_collection}:${_full_semantic_version}"

  # ASSUMPTION: un{committ,track}ed files indicate build needed;
  # Commit after successful test?
  # TODO: leverage Semantic versioning pre-releases
  # TODO: in a && chain: ([condition]? do : true)
  #       for: debug = -vvvv --verbose
  # https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_collections_creating.html
  # https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_collections_distributing.html#ignoring-files-and-folders

  if (($(git status --porcelain --untracked-files=all | grep --count "${_collection}") > 0)); then
    yq eval \
      --inplace '.version = "'"${_full_semantic_version}"'"' \
      "${_collection}/galaxy.yml" \
      && rm -f "${_collection/\//-}-"*'.tar.gz' \
      && ansible-galaxy collection build "${_collection}" -vvvv \
      && ansible-galaxy collection install \
        --force --offline --pre --verbose \
        "${_collection/\//-}-${_full_semantic_version}.tar.gz" \
      && spd-say "${_collection} published."
    # install --no-deps --upgrade
    # sudo apt install speech-dispatcher

    echo "CHECK|${_collection} -name .env*" \
      && find "${HOME}/.ansible/collections/ansible_collections/${_collection}" -name ".env*"
    # If galaxy.yml ignores: '*/.env*'; then no need to purge collection installation

  else
    echo -e "\n__ ${_collection}: no updates."
  fi

  ansible-galaxy collection list "${_collection//\//.}"
}

source .env || exit 99

FULL_SEMVER="$(jq -r '.FullSemVer' "${RELEASE-release.json}")"
for COLLECTION in ${COLLECTION_DIR}; do
  install_offline "${COLLECTION}" "${FULL_SEMVER-0.0.0}"
done

echo
