#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${DIR}/base.sh"

if [[ -f .version ]]; then
	VERSION_MINOR=$(head -n1 .version)
elif [[ -f VERSION ]]; then
	VERSION_MINOR=$(head -n1 VERSION)
fi

: ${VERSION_MINOR:=v1.0}
: ${GIT_SRC:=origin/develop}
: ${GIT_DST:=master}
: ${FORCE_BRANCH:=develop}

info "Fetching latest remote branches and tags"
git fetch
git fetch --tags

# Ensure we are in FORCE_BRANCH (defaults to "develop")
if [ "$(git rev-parse --abbrev-ref HEAD)" != "${FORCE_BRANCH}" ]; then
	error "Local branch is not ${FORCE_BRANCH}"
	exit 1
fi

# Ensure working tree is clean
if [ -n "$(git status --porcelain)" ]; then
	error "Local working tree unclean"
	exit 1
fi

# Ensure there are no un-pushed commits
if [ -n "$(git log origin/${FORCE_BRANCH}..HEAD)" ]; then
	error "Local branch has un-pushed commits"
	exit 1
fi

info "Updating local branch"
git pull
if [ $? != 0 ]; then
	error "Failed to pull ${FORCE_BRANCH}"
	exit 1
fi

info "Finding next tag name"
TAGS=$(git tag -l | grep -E "^${VERSION_MINOR}\.[0-9]+")
: ${TAGS:=${VERSION_MINOR}.0}
MAJOR=`echo "${TAGS}" | sed 's/v\([0-9]*\)\..*/\1/' | sort -n | tail -1`
MINOR=`echo "${TAGS}" | grep v${MAJOR} | sed 's/v[0-9]*\.\([0-9]*\)\..*/\1/' | sort -n | tail -1`
PATCH=`echo "${TAGS}" | grep v${MAJOR}.${MINOR} | sed 's/v[0-9]*\.[0-9]*\.\([0-9]*\)/\1/' | sort -n | tail -1`
PATCH_NEXT=$(($PATCH + 1))
NEW_TAG="v${MAJOR}.${MINOR}.${PATCH_NEXT}"
LATEST_TAG="v${MAJOR}.${MINOR}.0-latest"

info "Creating tag ${NEW_TAG} and updating ${LATEST_TAG}"
git tag "${NEW_TAG}" "${GIT_SRC}"
git tag --force "${LATEST_TAG}" "${GIT_SRC}"

info "Pushing tags"
git push origin tag "${NEW_TAG}"
git push --force origin tag "${LATEST_TAG}"

info "Updating ${GIT_DST} branch"
git checkout "${GIT_DST}"
git merge --ff-only "${GIT_SRC}"
git push origin "${GIT_DST}"
git checkout -
