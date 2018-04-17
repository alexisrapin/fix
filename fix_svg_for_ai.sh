#!/usr/bin/env bash
# A simple script to fix issues with SVG format.
# An Illustrator SVG font-related issue was discussed here https://github.com/CIRDLES/topsoil/issues/26.

#######
# Main
# Args:
#  inputfp
#  outputfp
#######
main() {

  local inputfp
  inputfp="${1}"

  local outputfp
  outputfp="${2}"

  echo '<?xml version="1.0" standalone="no"?>' > "${outputfp}"
  echo '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">' >> "${outputfp}"
  sed -e 's/font-family=\"[a-ZA-Z0-9 ,-]*\"/font-family=\"sans-serif\"/g;s/selected/slctd/g' "${inputfp}" >> "${outputfp}"

  if [[ $(grep -c "xmlns=" "${outputfp}") -eq 0 ]]; then
    sed -i -e 's/<svg/<svg xmlns="http:\/\/www.w3.org\/2000\/svg"/g' "${outputfp}"
  fi
  if [[ $(sed '1d' "${outputfp}" | grep -c "version=") -eq 0 ]]; then
    sed -i -e 's/<svg/<svg version="1\.1"/g' "${outputfp}"
  fi
  return 0
}

main "${@}"

exit 0
