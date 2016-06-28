#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${DIR}/base.sh"

VERSION_MINOR=$(head -n1 .version)

: ${VERSION_MINOR:=v1.0}
: ${GIT_SRC:=origin/develop}
: ${GIT_DST:=master}

info "Fetching latest remote branches and tags"
git fetch
git fetch --tags

info "Finding next tag name"
TAGS=$(git tag -l | grep -E "^${VERSION_MINOR}\.[0-9]+")
: ${TAGS:=${VERSION_MINOR}.0}
MAJOR=`echo "${TAGS}" | sed 's/v\([0-9]*\)\..*/\1/' | sort -n | tail -1`
MINOR=`echo "${TAGS}" | grep v${MAJOR} | sed 's/v[0-9]*\.\([0-9]*\)\..*/\1/' | sort -n | tail -1`
PATCH=`echo "${TAGS}" | grep v${MAJOR}.${MINOR} | sed 's/v[0-9]*\.[0-9]*\.\([0-9]*\)/\1/' | sort -n | tail -1`
PATCH_NEXT=$(($PATCH + 1))
NEW_TAG="v${MAJOR}.${MINOR}.${PATCH_NEXT}"

info "Creating tag ${NEW_TAG} and updating ${VERSION_MINOR}"
git tag "${NEW_TAG}" "${GIT_SRC}"
git tag --force "${VERSION_MINOR}" "${GIT_SRC}"

info "Pushing tags"
git push origin tag "${NEW_TAG}"
git push --force origin tag "${VERSION_MINOR}"

info "Updating ${GIT_DST} branch"
git checkout "${GIT_DST}"
git merge --ff-only "${GIT_SRC}"
git push origin "${GIT_DST}"
git checkout -
