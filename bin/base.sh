#!/bin/bash

# Please keep me up to date
ROLES="\
    ansible \
    datadog \
    elasticsearch \
    gocd_agent \
    gocd_server \
    golang \
    java \
    kafka \
    kibana \
    logstash \
    nginx \
    nodejs \
    openvpn \
    php \
    postgresql \
    rabbitmq \
    ruby \
    rsyslog \
    users_and_groups \
    zookeeper \
"

C_RED=$(tput setaf 1)
C_GREEN=$(tput setaf 2)
C_YELLOW=$(tput setaf 3)
C_RESET=$(tput sgr0)

function info { echo -e "${C_YELLOW} => ${1}${C_RESET}"; }
function warn { echo -e "${C_RED} => ${1}${C_RESET}"; }
function ok { echo -e "${C_GREEN} => ${1}${C_RESET}"; }
function error { echo -e "\033[1;31m => Error: $1\033[0m"; }

function echo_color { echo -e "${2}${1}${C_RESET}"; }
