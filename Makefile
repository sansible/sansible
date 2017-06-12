include .make

ANSIBLE_INSTALL_VERSION ?= 2.2.3.0
ANSIBLE_CONFIG ?= tests/ansible.cfg
ROLE_NAME ?= $(shell basename $$(pwd))
TEST_PLAYBOOK ?= test.yml
VAGRANT_BOX ?= ubuntu/trusty64
PATH := $(PWD)/.venv_$(ANSIBLE_INSTALL_VERSION)/bin:$(shell printenv PATH)

.DEFAULT_GOAL := help
.PHONY: help

export ANSIBLE_CONFIG
export PATH
export VAGRANT_BOX
export TEST_PLAYBOOK

all: test clean

watch: test_deps
	while sleep 1; do \
		find defaults/ handlers/ meta/ tasks/ templates/ tests/vagrant/test.yml \
		| entr -d make lint vagrant_up; \
	done

test: lint test_deps vagrant_up

integration_test: clean integration_test_deps vagrant_up clean

test_deps: .venv_$(ANSIBLE_INSTALL_VERSION)
	rm -rf tests/sansible.*
	ln -s .. tests/sansible.$(ROLE_NAME)
	ansible-galaxy install --force -p tests -r tests/local_requirements.yml

## ! Executes Ansible tests using local connection
# run it ONLY from within a test VM.
# Example: make test_ansible
#          make test_ansible TEST_PLAYBOOK=test-something-else.yml
test_ansible: test_ansible_build test_ansible_configure
	cd tests && ansible-playbook \
		--inventory inventory \
		--connection local \
		--tags assert \
		$(TEST_PLAYBOOK)

## ! Executes Ansible tests using local connection
# run it ONLY from witinh a test VM.
# Example: make test_ansible_build
#          make test_ansible_build TEST_PLAYBOOK=test-something-else.yml
test_ansible_%:
	cd tests && ansible-playbook \
		--inventory inventory \
		--connection local \
		--tags=$(subst test_ansible_,,$@) \
		$(TEST_PLAYBOOK)
	cd tests && ansible-playbook \
		--inventory inventory \
		--connection local \
		--tags=$(subst test_ansible_,,$@) \
		$(TEST_PLAYBOOK) \
		| grep -q 'changed=0.*failed=0' \
			&& (echo 'Idempotence test: pass' && exit 0) \
			|| (echo 'Idempotence test: fail' && exit 1)

## Start and (re)provisiom Vagrant test box
vagrant:
	cd tests && vagrant up --no-provision
	cd tests && vagrant provision
	@echo "- - - - - - - - - - - - - - - - - - - - - - -"
	@echo "           Provisioning Successful"
	@echo "- - - - - - - - - - - - - - - - - - - - - - -"

## Execute simple Vagrant command
# Example: make vagrant_ssh
#          make vagrant_halt
vagrant_%:
	cd tests && vagrant $(subst vagrant_,,$@)

## Installs a virtual environment and all python dependencies
.venv_%:
	virtualenv .venv_$(ANSIBLE_INSTALL_VERSION)
	.venv_$(ANSIBLE_INSTALL_VERSION)/bin/pip install -r requirements.txt --ignore-installed
	.venv_$(ANSIBLE_INSTALL_VERSION)/bin/pip install ansible==$(ANSIBLE_INSTALL_VERSION)
	virtualenv --relocatable .venv_$(ANSIBLE_INSTALL_VERSION)

## list Ansible files
lint: .venv_$(ANSIBLE_INSTALL_VERSION)
	find defaults/ handlers/ meta/ tasks/ templates/ -name "*.yml" | xargs -I{} ansible-lint {}

## Prints this help
help:
	@awk -v skip=1 \
		'/^##/ { sub(/^[#[:blank:]]*/, "", $$0); doc_h=$$0; doc=""; skip=0; next } \
		 skip  { next } \
		 /^#/  { doc=doc "\n" substr($$0, 2); next } \
		 /:/   { sub(/:.*/, "", $$0); printf "\033[34m%-30s\033[0m\033[1m%s\033[0m %s\n\n", $$0, doc_h, doc; skip=1 }' \
		$(MAKEFILE_LIST)

## Removes all downloaded dependencies
clean:
	rm -rf .venv_*
	rm -rf tests/sansible.*
	cd tests && vagrant destroy

.make:
	touch .make
