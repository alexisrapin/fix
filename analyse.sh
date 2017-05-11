#!/usr/bin/env bash
#analyse.sh
# © All rights reserved. ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland, Laboratory of Intestinal Immunology, 2016-2017"
# See the LICENSE.TXT file for more details.
# analyse using genocrunch_console

################
# Error function
# Args:
#  (1)  Error message
# Global vars:
#  __base  script name
################
err() {
  echo "Error [${__base}]: $@" >&2
  exit 1
}

################
# Main
# Args:
################
main() {

  local funcname
  funcname='main'

  local output_location
  output_location="${1}"

  local input_fp
  input_fp="${2}"

  local map_fp
  map_fp="${3}"

  local params_fp
  params_fp="${4}"

  local metadata_fp
  metadata_fp="${5}"

  # Set unique output directory
  local output_dir
  output_dir=$(greadlink -f $(mktemp -d "${output_location}"/"$(basename ${__file} .sh)"XXXXX))
  [[ ! -d "${output_dir}" ]] && { mkdir "${output_dir}" ; [[ "$?" -ne 0 ]] && \
  err "(line ${LINENO}) cannot make ${output_dir}" ; }
  [[ ! -w "${output_dir}" ]] && err "(line ${LINENO}) write permission denied on ${output_dir}"
  chown "${__user}" "${output_dir}"

  # Run the analysis using genocrunch_console
  if [[ "${metadata_fp}" != 'none' ]]; then
    /usr/local/bin/analyse_count_table.py --input "${input_fp}" --map "${map_fp}" --params "${params_fp}" --output "${output_dir}" --metadata "${metadata_fp}" > "${output_dir}"/job_log.txt
  else
    /usr/local/bin/analyse_count_table.py --input "${input_fp}" --map "${map_fp}" --params "${params_fp}" --output "${output_dir}" > "${output_dir}"/job_log.txt
  fi

  # Create archives
  cd "${output_location}" && tar zcmf "$(basename ${output_dir}).tar.gz" "$(basename ${output_dir})" && cd "${__workingdir}"

  printf "$(basename ${output_dir})"

  return 0
}

set -o nounset
set -o pipefail
#set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")"  && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file})"
__user=$(echo "${LOGNAME}")
__workingdir="$(pwd)"
[[ ! -w "${__workingdir}" ]] && err "(line ${LINENO}) write permission denied on ${__workingdir}"

main "${@}"

exit 0
