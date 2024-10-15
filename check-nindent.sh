#!/bin/bash

set -eo pipefail

# A bunch of text colors for echoing
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NOC='\033[0m'

function usage() {
  _info "Usage: helm check-nindent <chart folder>"
  exit 0
}


# getting filename
_CHART_FOLDER="$1"

if [[ $# -eq 0 || "$_CHART_FOLDER" == "help" || "$_CHART_FOLDER" == "-h" || "$_CHART_FOLDER" == "--help" ]]; then
  usage
fi

if [[ $# -ne 1 ]]; then
  usage
fi

function _err() {
  echo -e "${RED}ERROR: ${1}${NOC}"
}
function _fatal() {
  echo -e "${RED}FATAL: ${1}${NOC}"
  exit 1
}
function _info() {
  echo -e "${BLUE}INFO: ${1}${NOC}"
}
function _success() {
  echo -e "${GREEN}SUCCESS: ${1}${NOC}"
}
function _warn() {
  echo -e "${YELLOW}WARN: ${1}${NOC}"
}

_CHART_FOLDER_BASE=$(basename $(readlink -f ${_CHART_FOLDER}))/templates

_FILENAMES=$(find ${_CHART_FOLDER}/templates -type f \( -name "*.yaml" -o -name "*.yml" \))

# check if file exists
if [[ -z "$_FILENAMES" ]]; then
    _fatal "Provided charts folder ${_CHART_FOLDER} does not contain template files"
fi

_HAS_ERRORS=0

function _check_file() {
  local __FILENAME=$1
  local __LINE_NUM=0
  local __SPACES_NUM=0
  local __CHECK_NINDENT=

  if [[ ! -f "$__FILENAME" ]]; then
    _err "File ${__FILENAME} does not exist!"
  fi

  while IFS= read -r __LINE; do
    __LINE_NUM=$((__LINE_NUM+1))
    # check if we have 'nindent' defined
    if echo "${__LINE}" | grep -q "nindent"; then
      # get nindent value
      __CHECK_NINDENT=$(echo "${__LINE}" | sed -r 's/.*nindent ([0-9]+).*/\1/')

      # if no ninent value -- skip line
      if [[ -z $__CHECK_NINDENT ]]; then
        continue
      fi

      # get whitespace count till '{'
      __SPACES_NUM=$(echo "${__LINE}" | cut -d'{' -f1 | wc -c | tr -d ' ')
      __SPACES_NUM=$((__SPACES_NUM-1))

      # compate spaces and nindent value 'indent'
      if [[ $__SPACES_NUM -ne $__CHECK_NINDENT ]]; then
        __FILENAME_BASE=$(basename ${__FILENAME})
        _err "File ${_CHART_FOLDER_BASE}/${__FILENAME_BASE} on line #${__LINE_NUM}: whitespace num (${__SPACES_NUM}) is not equal to ${__CHECK_NINDENT}."
        _HAS_ERRORS=1
      fi
    fi
  done < "${__FILENAME}"
}

for __FILENAME in $_FILENAMES; do
  _check_file "$__FILENAME"
done

exit $_HAS_ERRORS

