#!/usr/bin/env bash

# This file is read by external tools. Do not move.
# Usage example in external projects:
#  curl -sSL https://raw.githubusercontent.com/kronostechnologies/standards/master/bin/docker-sbom.sh | bash -s -- -h

set -eo pipefail

DEFAULT_OUTPUT_FILE="./docker-sbom.json"

usage() {
  echo "Usage: $0 [-o result-file] [image-to-scan]"
}

while getopts ":o:h" option; do
  case $option in
  o)
    output_file=${OPTARG}
    ;;
  h)
    usage
    exit 0
    ;;
  *)
    usage
    exit 1
    ;;
  esac
done

shift $(($OPTIND - 1))
if [ $# -ne 1 ]; then
  usage
  exit 1
fi

output_file=${output_file:-$DEFAULT_OUTPUT_FILE}

mkdir -p "$(dirname "$output_file")"
touch "$output_file"

output_file_path=$(realpath "$output_file")

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$output_file_path":/root/output.json \
  -v /tmp/image.tar:/tmp/image.tar \
  philipssoftware/tern:2.9.1 \
  report -f cyclonedxjson -o /root/output.json -w /tmp/image.tar
