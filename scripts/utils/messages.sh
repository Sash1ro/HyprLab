#!/usr/bin/env bash
set -euo pipefail

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

OK=""
FAIL="󰅙"
INFO=""
WARN=""

help(){
cat <<EOF
Usage:
  $(basename $0) <command>

Commands :
    ok          -> show ok message
    fail        -> show fail message
    info        -> show info message
    warn        -> show warn message
    help        -> Show this message
EOF
}

msg_ok() { echo -e "${GREEN}${OK} $* ${RESET}"; }
msg_warn() { echo -e "${YELLOW}${WARN} $* ${RESET}"; }
msg_fail() { echo -e "${RED}${FAIL} $* ${RESET}"; }
msg_info() { echo -e "${BLUE}${INFO} $*${RESET}"; }

verif() {
    local arg=$1
    if [[ -z ${arg:-} ]]; then
        msg_fail "Message cannot be empty"
        exit 1
    fi
}
case $1 in 
    ok)verif ${2:-} && msg_ok $2;;
    info)verif ${2:-} && msg_info $2;;
    fail)verif ${2:-} && msg_fail $2;;
    warn)verif ${2:-} && msg_warn $2;;
    *|""|-h|help)help && exit 1;
esac
