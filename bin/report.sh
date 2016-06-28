#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SANSIBLE_ROOT="${DIR}/../.."

. "${DIR}/base.sh"


function main {
    if [ "this" == "${1}" ]; then
        print_branches "$(basename `pwd`)"
    else
        for role in ${ROLES}; do
            info "Checking ${role}"
            print_branches "${role}"
        done
    fi
}

function print_branches {
    local role=$1
    local CHECK_DEVELOP="x"
    local CHECK_MASTER="x"
    local CHECK_TAG="x"
    local hash_master=""
    local hash_develop=""

    if [ ! -d "${SANSIBLE_ROOT}/${role}" ]; then
        warn "Role ${role} is not checkout"
        return
    fi

    git --git-dir="${SANSIBLE_ROOT}/${role}/.git" fetch --prune
    BRANCHES=$(git --git-dir="${SANSIBLE_ROOT}/${role}/.git" branch -a)
    ORIGIN=$(echo "${BRANCHES}" \
        | grep "remotes/origin" \
        | sed 's/remotes\/origin\/\(.*\)/\1/')

    hash_v10=$(git --git-dir="${SANSIBLE_ROOT}/${role}/.git" log -n1 --format=%h v1.0)

    echo "${ORIGIN}" | grep develop &> /dev/null
    if [ $? -eq 0 ]; then
        CHECK_DEVELOP="✔";
        hash_develop=$(git --git-dir="${SANSIBLE_ROOT}/${role}/.git" log -n1 --format=%h origin/develop)
    fi

    echo "${ORIGIN}" | grep master &> /dev/null
    if [ $? -eq 0 ]; then
        CHECK_MASTER="✔";
        hash_master=$(git --git-dir="${SANSIBLE_ROOT}/${role}/.git" log -n1 --format=%h origin/master)

        if [[ "${hash_v10}" == "${hash_master}" ]]; then
            CHECK_TAG="✔";
        fi
    fi

    echo "
|  master | ${CHECK_MASTER} | ${hash_master}
| develop | ${CHECK_DEVELOP} | ${hash_develop}"

    echo "|    v1.0 | ${CHECK_TAG} | ${hash_v10}"

    tag=$(git --git-dir="${SANSIBLE_ROOT}/${role}/.git" tag -l \
        | grep -E "^v1\.0\.[0-9]+" \
        | sort -t. -k 1,1nr -k 2,2nr -k 3,3nr\
        | head -n1)

    tag_hash=$(git --git-dir="${SANSIBLE_ROOT}/${role}/.git" log -n1 --format=%h "${tag}")
    echo "|  ${tag} | ${CHECK_TAG} | ${tag_hash}"

    tags=$(git --git-dir="${SANSIBLE_ROOT}/${role}/.git" tag -l \
        | grep -E "^v1\.0\.[0-9]+" \
        | grep -v "${tag}" \
        | sort -t. -k 1,1nr -k 2,2nr -k 3,3nr \
        | head -n3 | tail -n2)

    for tag in ${tags}; do
        tag_hash=$(git --git-dir="${SANSIBLE_ROOT}/${role}/.git" log -n1 --format=%h "${tag}")
        echo "|  ${tag} | - | ${tag_hash}"
    done

    info "Merged Branches (to be deleted)"
    git --git-dir="${SANSIBLE_ROOT}/${role}/.git" branch -a --merged origin/develop \
        | grep "remotes/origin" \
        | sed 's/remotes\/origin\/\(.*\)/\1/' \
        | grep -vE "(develop|master)" \
        | xargs -I{} echo " o  {}"
}

main "$@"
